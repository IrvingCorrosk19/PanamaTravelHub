using Microsoft.AspNetCore.Mvc;
using PanamaTravelHub.Application.Exceptions;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Application.Validators;
using PanamaTravelHub.Domain.Enums;

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
    public async Task<ActionResult<IEnumerable<BookingResponseDto>>> GetMyBookings([FromQuery] Guid? userId = null)
    {
        try
        {
            // Obtener userId del query parameter o usar el hardcodeado como fallback
            Guid actualUserId;
            if (userId.HasValue && userId.Value != Guid.Empty)
            {
                actualUserId = userId.Value;
            }
            else
            {
                // TODO: Obtener userId del token JWT cuando la autenticación esté implementada
                // Por ahora usar un GUID mock para testing
                actualUserId = Guid.Parse("00000000-0000-0000-0000-000000000001");
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
    public async Task<ActionResult<IEnumerable<BookingResponseDto>>> GetAllBookings()
    {
        // TODO: Verificar que el usuario sea admin
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
    public async Task<ActionResult<BookingDetailResponseDto>> GetBooking(Guid id)
    {
        var booking = await _bookingService.GetBookingByIdAsync(id);
        if (booking == null)
            throw new NotFoundException("Reserva", id);

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
    public async Task<ActionResult<BookingResponseDto>> CreateBooking([FromBody] CreateBookingRequestDto request)
    {
        // La validación se hace automáticamente por FluentValidation
        // Obtener userId del request o usar el del body si está disponible
        Guid userId;
        if (request.UserId.HasValue && request.UserId.Value != Guid.Empty)
        {
            userId = request.UserId.Value;
        }
        else
        {
            // TODO: Obtener userId del token JWT cuando la autenticación esté implementada
            // Por ahora, si no viene en el request, lanzar error
            throw new BusinessException("Usuario no autenticado. Debes iniciar sesión para realizar una reserva.", "USER_NOT_AUTHENTICATED");
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
            participants);

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
    public async Task<ActionResult> ConfirmBooking(Guid id)
    {
        // TODO: Verificar que el usuario sea admin
        var success = await _bookingService.ConfirmBookingAsync(id);
        if (!success)
            throw new BusinessException("No se pudo confirmar la reserva. Verifica que la reserva esté en estado Pending.", "CANNOT_CONFIRM_BOOKING");

        return Ok(new { message = "Reserva confirmada exitosamente" });
    }

    /// <summary>
    /// Cancela una reserva
    /// </summary>
    [HttpPost("{id}/cancel")]
    public async Task<ActionResult> CancelBooking(Guid id)
    {
        var success = await _bookingService.CancelBookingAsync(id);
        if (!success)
            throw new BusinessException("No se pudo cancelar la reserva. Verifica que la reserva no esté completada o ya cancelada.", "CANNOT_CANCEL_BOOKING");

        return Ok(new { message = "Reserva cancelada exitosamente" });
    }
}

// DTOs
public class CreateBookingRequestDto
{
    public Guid? UserId { get; set; }
    public Guid TourId { get; set; }
    public Guid? TourDateId { get; set; }
    public int NumberOfParticipants { get; set; }
    public List<ParticipantRequestDto> Participants { get; set; } = new();
}

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
