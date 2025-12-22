using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Infrastructure.Data;
using PanamaTravelHub.Infrastructure.Repositories;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/admin")]
public class AdminController : ControllerBase
{
    private readonly IRepository<Tour> _tourRepository;
    private readonly IRepository<Booking> _bookingRepository;
    private readonly IRepository<User> _userRepository;
    private readonly IBookingService _bookingService;
    private readonly ApplicationDbContext _context;
    private readonly ILogger<AdminController> _logger;

    public AdminController(
        IRepository<Tour> tourRepository,
        IRepository<Booking> bookingRepository,
        IRepository<User> userRepository,
        IBookingService bookingService,
        ApplicationDbContext context,
        ILogger<AdminController> logger)
    {
        _tourRepository = tourRepository;
        _bookingRepository = bookingRepository;
        _userRepository = userRepository;
        _bookingService = bookingService;
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Obtiene todos los tours (Admin)
    /// </summary>
    [HttpGet("tours")]
    public async Task<ActionResult<IEnumerable<AdminTourDto>>> GetTours()
    {
        try
        {
            // TODO: Verificar que el usuario sea admin
            var tours = await _context.Tours
                .Include(t => t.TourImages)
                .Include(t => t.TourDates)
                .OrderByDescending(t => t.CreatedAt)
                .ToListAsync();

            var result = tours.Select(t => new AdminTourDto
            {
                Id = t.Id,
                Name = t.Name,
                Description = t.Description,
                Price = t.Price,
                MaxCapacity = t.MaxCapacity,
                AvailableSpots = t.AvailableSpots,
                DurationHours = t.DurationHours,
                Location = t.Location,
                IsActive = t.IsActive,
                CreatedAt = t.CreatedAt,
                ImageUrl = t.TourImages.FirstOrDefault(i => i.IsPrimary)?.ImageUrl
            });

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener tours");
            return StatusCode(500, new { message = "Error al obtener los tours" });
        }
    }

    /// <summary>
    /// Crea un nuevo tour (Admin)
    /// </summary>
    [HttpPost("tours")]
    public async Task<ActionResult<AdminTourDto>> CreateTour([FromBody] CreateTourRequestDto request)
    {
        try
        {
            // TODO: Verificar que el usuario sea admin
            var tour = new Tour
            {
                Name = request.Name,
                Description = request.Description,
                Itinerary = request.Itinerary,
                Price = request.Price,
                MaxCapacity = request.MaxCapacity,
                AvailableSpots = request.MaxCapacity, // Inicialmente todos los cupos están disponibles
                DurationHours = request.DurationHours,
                Location = request.Location,
                IsActive = request.IsActive ?? true
            };

            await _tourRepository.AddAsync(tour);

            // Agregar imágenes
            if (request.Images != null && request.Images.Any())
            {
                foreach (var imageUrl in request.Images)
                {
                    var tourImage = new TourImage
                    {
                        TourId = tour.Id,
                        ImageUrl = imageUrl,
                        IsPrimary = request.Images.IndexOf(imageUrl) == 0
                    };
                    _context.TourImages.Add(tourImage);
                }
            }

            await _context.SaveChangesAsync();

            // Cargar imágenes
            await _context.Entry(tour)
                .Collection(t => t.TourImages)
                .LoadAsync();

            var result = new AdminTourDto
            {
                Id = tour.Id,
                Name = tour.Name,
                Description = tour.Description,
                Price = tour.Price,
                MaxCapacity = tour.MaxCapacity,
                AvailableSpots = tour.AvailableSpots,
                DurationHours = tour.DurationHours,
                Location = tour.Location,
                IsActive = tour.IsActive,
                CreatedAt = tour.CreatedAt,
                ImageUrl = tour.TourImages.FirstOrDefault(i => i.IsPrimary)?.ImageUrl
            };

            return CreatedAtAction(nameof(GetTour), new { id = tour.Id }, result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear tour");
            return StatusCode(500, new { message = "Error al crear el tour" });
        }
    }

    /// <summary>
    /// Obtiene un tour por ID (Admin)
    /// </summary>
    [HttpGet("tours/{id}")]
    public async Task<ActionResult<AdminTourDto>> GetTour(Guid id)
    {
        try
        {
            var tour = await _context.Tours
                .Include(t => t.TourImages)
                .Include(t => t.TourDates)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (tour == null)
                return NotFound(new { message = "Tour no encontrado" });

            var result = new AdminTourDto
            {
                Id = tour.Id,
                Name = tour.Name,
                Description = tour.Description,
                Itinerary = tour.Itinerary,
                Price = tour.Price,
                MaxCapacity = tour.MaxCapacity,
                AvailableSpots = tour.AvailableSpots,
                DurationHours = tour.DurationHours,
                Location = tour.Location,
                IsActive = tour.IsActive,
                CreatedAt = tour.CreatedAt,
                ImageUrl = tour.TourImages.FirstOrDefault(i => i.IsPrimary)?.ImageUrl,
                Images = tour.TourImages.Select(i => i.ImageUrl).ToList()
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener tour {TourId}", id);
            return StatusCode(500, new { message = "Error al obtener el tour" });
        }
    }

    /// <summary>
    /// Actualiza un tour (Admin)
    /// </summary>
    [HttpPut("tours/{id}")]
    public async Task<ActionResult<AdminTourDto>> UpdateTour(Guid id, [FromBody] UpdateTourRequestDto request)
    {
        try
        {
            var tour = await _tourRepository.GetByIdAsync(id);
            if (tour == null)
                return NotFound(new { message = "Tour no encontrado" });

            tour.Name = request.Name ?? tour.Name;
            tour.Description = request.Description ?? tour.Description;
            tour.Itinerary = request.Itinerary ?? tour.Itinerary;
            tour.Price = request.Price ?? tour.Price;
            tour.MaxCapacity = request.MaxCapacity ?? tour.MaxCapacity;
            tour.DurationHours = request.DurationHours ?? tour.DurationHours;
            tour.Location = request.Location ?? tour.Location;
            if (request.IsActive.HasValue)
                tour.IsActive = request.IsActive.Value;

            await _tourRepository.UpdateAsync(tour);
            await _context.SaveChangesAsync();

            // Cargar imágenes
            await _context.Entry(tour)
                .Collection(t => t.TourImages)
                .LoadAsync();

            var result = new AdminTourDto
            {
                Id = tour.Id,
                Name = tour.Name,
                Description = tour.Description,
                Price = tour.Price,
                MaxCapacity = tour.MaxCapacity,
                AvailableSpots = tour.AvailableSpots,
                DurationHours = tour.DurationHours,
                Location = tour.Location,
                IsActive = tour.IsActive,
                CreatedAt = tour.CreatedAt,
                ImageUrl = tour.TourImages.FirstOrDefault(i => i.IsPrimary)?.ImageUrl
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al actualizar tour {TourId}", id);
            return StatusCode(500, new { message = "Error al actualizar el tour" });
        }
    }

    /// <summary>
    /// Elimina un tour (Admin)
    /// </summary>
    [HttpDelete("tours/{id}")]
    public async Task<ActionResult> DeleteTour(Guid id)
    {
        try
        {
            var tour = await _tourRepository.GetByIdAsync(id);
            if (tour == null)
                return NotFound(new { message = "Tour no encontrado" });

            // Verificar que no tenga reservas activas
            var hasActiveBookings = await _context.Bookings
                .AnyAsync(b => b.TourId == id && 
                    (b.Status == Domain.Enums.BookingStatus.Pending || 
                     b.Status == Domain.Enums.BookingStatus.Confirmed));

            if (hasActiveBookings)
                return BadRequest(new { message = "No se puede eliminar un tour con reservas activas" });

            tour.IsActive = false; // Soft delete
            await _tourRepository.UpdateAsync(tour);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Tour desactivado exitosamente" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al eliminar tour {TourId}", id);
            return StatusCode(500, new { message = "Error al eliminar el tour" });
        }
    }

    /// <summary>
    /// Obtiene todas las reservas (Admin)
    /// </summary>
    [HttpGet("bookings")]
    public async Task<ActionResult<IEnumerable<AdminBookingDto>>> GetBookings()
    {
        try
        {
            var bookings = await _bookingService.GetAllBookingsAsync();

            var result = bookings.Select(b => new AdminBookingDto
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
                CreatedAt = b.CreatedAt,
                ExpiresAt = b.ExpiresAt
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
    /// Obtiene estadísticas (Admin)
    /// </summary>
    [HttpGet("stats")]
    public async Task<ActionResult<AdminStatsDto>> GetStats()
    {
        try
        {
            var totalTours = await _context.Tours.CountAsync();
            var activeTours = await _context.Tours.CountAsync(t => t.IsActive);
            var totalBookings = await _context.Bookings.CountAsync();
            var pendingBookings = await _context.Bookings.CountAsync(b => b.Status == Domain.Enums.BookingStatus.Pending);
            var confirmedBookings = await _context.Bookings.CountAsync(b => b.Status == Domain.Enums.BookingStatus.Confirmed);
            var totalUsers = await _context.Users.CountAsync();
            var totalRevenue = await _context.Bookings
                .Where(b => b.Status == Domain.Enums.BookingStatus.Confirmed)
                .SumAsync(b => (decimal?)b.TotalAmount) ?? 0;

            var stats = new AdminStatsDto
            {
                TotalTours = totalTours,
                ActiveTours = activeTours,
                TotalBookings = totalBookings,
                PendingBookings = pendingBookings,
                ConfirmedBookings = confirmedBookings,
                TotalUsers = totalUsers,
                TotalRevenue = totalRevenue
            };

            return Ok(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener estadísticas");
            return StatusCode(500, new { message = "Error al obtener las estadísticas" });
        }
    }
}

// DTOs
public class AdminTourDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? Itinerary { get; set; }
    public decimal Price { get; set; }
    public int MaxCapacity { get; set; }
    public int AvailableSpots { get; set; }
    public int DurationHours { get; set; }
    public string? Location { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public string? ImageUrl { get; set; }
    public List<string>? Images { get; set; }
}

public class CreateTourRequestDto
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? Itinerary { get; set; }
    public decimal Price { get; set; }
    public int MaxCapacity { get; set; }
    public int DurationHours { get; set; }
    public string? Location { get; set; }
    public bool? IsActive { get; set; }
    public List<string>? Images { get; set; }
}

public class UpdateTourRequestDto
{
    public string? Name { get; set; }
    public string? Description { get; set; }
    public string? Itinerary { get; set; }
    public decimal? Price { get; set; }
    public int? MaxCapacity { get; set; }
    public int? DurationHours { get; set; }
    public string? Location { get; set; }
    public bool? IsActive { get; set; }
}

public class AdminBookingDto
{
    public Guid Id { get; set; }
    public Guid TourId { get; set; }
    public string TourName { get; set; } = string.Empty;
    public Guid UserId { get; set; }
    public string UserEmail { get; set; } = string.Empty;
    public string UserName { get; set; } = string.Empty;
    public int NumberOfParticipants { get; set; }
    public decimal TotalAmount { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime? TourDate { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ExpiresAt { get; set; }
}

public class AdminStatsDto
{
    public int TotalTours { get; set; }
    public int ActiveTours { get; set; }
    public int TotalBookings { get; set; }
    public int PendingBookings { get; set; }
    public int ConfirmedBookings { get; set; }
    public int TotalUsers { get; set; }
    public decimal TotalRevenue { get; set; }
}

