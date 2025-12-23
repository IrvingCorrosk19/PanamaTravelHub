using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Application.Exceptions;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Application.Validators;
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
            throw;
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
            throw;
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
                throw new NotFoundException("Tour", id);

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
            throw;
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
            var tour = await _context.Tours
                .Include(t => t.TourImages)
                .FirstOrDefaultAsync(t => t.Id == id);
            
            if (tour == null)
                throw new NotFoundException("Tour", id);

            // Actualizar campos (si se proporcionan valores, actualizar; si son null, mantener el valor actual)
            if (!string.IsNullOrWhiteSpace(request.Name))
                tour.Name = request.Name;
            
            if (!string.IsNullOrWhiteSpace(request.Description))
                tour.Description = request.Description;
            
            if (request.Itinerary != null)
                tour.Itinerary = request.Itinerary;
            
            if (request.Price.HasValue)
                tour.Price = request.Price.Value;
            
            if (request.MaxCapacity.HasValue)
            {
                var oldCapacity = tour.MaxCapacity;
                tour.MaxCapacity = request.MaxCapacity.Value;
                // Ajustar availableSpots si la capacidad cambió
                if (request.MaxCapacity.Value > oldCapacity)
                {
                    tour.AvailableSpots += (request.MaxCapacity.Value - oldCapacity);
                }
                else if (request.MaxCapacity.Value < oldCapacity)
                {
                    tour.AvailableSpots = Math.Max(0, tour.AvailableSpots - (oldCapacity - request.MaxCapacity.Value));
                }
            }
            
            if (request.DurationHours.HasValue)
                tour.DurationHours = request.DurationHours.Value;
            
            if (request.Location != null)
                tour.Location = request.Location;
            
            if (request.IsActive.HasValue)
                tour.IsActive = request.IsActive.Value;

            // Actualizar imágenes si se proporcionan
            if (request.Images != null)
            {
                // Eliminar imágenes existentes
                var existingImages = tour.TourImages.ToList();
                foreach (var img in existingImages)
                {
                    _context.TourImages.Remove(img);
                }

                // Agregar nuevas imágenes
                if (request.Images.Any())
                {
                    foreach (var imageUrl in request.Images)
                    {
                        var tourImage = new TourImage
                        {
                            TourId = tour.Id,
                            ImageUrl = imageUrl,
                            IsPrimary = request.Images.IndexOf(imageUrl) == 0 // Primera imagen es principal
                        };
                        _context.TourImages.Add(tourImage);
                    }
                }
            }

            await _tourRepository.UpdateAsync(tour);
            await _context.SaveChangesAsync();

            // Recargar imágenes
            await _context.Entry(tour)
                .Collection(t => t.TourImages)
                .LoadAsync();

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
            _logger.LogError(ex, "Error al actualizar tour {TourId}", id);
            throw;
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
                throw new NotFoundException("Tour", id);

            // Verificar que no tenga reservas activas
            var hasActiveBookings = await _context.Bookings
                .AnyAsync(b => b.TourId == id && 
                    (b.Status == Domain.Enums.BookingStatus.Pending || 
                     b.Status == Domain.Enums.BookingStatus.Confirmed));

            if (hasActiveBookings)
                throw new BusinessException("No se puede eliminar un tour con reservas activas", "TOUR_HAS_ACTIVE_BOOKINGS");

            tour.IsActive = false; // Soft delete
            await _tourRepository.UpdateAsync(tour);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Tour desactivado exitosamente" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al eliminar tour {TourId}", id);
            throw;
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
            throw;
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
            throw;
        }
    }

    /// <summary>
    /// Obtiene el contenido de la página de inicio
    /// </summary>
    [HttpGet("homepage-content")]
    public async Task<ActionResult<HomePageContentDto>> GetHomePageContent()
    {
        try
        {
            var content = await _context.HomePageContent.FirstOrDefaultAsync();
            
            if (content == null)
            {
                // Crear contenido por defecto si no existe
                content = new HomePageContent
                {
                    Id = Guid.NewGuid(),
                    CreatedAt = DateTime.UtcNow
                };
                _context.HomePageContent.Add(content);
                await _context.SaveChangesAsync();
            }

            var result = new HomePageContentDto
            {
                Id = content.Id,
                HeroTitle = content.HeroTitle,
                HeroSubtitle = content.HeroSubtitle,
                HeroSearchPlaceholder = content.HeroSearchPlaceholder,
                ToursSectionTitle = content.ToursSectionTitle,
                ToursSectionSubtitle = content.ToursSectionSubtitle,
                FooterBrandText = content.FooterBrandText,
                FooterDescription = content.FooterDescription,
                FooterCopyright = content.FooterCopyright,
                NavBrandText = content.NavBrandText,
                NavToursLink = content.NavToursLink,
                NavBookingsLink = content.NavBookingsLink,
                NavLoginLink = content.NavLoginLink,
                NavLogoutButton = content.NavLogoutButton,
                UpdatedAt = content.UpdatedAt
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener contenido de la página de inicio");
            throw;
        }
    }

    /// <summary>
    /// Actualiza el contenido de la página de inicio
    /// </summary>
    [HttpPut("homepage-content")]
    public async Task<ActionResult<HomePageContentDto>> UpdateHomePageContent([FromBody] UpdateHomePageContentDto request)
    {
        try
        {
            var content = await _context.HomePageContent.FirstOrDefaultAsync();
            
            if (content == null)
            {
                // Crear nuevo contenido si no existe
                content = new HomePageContent
                {
                    Id = Guid.NewGuid(),
                    CreatedAt = DateTime.UtcNow
                };
                _context.HomePageContent.Add(content);
            }

            // Actualizar campos
            if (!string.IsNullOrWhiteSpace(request.HeroTitle))
                content.HeroTitle = request.HeroTitle;
            
            if (!string.IsNullOrWhiteSpace(request.HeroSubtitle))
                content.HeroSubtitle = request.HeroSubtitle;
            
            if (!string.IsNullOrWhiteSpace(request.HeroSearchPlaceholder))
                content.HeroSearchPlaceholder = request.HeroSearchPlaceholder;
            
            if (!string.IsNullOrWhiteSpace(request.ToursSectionTitle))
                content.ToursSectionTitle = request.ToursSectionTitle;
            
            if (!string.IsNullOrWhiteSpace(request.ToursSectionSubtitle))
                content.ToursSectionSubtitle = request.ToursSectionSubtitle;
            
            if (!string.IsNullOrWhiteSpace(request.FooterBrandText))
                content.FooterBrandText = request.FooterBrandText;
            
            if (!string.IsNullOrWhiteSpace(request.FooterDescription))
                content.FooterDescription = request.FooterDescription;
            
            if (!string.IsNullOrWhiteSpace(request.FooterCopyright))
                content.FooterCopyright = request.FooterCopyright;
            
            if (!string.IsNullOrWhiteSpace(request.NavBrandText))
                content.NavBrandText = request.NavBrandText;
            
            if (!string.IsNullOrWhiteSpace(request.NavToursLink))
                content.NavToursLink = request.NavToursLink;
            
            if (!string.IsNullOrWhiteSpace(request.NavBookingsLink))
                content.NavBookingsLink = request.NavBookingsLink;
            
            if (!string.IsNullOrWhiteSpace(request.NavLoginLink))
                content.NavLoginLink = request.NavLoginLink;
            
            if (!string.IsNullOrWhiteSpace(request.NavLogoutButton))
                content.NavLogoutButton = request.NavLogoutButton;

            content.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            var result = new HomePageContentDto
            {
                Id = content.Id,
                HeroTitle = content.HeroTitle,
                HeroSubtitle = content.HeroSubtitle,
                HeroSearchPlaceholder = content.HeroSearchPlaceholder,
                ToursSectionTitle = content.ToursSectionTitle,
                ToursSectionSubtitle = content.ToursSectionSubtitle,
                FooterBrandText = content.FooterBrandText,
                FooterDescription = content.FooterDescription,
                FooterCopyright = content.FooterCopyright,
                NavBrandText = content.NavBrandText,
                NavToursLink = content.NavToursLink,
                NavBookingsLink = content.NavBookingsLink,
                NavLoginLink = content.NavLoginLink,
                NavLogoutButton = content.NavLogoutButton,
                UpdatedAt = content.UpdatedAt
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al actualizar contenido de la página de inicio");
            throw;
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

public class HomePageContentDto
{
    public Guid Id { get; set; }
    public string HeroTitle { get; set; } = string.Empty;
    public string HeroSubtitle { get; set; } = string.Empty;
    public string HeroSearchPlaceholder { get; set; } = string.Empty;
    public string ToursSectionTitle { get; set; } = string.Empty;
    public string ToursSectionSubtitle { get; set; } = string.Empty;
    public string FooterBrandText { get; set; } = string.Empty;
    public string FooterDescription { get; set; } = string.Empty;
    public string FooterCopyright { get; set; } = string.Empty;
    public string NavBrandText { get; set; } = string.Empty;
    public string NavToursLink { get; set; } = string.Empty;
    public string NavBookingsLink { get; set; } = string.Empty;
    public string NavLoginLink { get; set; } = string.Empty;
    public string NavLogoutButton { get; set; } = string.Empty;
    public DateTime? UpdatedAt { get; set; }
}

public class UpdateHomePageContentDto
{
    public string? HeroTitle { get; set; }
    public string? HeroSubtitle { get; set; }
    public string? HeroSearchPlaceholder { get; set; }
    public string? ToursSectionTitle { get; set; }
    public string? ToursSectionSubtitle { get; set; }
    public string? FooterBrandText { get; set; }
    public string? FooterDescription { get; set; }
    public string? FooterCopyright { get; set; }
    public string? NavBrandText { get; set; }
    public string? NavToursLink { get; set; }
    public string? NavBookingsLink { get; set; }
    public string? NavLoginLink { get; set; }
    public string? NavLogoutButton { get; set; }
}

