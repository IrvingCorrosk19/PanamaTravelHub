using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PanamaTravelHub.Application.Exceptions;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Application.Validators;
using PanamaTravelHub.Domain.Enums;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BookingsController : ControllerBase
{
    private readonly IBookingService _bookingService;
    private readonly ILogger<BookingsController> _logger;

    public BookingsController(
        IBookingService bookingService,
        ILogger<BookingsController> logger)
    {
        _bookingService = bookingService;
        _logger = logger;
    }

    /// <summary>
    /// Obtiene las reservas del usuario actual
    /// </summary>
    [HttpGet("my")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult<IEnumerable<BookingResponseDto>>> GetMyBookings()
    {
        try
        {
            // Obtener userId del token JWT
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var actualUserId))
            {
                return Unauthorized(new { message = "Usuario no autenticado" });
            }

            var bookings = await _bookingService.GetUserBookingsAsync(actualUserId);

            var result = bookings.Select(b => new BookingResponseDto
            {
                Id = b.Id,
                TourId = b.TourId,
                TourName = b.Tour.Name,
                NumberOfParticipants = b.NumberOfParticipants,
                TotalAmount = b.TotalAmount,
                Status = b.Status.ToString(),
                TourDate = b.TourDate?.TourDateTime,
                CreatedAt = b.CreatedAt
            });

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener reservas");
            throw;
        }
    }

    /// <summary>
    /// Obtiene todas las reservas (Admin)
    /// </summary>
    [HttpGet]
    [Authorize(Policy = "AdminOnly")]
    public async Task<ActionResult<IEnumerable<BookingResponseDto>>> GetAllBookings()
    {
        var bookings = await _bookingService.GetAllBookingsAsync();

        var result = bookings.Select(b => new BookingResponseDto
        {
            Id = b.Id,
            TourId = b.TourId,
            TourName = b.Tour.Name,
            UserId = b.UserId,
            UserEmail = b.User.Email,
            UserName = $"{b.User.FirstName} {b.User.LastName}",
            NumberOfParticipants = b.NumberOfParticipants,
            TotalAmount = b.TotalAmount,
            Status = b.Status.ToString(),
            TourDate = b.TourDate?.TourDateTime,
            CreatedAt = b.CreatedAt
        });

        return Ok(result);
    }

    /// <summary>
    /// Obtiene una reserva por ID
    /// </summary>
    [HttpGet("{id}")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult<BookingDetailResponseDto>> GetBooking(Guid id)
    {
        var booking = await _bookingService.GetBookingByIdAsync(id);
        if (booking == null)
            throw new NotFoundException("Reserva", id);

        // Verificar que el usuario sea el dueño de la reserva o admin
        var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                         User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var currentUserId))
        {
            return Unauthorized(new { message = "Usuario no autenticado" });
        }

        // Verificar propiedad o rol admin
        if (booking.UserId != currentUserId && !User.IsInRole("Admin"))
        {
            return StatusCode(403, new { message = "No tienes permisos para ver esta reserva" });
        }

        var result = new BookingDetailResponseDto
            {
                Id = booking.Id,
                TourId = booking.TourId,
                TourName = booking.Tour.Name,
                UserId = booking.UserId,
                UserEmail = booking.User.Email,
                UserName = $"{booking.User.FirstName} {booking.User.LastName}",
                NumberOfParticipants = booking.NumberOfParticipants,
                TotalAmount = booking.TotalAmount,
                Status = booking.Status.ToString(),
                TourDate = booking.TourDate?.TourDateTime,
                CreatedAt = booking.CreatedAt,
                ExpiresAt = booking.ExpiresAt,
                Notes = booking.Notes,
                Participants = booking.Participants.Select(p => new ParticipantDto
                {
                    FirstName = p.FirstName,
                    LastName = p.LastName,
                    Email = p.Email,
                    Phone = p.Phone,
                    DateOfBirth = p.DateOfBirth
                }).ToList()
            };

        return Ok(result);
    }

    /// <summary>
    /// Crea una nueva reserva
    /// </summary>
    [HttpPost]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult<BookingResponseDto>> CreateBooking([FromBody] CreateBookingRequestDto request)
    {
        // La validación se hace automáticamente por FluentValidation
        // Obtener userId del token JWT
        var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                         User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized(new { message = "Usuario no autenticado. Debes iniciar sesión para realizar una reserva." });
        }

        // Si viene userId en el request, validar que coincida con el del token (solo admin puede crear para otros)
        if (request.UserId.HasValue && request.UserId.Value != Guid.Empty)
        {
            if (request.UserId.Value != userId && !User.IsInRole("Admin"))
            {
                return StatusCode(403, new { message = "No puedes crear reservas para otros usuarios" });
            }
            userId = request.UserId.Value;
        }

        // Convertir participantes
        var participants = request.Participants.Select(p => new BookingParticipantInfo
        {
            FirstName = p.FirstName,
            LastName = p.LastName,
            Email = p.Email,
            Phone = p.Phone,
            DateOfBirth = p.DateOfBirth
        }).ToList();

        // Crear reserva
        var booking = await _bookingService.CreateBookingAsync(
            userId,
            request.TourId,
            request.TourDateId,
            request.NumberOfParticipants,
            participants,
            request.CountryId);

        var result = new BookingResponseDto
        {
            Id = booking.Id,
            TourId = booking.TourId,
            TourName = booking.Tour.Name,
            NumberOfParticipants = booking.NumberOfParticipants,
            TotalAmount = booking.TotalAmount,
            Status = booking.Status.ToString(),
            TourDate = booking.TourDate?.TourDateTime,
            CreatedAt = booking.CreatedAt
        };

        return CreatedAtAction(nameof(GetBooking), new { id = booking.Id }, result);
    }

    /// <summary>
    /// Confirma una reserva (Admin)
    /// </summary>
    [HttpPost("{id}/confirm")]
    [Authorize(Policy = "AdminOnly")]
    public async Task<ActionResult> ConfirmBooking(Guid id)
    {
        var success = await _bookingService.ConfirmBookingAsync(id);
        if (!success)
            throw new BusinessException("No se pudo confirmar la reserva. Verifica que la reserva esté en estado Pending.", "CANNOT_CONFIRM_BOOKING");

        return Ok(new { message = "Reserva confirmada exitosamente" });
    }

    /// <summary>
    /// Cancela una reserva
    /// </summary>
    [HttpPost("{id}/cancel")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult> CancelBooking(Guid id)
    {
        // Verificar que el usuario sea el dueño de la reserva o admin
        var booking = await _bookingService.GetBookingByIdAsync(id);
        if (booking == null)
            throw new NotFoundException("Reserva", id);

        var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                         User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var currentUserId))
        {
            return Unauthorized(new { message = "Usuario no autenticado" });
        }

        // Verificar propiedad o rol admin
        if (booking.UserId != currentUserId && !User.IsInRole("Admin"))
        {
            return StatusCode(403, new { message = "No tienes permisos para cancelar esta reserva" });
        }

        var success = await _bookingService.CancelBookingAsync(id);
        if (!success)
            throw new BusinessException("No se pudo cancelar la reserva. Verifica que la reserva no esté completada o ya cancelada.", "CANNOT_CANCEL_BOOKING");

        return Ok(new { message = "Reserva cancelada exitosamente" });
    }
}

// DTOs
// CreateBookingRequestDto y ParticipantRequestDto están definidos en PanamaTravelHub.Application.Validators

public class ParticipantRequestDto
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? Email { get; set; }
    public string? Phone { get; set; }
    public DateTime? DateOfBirth { get; set; }
}

public class BookingResponseDto
{
    public Guid Id { get; set; }
    public Guid TourId { get; set; }
    public string TourName { get; set; } = string.Empty;
    public Guid? UserId { get; set; }
    public string? UserEmail { get; set; }
    public string? UserName { get; set; }
    public int NumberOfParticipants { get; set; }
    public decimal TotalAmount { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime? TourDate { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class BookingDetailResponseDto : BookingResponseDto
{
    public DateTime? ExpiresAt { get; set; }
    public string? Notes { get; set; }
    public List<ParticipantDto> Participants { get; set; } = new();
}

public class ParticipantDto
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? Email { get; set; }
    public string? Phone { get; set; }
    public DateTime? DateOfBirth { get; set; }
}
