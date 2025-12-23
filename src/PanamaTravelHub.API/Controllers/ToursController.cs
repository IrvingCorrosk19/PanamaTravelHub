using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Application.Exceptions;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Infrastructure.Data;
using PanamaTravelHub.Infrastructure.Repositories;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ToursController : ControllerBase
{
    private readonly IRepository<Tour> _tourRepository;
    private readonly ApplicationDbContext _context;
    private readonly ILogger<ToursController> _logger;

    public ToursController(
        IRepository<Tour> tourRepository,
        ApplicationDbContext context,
        ILogger<ToursController> logger)
    {
        _tourRepository = tourRepository;
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Obtiene todos los tours disponibles
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<TourDto>>> GetTours()
    {
        try
        {
            // Obtener tours activos desde la base de datos
            var tours = await _context.Tours
                .Include(t => t.TourImages)
                .Where(t => t.IsActive)
                .OrderByDescending(t => t.CreatedAt)
                .ToListAsync();

            if (!tours.Any())
            {
                // Si no hay tours en BD, retornar datos mock como fallback
                var mockTours = new List<TourDto>
                {
                new TourDto
                {
                    Id = Guid.Parse("00000000-0000-0000-0000-000000000001"),
                    Name = "Tour del Canal de Panamá",
                    Description = "Descubre la maravilla de la ingeniería mundial. Visita las esclusas de Miraflores y aprende sobre la historia del canal.",
                    Price = 75.00m,
                    DurationHours = 4,
                    Location = "Ciudad de Panamá",
                    AvailableSpots = 15,
                    MaxCapacity = 20,
                    IsActive = true,
                    TourImages = new List<TourImageDto>
                    {
                        new TourImageDto
                        {
                            ImageUrl = "https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800",
                            IsPrimary = true
                        }
                    }
                },
                new TourDto
                {
                    Id = Guid.Parse("00000000-0000-0000-0000-000000000002"),
                    Name = "Casco Antiguo y Panamá Viejo",
                    Description = "Recorre la historia de Panamá visitando el Casco Antiguo colonial y las ruinas de Panamá Viejo, declaradas Patrimonio de la Humanidad.",
                    Price = 45.00m,
                    DurationHours = 3,
                    Location = "Casco Antiguo",
                    AvailableSpots = 8,
                    MaxCapacity = 15,
                    IsActive = true,
                    TourImages = new List<TourImageDto>
                    {
                        new TourImageDto
                        {
                            ImageUrl = "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800",
                            IsPrimary = true
                        }
                    }
                },
                new TourDto
                {
                    Id = Guid.Parse("00000000-0000-0000-0000-000000000003"),
                    Name = "Isla Taboga - Día Completo",
                    Description = "Escápate a la Isla de las Flores. Disfruta de playas paradisíacas, snorkel y la tranquilidad de este paraíso tropical.",
                    Price = 120.00m,
                    DurationHours = 8,
                    Location = "Isla Taboga",
                    AvailableSpots = 12,
                    MaxCapacity = 25,
                    IsActive = true,
                    TourImages = new List<TourImageDto>
                    {
                        new TourImageDto
                        {
                            ImageUrl = "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800",
                            IsPrimary = true
                        }
                    }
                },
                new TourDto
                {
                    Id = Guid.Parse("00000000-0000-0000-0000-000000000004"),
                    Name = "Tour Nocturno de la Ciudad",
                    Description = "Explora la ciudad de Panamá de noche. Disfruta de la vida nocturna, restaurantes y vistas panorámicas de la ciudad iluminada.",
                    Price = 65.00m,
                    DurationHours = 4,
                    Location = "Ciudad de Panamá",
                    AvailableSpots = 20,
                    MaxCapacity = 30,
                    IsActive = true,
                    TourImages = new List<TourImageDto>
                    {
                        new TourImageDto
                        {
                            ImageUrl = "https://images.unsplash.com/photo-1514565131-fce0801e5785?w=800",
                            IsPrimary = true
                        }
                    }
                },
                new TourDto
                {
                    Id = Guid.Parse("00000000-0000-0000-0000-000000000005"),
                    Name = "Rainforest Adventure - Gamboa",
                    Description = "Aventura en la naturaleza. Camina por senderos del bosque tropical, observa la fauna local y disfruta de la biodiversidad panameña.",
                    Price = 95.00m,
                    DurationHours = 6,
                    Location = "Gamboa",
                    AvailableSpots = 5,
                    MaxCapacity = 12,
                    IsActive = true,
                    TourImages = new List<TourImageDto>
                    {
                        new TourImageDto
                        {
                            ImageUrl = "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800",
                            IsPrimary = true
                        }
                    }
                },
                new TourDto
                {
                    Id = Guid.Parse("00000000-0000-0000-0000-000000000006"),
                    Name = "Tour Gastronómico Panameño",
                    Description = "Saborea la auténtica cocina panameña. Visita mercados locales, prueba platos tradicionales y aprende sobre la cultura culinaria.",
                    Price = 55.00m,
                    DurationHours = 3,
                    Location = "Ciudad de Panamá",
                    AvailableSpots = 18,
                    MaxCapacity = 20,
                    IsActive = true,
                    TourImages = new List<TourImageDto>
                    {
                        new TourImageDto
                        {
                            ImageUrl = "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800",
                            IsPrimary = true
                        }
                    }
                }
                };
                return Ok(mockTours);
            }

            // Convertir a DTOs
            var result = tours.Select(t => new TourDto
            {
                Id = t.Id,
                Name = t.Name,
                Description = t.Description,
                Price = t.Price,
                DurationHours = t.DurationHours,
                Location = t.Location,
                AvailableSpots = t.AvailableSpots,
                MaxCapacity = t.MaxCapacity,
                IsActive = t.IsActive,
                TourImages = t.TourImages.Select(i => new TourImageDto
                {
                    ImageUrl = i.ImageUrl,
                    IsPrimary = i.IsPrimary
                }).ToList()
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
    /// Obtiene un tour por ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<TourDto>> GetTour(Guid id)
    {
        try
        {
            var tour = await _context.Tours
                .Include(t => t.TourImages)
                .Include(t => t.TourDates)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (tour == null)
            {
                // Fallback a datos mock si no existe
                return Ok(new TourDto
                {
                    Id = id,
                    Name = "Tour del Canal de Panamá",
                    Description = "Descubre la maravilla de la ingeniería mundial. Visita las esclusas de Miraflores y aprende sobre la historia del canal que conecta dos océanos.",
                    Itinerary = "1. Recogida en hotel\n2. Visita al Centro de Visitantes de Miraflores\n3. Observación de barcos transitando\n4. Museo del Canal\n5. Regreso al hotel",
                    Price = 75.00m,
                    DurationHours = 4,
                    Location = "Ciudad de Panamá",
                    AvailableSpots = 15,
                    MaxCapacity = 20,
                    IsActive = true,
                    TourImages = new List<TourImageDto>
                    {
                        new TourImageDto
                        {
                            ImageUrl = "https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=1200",
                            IsPrimary = true
                        }
                    }
                });
            }

            var result = new TourDto
            {
                Id = tour.Id,
                Name = tour.Name,
                Description = tour.Description,
                Itinerary = tour.Itinerary,
                Price = tour.Price,
                DurationHours = tour.DurationHours,
                Location = tour.Location,
                AvailableSpots = tour.AvailableSpots,
                MaxCapacity = tour.MaxCapacity,
                IsActive = tour.IsActive,
                TourImages = tour.TourImages.Select(i => new TourImageDto
                {
                    ImageUrl = i.ImageUrl,
                    IsPrimary = i.IsPrimary
                }).ToList()
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener tour {TourId}", id);
            throw;
        }
    }
}

// DTOs temporales hasta que se implemente la capa Application
public class TourDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? Itinerary { get; set; }
    public decimal Price { get; set; }
    public int DurationHours { get; set; }
    public string? Location { get; set; }
    public int AvailableSpots { get; set; }
    public int MaxCapacity { get; set; }
    public bool IsActive { get; set; }
    public List<TourImageDto> TourImages { get; set; } = new();
}

public class TourImageDto
{
    public string ImageUrl { get; set; } = string.Empty;
    public bool IsPrimary { get; set; }
}
