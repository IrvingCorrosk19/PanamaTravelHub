using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Infrastructure.Data;
using System.Text.Json;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/analytics")]
public class AnalyticsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<AnalyticsController> _logger;

    public AnalyticsController(
        ApplicationDbContext context,
        ILogger<AnalyticsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Registra un evento de analytics (first-party)
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> TrackEvent([FromBody] TrackEventRequest request)
    {
        try
        {
            // Validar evento
            if (string.IsNullOrWhiteSpace(request.Event))
            {
                return BadRequest(new { message = "El evento es requerido" });
            }

            // Obtener userId si está autenticado
            Guid? userId = null;
            var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier);
            if (userIdClaim != null && Guid.TryParse(userIdClaim.Value, out var parsedUserId))
            {
                userId = parsedUserId;
            }

            // Detectar dispositivo desde User-Agent
            var userAgent = Request.Headers["User-Agent"].ToString();
            var device = DetectDevice(userAgent);

            // Crear evento
            var analyticsEvent = new AnalyticsEvent
            {
                Event = request.Event,
                EntityType = request.EntityType,
                EntityId = request.EntityId,
                SessionId = request.SessionId,
                UserId = userId,
                Metadata = request.Metadata != null ? JsonSerializer.Serialize(request.Metadata) : null,
                Device = device,
                UserAgent = userAgent,
                Referrer = Request.Headers["Referer"].ToString(),
                Country = request.Country,
                City = request.City,
                CreatedAt = DateTime.UtcNow
            };

            _context.AnalyticsEvents.Add(analyticsEvent);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Evento registrado", id = analyticsEvent.Id });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al registrar evento de analytics: {Event}", request.Event);
            // No fallar silenciosamente, pero no bloquear al usuario
            return StatusCode(500, new { message = "Error al registrar evento" });
        }
    }

    /// <summary>
    /// Obtiene métricas de conversión (Admin)
    /// </summary>
    [HttpGet("metrics")]
    [Microsoft.AspNetCore.Authorization.Authorize]
    public async Task<IActionResult> GetMetrics(
        [FromQuery] DateTime? startDate = null,
        [FromQuery] DateTime? endDate = null,
        [FromQuery] Guid? tourId = null)
    {
        try
        {
            var start = startDate ?? DateTime.UtcNow.AddDays(-30);
            var end = endDate ?? DateTime.UtcNow;

            var query = _context.AnalyticsEvents
                .Where(e => e.CreatedAt >= start && e.CreatedAt <= end);

            if (tourId.HasValue)
            {
                query = query.Where(e => e.EntityType == "tour" && e.EntityId == tourId.Value);
            }

            var events = await query.ToListAsync();

            // Calcular ingresos desde metadata de payment_success
            var revenue = events
                .Where(e => e.Event == "payment_success" && !string.IsNullOrEmpty(e.Metadata))
                .Select(e =>
                {
                    try
                    {
                        var metadata = System.Text.Json.JsonSerializer.Deserialize<Dictionary<string, object>>(e.Metadata!);
                        if (metadata != null && metadata.ContainsKey("amount"))
                        {
                            if (metadata["amount"] is System.Text.Json.JsonElement elem && elem.ValueKind == System.Text.Json.JsonValueKind.Number)
                            {
                                return elem.GetDecimal();
                            }
                            if (decimal.TryParse(metadata["amount"]?.ToString(), out var amount))
                            {
                                return amount;
                            }
                        }
                    }
                    catch { }
                    return 0m;
                })
                .Sum();

            var tourViews = events.Count(e => e.Event == "tour_viewed");
            var reserveClicks = events.Count(e => e.Event == "reserve_clicked");
            var checkoutViews = events.Count(e => e.Event == "checkout_viewed");
            var paymentStarted = events.Count(e => e.Event == "payment_started");
            var paymentSuccess = events.Count(e => e.Event == "payment_success");
            var paymentFailed = events.Count(e => e.Event == "payment_failed");
            var availabilityViewed = events.Count(e => e.Event == "availability_viewed");
            var stickyCtaShown = events.Count(e => e.Event == "sticky_cta_shown");
            var urgencyShown = events.Count(e => e.Event == "urgency_shown");

            // Conversión total
            var conversionRate = tourViews > 0
                ? (double)paymentSuccess / tourViews * 100
                : 0;

            // Ticket promedio
            var averageTicket = paymentSuccess > 0
                ? (double)revenue / paymentSuccess
                : 0;

            // Métricas básicas
            var metrics = new
            {
                TotalEvents = events.Count,
                TourViews = tourViews,
                ReserveClicks = reserveClicks,
                CheckoutViews = checkoutViews,
                PaymentStarted = paymentStarted,
                PaymentSuccess = paymentSuccess,
                PaymentFailed = paymentFailed,
                AvailabilityViewed = availabilityViewed,
                StickyCtaShown = stickyCtaShown,
                UrgencyShown = urgencyShown,
                
                // Conversión
                ConversionRate = conversionRate,
                Revenue = revenue,
                AverageTicket = averageTicket,
                
                // Por dispositivo
                ByDevice = events
                    .Where(e => !string.IsNullOrEmpty(e.Device))
                    .GroupBy(e => e.Device)
                    .Select(g => new { Device = g.Key, Count = g.Count() })
                    .ToList(),
                
                // Eventos por día
                ByDay = events
                    .GroupBy(e => e.CreatedAt.Date)
                    .Select(g => new { Date = g.Key, Count = g.Count() })
                    .OrderBy(x => x.Date)
                    .ToList()
            };

            return Ok(metrics);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener métricas");
            throw;
        }
    }

    /// <summary>
    /// Obtiene funnel de conversión (Admin)
    /// </summary>
    [HttpGet("funnel")]
    [Microsoft.AspNetCore.Authorization.Authorize]
    public async Task<IActionResult> GetFunnel(
        [FromQuery] DateTime? startDate = null,
        [FromQuery] DateTime? endDate = null)
    {
        try
        {
            var start = startDate ?? DateTime.UtcNow.AddDays(-30);
            var end = endDate ?? DateTime.UtcNow;

            var events = await _context.AnalyticsEvents
                .Where(e => e.CreatedAt >= start && e.CreatedAt <= end)
                .OrderBy(e => e.CreatedAt)
                .ToListAsync();

            // Agrupar por sesión para construir funnel
            var sessions = events
                .GroupBy(e => e.SessionId)
                .Select(g => new
                {
                    SessionId = g.Key,
                    Events = g.OrderBy(e => e.CreatedAt).Select(e => e.Event).ToList()
                })
                .ToList();

            var tourViewed = sessions.Count(s => s.Events.Contains("tour_viewed"));
            var availabilityViewed = sessions.Count(s => s.Events.Contains("availability_viewed"));
            var reserveClicked = sessions.Count(s => s.Events.Contains("reserve_clicked"));
            var checkoutViewed = sessions.Count(s => s.Events.Contains("checkout_viewed"));
            var paymentStarted = sessions.Count(s => s.Events.Contains("payment_started"));
            var paymentSuccess = sessions.Count(s => s.Events.Contains("payment_success"));

            var funnel = new
            {
                TourViewed = tourViewed,
                AvailabilityViewed = availabilityViewed,
                ReserveClicked = reserveClicked,
                CheckoutViewed = checkoutViewed,
                PaymentStarted = paymentStarted,
                PaymentSuccess = paymentSuccess
            };

            return Ok(funnel);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener funnel");
            throw;
        }
    }

    /// <summary>
    /// Obtiene top tours por métricas (Admin)
    /// </summary>
    [HttpGet("top-tours")]
    [Microsoft.AspNetCore.Authorization.Authorize]
    public async Task<IActionResult> GetTopTours(
        [FromQuery] DateTime? startDate = null,
        [FromQuery] DateTime? endDate = null,
        [FromQuery] int limit = 10)
    {
        try
        {
            var start = startDate ?? DateTime.UtcNow.AddDays(-30);
            var end = endDate ?? DateTime.UtcNow;

            // Obtener eventos de tours
            var tourEvents = await _context.AnalyticsEvents
                .Where(e => e.CreatedAt >= start && e.CreatedAt <= end && e.EntityType == "tour" && e.EntityId.HasValue)
                .ToListAsync();

            // Agrupar por tour
            var tourStats = tourEvents
                .GroupBy(e => e.EntityId!.Value)
                .Select(g => new
                {
                    TourId = g.Key,
                    Views = g.Count(e => e.Event == "tour_viewed"),
                    ReserveClicks = g.Count(e => e.Event == "reserve_clicked"),
                    CheckoutViews = g.Count(e => e.Event == "checkout_viewed"),
                    PaymentSuccess = g.Count(e => e.Event == "payment_success"),
                    Revenue = g
                        .Where(e => e.Event == "payment_success" && !string.IsNullOrEmpty(e.Metadata))
                        .Select(e =>
                        {
                            try
                            {
                                var metadata = System.Text.Json.JsonSerializer.Deserialize<Dictionary<string, object>>(e.Metadata!);
                                if (metadata != null && metadata.ContainsKey("amount"))
                                {
                                    if (metadata["amount"] is System.Text.Json.JsonElement elem && elem.ValueKind == System.Text.Json.JsonValueKind.Number)
                                    {
                                        return elem.GetDecimal();
                                    }
                                    if (decimal.TryParse(metadata["amount"]?.ToString(), out var amount))
                                    {
                                        return amount;
                                    }
                                }
                            }
                            catch { }
                            return 0m;
                        })
                        .Sum()
                })
                .Where(t => t.Views > 0)
                .Select(t => new
                {
                    t.TourId,
                    t.Views,
                    t.ReserveClicks,
                    t.CheckoutViews,
                    t.PaymentSuccess,
                    t.Revenue,
                    ConversionRate = t.Views > 0 ? (double)t.PaymentSuccess / t.Views * 100 : 0
                })
                .OrderByDescending(t => t.Revenue)
                .ThenByDescending(t => t.PaymentSuccess)
                .Take(limit)
                .ToList();

            // Obtener nombres de tours
            var tourIds = tourStats.Select(t => t.TourId).ToList();
            var tours = await _context.Tours
                .Where(t => tourIds.Contains(t.Id))
                .Select(t => new { t.Id, t.Name })
                .ToListAsync();

            var result = tourStats.Select(stat =>
            {
                var tour = tours.FirstOrDefault(t => t.Id == stat.TourId);
                return new
                {
                    stat.TourId,
                    TourName = tour?.Name ?? "Tour desconocido",
                    stat.Views,
                    stat.ReserveClicks,
                    stat.CheckoutViews,
                    stat.PaymentSuccess,
                    stat.Revenue,
                    stat.ConversionRate
                };
            }).ToList();

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener top tours");
            throw;
        }
    }

    /// <summary>
    /// Obtiene impacto de UX (Admin)
    /// </summary>
    [HttpGet("ux-impact")]
    [Microsoft.AspNetCore.Authorization.Authorize]
    public async Task<IActionResult> GetUxImpact(
        [FromQuery] DateTime? startDate = null,
        [FromQuery] DateTime? endDate = null)
    {
        try
        {
            var start = startDate ?? DateTime.UtcNow.AddDays(-30);
            var end = endDate ?? DateTime.UtcNow;

            var events = await _context.AnalyticsEvents
                .Where(e => e.CreatedAt >= start && e.CreatedAt <= end)
                .ToListAsync();

            // Agrupar por sesión
            var sessions = events
                .GroupBy(e => e.SessionId)
                .Select(g => new
                {
                    SessionId = g.Key,
                    Events = g.OrderBy(e => e.CreatedAt).Select(e => new { e.Event, e.Device }).ToList()
                })
                .ToList();

            // Sticky CTA Impact
            var sessionsWithStickyCta = sessions.Count(s => s.Events.Any(e => e.Event == "sticky_cta_shown"));
            var sessionsWithStickyCtaAndReserve = sessions.Count(s => 
                s.Events.Any(e => e.Event == "sticky_cta_shown") && 
                s.Events.Any(e => e.Event == "reserve_clicked"));
            var stickyCtaConversion = sessionsWithStickyCta > 0
                ? (double)sessionsWithStickyCtaAndReserve / sessionsWithStickyCta * 100
                : 0;

            // Urgency Impact
            var sessionsWithUrgency = sessions.Count(s => s.Events.Any(e => e.Event == "urgency_shown"));
            var sessionsWithUrgencyAndReserve = sessions.Count(s => 
                s.Events.Any(e => e.Event == "urgency_shown") && 
                s.Events.Any(e => e.Event == "reserve_clicked"));
            var urgencyConversion = sessionsWithUrgency > 0
                ? (double)sessionsWithUrgencyAndReserve / sessionsWithUrgency * 100
                : 0;

            // Device Impact
            var mobileSessions = sessions.Where(s => s.Events.Any(e => e.Device == "mobile")).ToList();
            var desktopSessions = sessions.Where(s => s.Events.Any(e => e.Device == "desktop")).ToList();
            var tabletSessions = sessions.Where(s => s.Events.Any(e => e.Device == "tablet")).ToList();

            var mobileConversion = mobileSessions.Count > 0
                ? (double)mobileSessions.Count(s => s.Events.Any(e => e.Event == "payment_success")) / mobileSessions.Count * 100
                : 0;

            var desktopConversion = desktopSessions.Count > 0
                ? (double)desktopSessions.Count(s => s.Events.Any(e => e.Event == "payment_success")) / desktopSessions.Count * 100
                : 0;

            var tabletConversion = tabletSessions.Count > 0
                ? (double)tabletSessions.Count(s => s.Events.Any(e => e.Event == "payment_success")) / tabletSessions.Count * 100
                : 0;

            var impact = new
            {
                StickyCta = new
                {
                    Shown = sessionsWithStickyCta,
                    Converted = sessionsWithStickyCtaAndReserve,
                    ConversionRate = stickyCtaConversion
                },
                Urgency = new
                {
                    Shown = sessionsWithUrgency,
                    Converted = sessionsWithUrgencyAndReserve,
                    ConversionRate = urgencyConversion
                },
                ByDevice = new
                {
                    Mobile = new { Sessions = mobileSessions.Count, ConversionRate = mobileConversion },
                    Desktop = new { Sessions = desktopSessions.Count, ConversionRate = desktopConversion },
                    Tablet = new { Sessions = tabletSessions.Count, ConversionRate = tabletConversion }
                }
            };

            return Ok(impact);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener impacto UX");
            throw;
        }
    }

    private string? DetectDevice(string userAgent)
    {
        if (string.IsNullOrEmpty(userAgent))
            return null;

        var ua = userAgent.ToLower();
        
        if (ua.Contains("mobile") || ua.Contains("android") || ua.Contains("iphone") || ua.Contains("ipod"))
            return "mobile";
        
        if (ua.Contains("tablet") || ua.Contains("ipad"))
            return "tablet";
        
        return "desktop";
    }
}

public class TrackEventRequest
{
    public string Event { get; set; } = string.Empty;
    public string? EntityType { get; set; }
    public Guid? EntityId { get; set; }
    public Guid SessionId { get; set; }
    public Dictionary<string, object>? Metadata { get; set; }
    public string? Country { get; set; }
    public string? City { get; set; }
}
