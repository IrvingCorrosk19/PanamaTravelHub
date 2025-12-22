using Microsoft.AspNetCore.Mvc;
using PanamaTravelHub.Application.Services;
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
    public async Task<ActionResult<IEnumerable<BookingResponseDto>>> GetMyBookings()
    {
        try
        {
            // TODO: Obtener userId del token JWT
            // Por ahora usamos un GUID mock para testing
            var userId = Guid.Parse("00000000-0000-0000-0000-000000000001");

            var bookings = await _bookingService.GetUserBookingsAsync(userId);

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
            return StatusCode(500, new { message = "Error al obtener las reservas" });
        }
    }

    /// <summary>
    /// Obtiene todas las reservas (Admin)
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<BookingResponseDto>>> GetAllBookings()
    {
        try
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
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener reservas");
            return StatusCode(500, new { message = "Error al obtener las reservas" });
        }
    }

    /// <summary>
    /// Obtiene una reserva por ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<BookingDetailResponseDto>> GetBooking(Guid id)
    {
        try
        {
            var booking = await _bookingService.GetBookingByIdAsync(id);
            if (booking == null)
                return NotFound(new { message = "Reserva no encontrada" });

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
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener reserva {BookingId}", id);
            return StatusCode(500, new { message = "Error al obtener la reserva" });
        }
    }

    /// <summary>
    /// Crea una nueva reserva
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<BookingResponseDto>> CreateBooking([FromBody] CreateBookingRequestDto request)
    {
        try
        {
            // TODO: Obtener userId del token JWT
            var userId = Guid.Parse("00000000-0000-0000-0000-000000000001");

            // Validaciones
            if (request.NumberOfParticipants <= 0)
                return BadRequest(new { message = "El número de participantes debe ser mayor a 0" });

            if (request.Participants == null || request.Participants.Count != request.NumberOfParticipants)
                return BadRequest(new { message = "El número de participantes no coincide con la lista proporcionada" });

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
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear reserva");
            return StatusCode(500, new { message = "Error al crear la reserva" });
        }
    }

    /// <summary>
    /// Confirma una reserva (Admin)
    /// </summary>
    [HttpPost("{id}/confirm")]
    public async Task<ActionResult> ConfirmBooking(Guid id)
    {
        try
        {
            // TODO: Verificar que el usuario sea admin
            var success = await _bookingService.ConfirmBookingAsync(id);
            if (!success)
                return BadRequest(new { message = "No se pudo confirmar la reserva" });

            return Ok(new { message = "Reserva confirmada exitosamente" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al confirmar reserva {BookingId}", id);
            return StatusCode(500, new { message = "Error al confirmar la reserva" });
        }
    }

    /// <summary>
    /// Cancela una reserva
    /// </summary>
    [HttpPost("{id}/cancel")]
    public async Task<ActionResult> CancelBooking(Guid id)
    {
        try
        {
            var success = await _bookingService.CancelBookingAsync(id);
            if (!success)
                return BadRequest(new { message = "No se pudo cancelar la reserva" });

            return Ok(new { message = "Reserva cancelada exitosamente" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al cancelar reserva {BookingId}", id);
            return StatusCode(500, new { message = "Error al cancelar la reserva" });
        }
    }
}

// DTOs
public class CreateBookingRequestDto
{
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
