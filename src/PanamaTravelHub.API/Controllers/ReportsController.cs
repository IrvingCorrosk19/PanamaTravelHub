using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Domain.Enums;
using PanamaTravelHub.Infrastructure.Data;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/admin/reports")]
[Authorize(Policy = "AdminOnly")]
public class ReportsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<ReportsController> _logger;

    public ReportsController(
        ApplicationDbContext context,
        ILogger<ReportsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Obtiene un resumen general de estadísticas
    /// </summary>
    [HttpGet("summary")]
    public async Task<ActionResult<ReportsSummaryDto>> GetSummary(
        [FromQuery] DateTime? startDate = null,
        [FromQuery] DateTime? endDate = null)
    {
        try
        {
            var start = startDate ?? DateTime.UtcNow.AddMonths(-1);
            var end = endDate ?? DateTime.UtcNow;

            // Asegurar que las fechas estén en UTC
            if (start.Kind != DateTimeKind.Utc)
                start = DateTime.SpecifyKind(start, DateTimeKind.Utc);
            if (end.Kind != DateTimeKind.Utc)
                end = DateTime.SpecifyKind(end, DateTimeKind.Utc);

            var query = _context.Bookings
                .Where(b => b.CreatedAt >= start && b.CreatedAt <= end);

            var totalBookings = await query.CountAsync();
            var confirmedBookings = await query.CountAsync(b => b.Status == BookingStatus.Confirmed);
            var pendingBookings = await query.CountAsync(b => b.Status == BookingStatus.Pending);
            var cancelledBookings = await query.CountAsync(b => b.Status == BookingStatus.Cancelled);

            var totalRevenue = await query
                .Where(b => b.Status == BookingStatus.Confirmed)
                .SumAsync(b => (decimal?)b.TotalAmount) ?? 0;

            var averageTicket = confirmedBookings > 0 
                ? totalRevenue / confirmedBookings 
                : 0;

            var totalTours = await _context.Tours.CountAsync(t => t.IsActive);
            var totalUsers = await _context.Users.CountAsync(u => u.IsActive);

            var conversionRate = totalUsers > 0 
                ? (decimal)confirmedBookings / totalUsers * 100 
                : 0;

            var result = new ReportsSummaryDto
            {
                Period = new DateRangeDto
                {
                    StartDate = start,
                    EndDate = end
                },
                Bookings = new BookingsSummaryDto
                {
                    Total = totalBookings,
                    Confirmed = confirmedBookings,
                    Pending = pendingBookings,
                    Cancelled = cancelledBookings
                },
                Revenue = new RevenueSummaryDto
                {
                    Total = totalRevenue,
                    AverageTicket = averageTicket,
                    Currency = "USD"
                },
                Tours = new ToursSummaryDto
                {
                    Total = totalTours,
                    Active = totalTours
                },
                Users = new UsersSummaryDto
                {
                    Total = totalUsers
                },
                ConversionRate = conversionRate
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener resumen de reportes");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Obtiene reporte de tours (más vendidos, más rentables, etc.)
    /// </summary>
    [HttpGet("tours")]
    public async Task<ActionResult<ToursReportDto>> GetToursReport(
        [FromQuery] DateTime? startDate = null,
        [FromQuery] DateTime? endDate = null,
        [FromQuery] int limit = 10)
    {
        try
        {
            var start = startDate ?? DateTime.UtcNow.AddMonths(-1);
            var end = endDate ?? DateTime.UtcNow;

            if (start.Kind != DateTimeKind.Utc)
                start = DateTime.SpecifyKind(start, DateTimeKind.Utc);
            if (end.Kind != DateTimeKind.Utc)
                end = DateTime.SpecifyKind(end, DateTimeKind.Utc);

            // Tours más vendidos
            var topSellingTours = await _context.Bookings
                .Where(b => b.CreatedAt >= start && b.CreatedAt <= end && b.Status == BookingStatus.Confirmed)
                .GroupBy(b => new { b.TourId, b.Tour.Name })
                .Select(g => new TourSalesDto
                {
                    TourId = g.Key.TourId,
                    TourName = g.Key.Name,
                    TotalBookings = g.Count(),
                    TotalRevenue = g.Sum(b => b.TotalAmount),
                    TotalParticipants = g.Sum(b => b.NumberOfParticipants)
                })
                .OrderByDescending(t => t.TotalBookings)
                .Take(limit)
                .ToListAsync();

            // Tours más rentables
            var topRevenueTours = await _context.Bookings
                .Where(b => b.CreatedAt >= start && b.CreatedAt <= end && b.Status == BookingStatus.Confirmed)
                .GroupBy(b => new { b.TourId, b.Tour.Name })
                .Select(g => new TourSalesDto
                {
                    TourId = g.Key.TourId,
                    TourName = g.Key.Name,
                    TotalBookings = g.Count(),
                    TotalRevenue = g.Sum(b => b.TotalAmount),
                    TotalParticipants = g.Sum(b => b.NumberOfParticipants)
                })
                .OrderByDescending(t => t.TotalRevenue)
                .Take(limit)
                .ToListAsync();

            var result = new ToursReportDto
            {
                Period = new DateRangeDto
                {
                    StartDate = start,
                    EndDate = end
                },
                TopSellingTours = topSellingTours,
                TopRevenueTours = topRevenueTours
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener reporte de tours");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Obtiene series de tiempo (datos para gráficos)
    /// </summary>
    [HttpGet("timeseries")]
    public async Task<ActionResult<TimeseriesReportDto>> GetTimeseries(
        [FromQuery] DateTime? startDate = null,
        [FromQuery] DateTime? endDate = null,
        [FromQuery] string groupBy = "day") // day, week, month
    {
        try
        {
            var start = startDate ?? DateTime.UtcNow.AddMonths(-1);
            var end = endDate ?? DateTime.UtcNow;

            if (start.Kind != DateTimeKind.Utc)
                start = DateTime.SpecifyKind(start, DateTimeKind.Utc);
            if (end.Kind != DateTimeKind.Utc)
                end = DateTime.SpecifyKind(end, DateTimeKind.Utc);

            var bookings = await _context.Bookings
                .Where(b => b.CreatedAt >= start && b.CreatedAt <= end)
                .Select(b => new
                {
                    Date = b.CreatedAt,
                    Status = b.Status,
                    TotalAmount = b.TotalAmount
                })
                .ToListAsync();

            var dataPoints = new List<TimeseriesDataPointDto>();

            if (groupBy.ToLower() == "day")
            {
                var grouped = bookings
                    .GroupBy(b => b.Date.Date)
                    .OrderBy(g => g.Key)
                    .Select(g => new TimeseriesDataPointDto
                    {
                        Date = g.Key,
                        Bookings = g.Count(),
                        ConfirmedBookings = g.Count(b => b.Status == BookingStatus.Confirmed),
                        Revenue = g.Where(b => b.Status == BookingStatus.Confirmed).Sum(b => b.TotalAmount)
                    })
                    .ToList();

                dataPoints = grouped;
            }
            else if (groupBy.ToLower() == "week")
            {
                var grouped = bookings
                    .GroupBy(b => new { Year = b.Date.Year, Week = GetWeekOfYear(b.Date) })
                    .OrderBy(g => g.Key.Year).ThenBy(g => g.Key.Week)
                    .Select(g => new TimeseriesDataPointDto
                    {
                        Date = GetFirstDayOfWeek(g.Key.Year, g.Key.Week),
                        Bookings = g.Count(),
                        ConfirmedBookings = g.Count(b => b.Status == BookingStatus.Confirmed),
                        Revenue = g.Where(b => b.Status == BookingStatus.Confirmed).Sum(b => b.TotalAmount)
                    })
                    .ToList();

                dataPoints = grouped;
            }
            else if (groupBy.ToLower() == "month")
            {
                var grouped = bookings
                    .GroupBy(b => new { b.Date.Year, b.Date.Month })
                    .OrderBy(g => g.Key.Year).ThenBy(g => g.Key.Month)
                    .Select(g => new TimeseriesDataPointDto
                    {
                        Date = new DateTime(g.Key.Year, g.Key.Month, 1),
                        Bookings = g.Count(),
                        ConfirmedBookings = g.Count(b => b.Status == BookingStatus.Confirmed),
                        Revenue = g.Where(b => b.Status == BookingStatus.Confirmed).Sum(b => b.TotalAmount)
                    })
                    .ToList();

                dataPoints = grouped;
            }

            var result = new TimeseriesReportDto
            {
                Period = new DateRangeDto
                {
                    StartDate = start,
                    EndDate = end
                },
                GroupBy = groupBy,
                DataPoints = dataPoints
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener series de tiempo");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Obtiene reporte de clientes
    /// </summary>
    [HttpGet("customers")]
    public async Task<ActionResult<CustomersReportDto>> GetCustomersReport(
        [FromQuery] DateTime? startDate = null,
        [FromQuery] DateTime? endDate = null,
        [FromQuery] int limit = 10)
    {
        try
        {
            var start = startDate ?? DateTime.UtcNow.AddMonths(-1);
            var end = endDate ?? DateTime.UtcNow;

            if (start.Kind != DateTimeKind.Utc)
                start = DateTime.SpecifyKind(start, DateTimeKind.Utc);
            if (end.Kind != DateTimeKind.Utc)
                end = DateTime.SpecifyKind(end, DateTimeKind.Utc);

            // Clientes más activos
            var topCustomers = await _context.Users
                .Where(u => u.Bookings.Any(b => b.CreatedAt >= start && b.CreatedAt <= end))
                .Select(u => new CustomerStatsDto
                {
                    UserId = u.Id,
                    Email = u.Email,
                    Name = $"{u.FirstName} {u.LastName}",
                    TotalBookings = u.Bookings.Count(b => b.CreatedAt >= start && b.CreatedAt <= end),
                    TotalSpent = u.Bookings
                        .Where(b => b.CreatedAt >= start && b.CreatedAt <= end && b.Status == BookingStatus.Confirmed)
                        .Sum(b => (decimal?)b.TotalAmount) ?? 0,
                    LastBookingDate = u.Bookings
                        .Where(b => b.CreatedAt >= start && b.CreatedAt <= end)
                        .OrderByDescending(b => b.CreatedAt)
                        .Select(b => b.CreatedAt)
                        .FirstOrDefault()
                })
                .OrderByDescending(c => c.TotalSpent)
                .Take(limit)
                .ToListAsync();

            // Clientes nuevos vs recurrentes
            var newCustomers = await _context.Users
                .CountAsync(u => u.CreatedAt >= start && u.CreatedAt <= end);

            var returningCustomers = await _context.Users
                .CountAsync(u => u.CreatedAt < start && 
                                u.Bookings.Any(b => b.CreatedAt >= start && b.CreatedAt <= end));

            var result = new CustomersReportDto
            {
                Period = new DateRangeDto
                {
                    StartDate = start,
                    EndDate = end
                },
                TopCustomers = topCustomers,
                NewCustomers = newCustomers,
                ReturningCustomers = returningCustomers
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener reporte de clientes");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    // Helper methods
    private int GetWeekOfYear(DateTime date)
    {
        var culture = System.Globalization.CultureInfo.CurrentCulture;
        var calendar = culture.Calendar;
        return calendar.GetWeekOfYear(date, culture.DateTimeFormat.CalendarWeekRule, culture.DateTimeFormat.FirstDayOfWeek);
    }

    private DateTime GetFirstDayOfWeek(int year, int week)
    {
        var jan1 = new DateTime(year, 1, 1);
        var daysOffset = DayOfWeek.Thursday - jan1.DayOfWeek;
        var firstThursday = jan1.AddDays(daysOffset);
        var cal = System.Globalization.CultureInfo.CurrentCulture.Calendar;
        var firstWeek = cal.GetWeekOfYear(firstThursday, System.Globalization.CalendarWeekRule.FirstFourDayWeek, DayOfWeek.Monday);
        var weekNum = week;
        if (firstWeek <= 1)
        {
            weekNum -= 1;
        }
        var result = firstThursday.AddDays(weekNum * 7);
        return result.AddDays(-3);
    }
}

// DTOs
public class ReportsSummaryDto
{
    public DateRangeDto Period { get; set; } = new();
    public BookingsSummaryDto Bookings { get; set; } = new();
    public RevenueSummaryDto Revenue { get; set; } = new();
    public ToursSummaryDto Tours { get; set; } = new();
    public UsersSummaryDto Users { get; set; } = new();
    public decimal ConversionRate { get; set; }
}

public class DateRangeDto
{
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
}

public class BookingsSummaryDto
{
    public int Total { get; set; }
    public int Confirmed { get; set; }
    public int Pending { get; set; }
    public int Cancelled { get; set; }
}

public class RevenueSummaryDto
{
    public decimal Total { get; set; }
    public decimal AverageTicket { get; set; }
    public string Currency { get; set; } = "USD";
}

public class ToursSummaryDto
{
    public int Total { get; set; }
    public int Active { get; set; }
}

public class UsersSummaryDto
{
    public int Total { get; set; }
}

public class ToursReportDto
{
    public DateRangeDto Period { get; set; } = new();
    public List<TourSalesDto> TopSellingTours { get; set; } = new();
    public List<TourSalesDto> TopRevenueTours { get; set; } = new();
}

public class TourSalesDto
{
    public Guid TourId { get; set; }
    public string TourName { get; set; } = string.Empty;
    public int TotalBookings { get; set; }
    public decimal TotalRevenue { get; set; }
    public int TotalParticipants { get; set; }
}

public class TimeseriesReportDto
{
    public DateRangeDto Period { get; set; } = new();
    public string GroupBy { get; set; } = "day";
    public List<TimeseriesDataPointDto> DataPoints { get; set; } = new();
}

public class TimeseriesDataPointDto
{
    public DateTime Date { get; set; }
    public int Bookings { get; set; }
    public int ConfirmedBookings { get; set; }
    public decimal Revenue { get; set; }
}

public class CustomersReportDto
{
    public DateRangeDto Period { get; set; } = new();
    public List<CustomerStatsDto> TopCustomers { get; set; } = new();
    public int NewCustomers { get; set; }
    public int ReturningCustomers { get; set; }
}

public class CustomerStatsDto
{
    public Guid UserId { get; set; }
    public string Email { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public int TotalBookings { get; set; }
    public decimal TotalSpent { get; set; }
    public DateTime? LastBookingDate { get; set; }
}
