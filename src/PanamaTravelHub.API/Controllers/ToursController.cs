using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Application.Exceptions;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Domain.Enums;
using PanamaTravelHub.Infrastructure.Data;
using PanamaTravelHub.Infrastructure.Repositories;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

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
    /// Obtiene todos los tours disponibles con búsqueda y filtros avanzados
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<TourDto>>> GetTours(
        [FromQuery] string? search = null,
        [FromQuery] decimal? minPrice = null,
        [FromQuery] decimal? maxPrice = null,
        [FromQuery] int? minDuration = null,
        [FromQuery] int? maxDuration = null,
        [FromQuery] string? location = null,
        [FromQuery] string? category = null,
        [FromQuery] string? sortBy = "created", // created, price, duration, name
        [FromQuery] string? sortOrder = "desc") // asc, desc
    {
        try
        {
            _logger.LogInformation("=== INICIO GetTours ===");
            
            // Obtener tours activos desde la base de datos
            _logger.LogInformation("Consultando tours activos desde la base de datos...");
            var query = _context.Tours
                .Include(t => t.TourImages)
                .Where(t => t.IsActive);

            // Búsqueda por texto
            if (!string.IsNullOrWhiteSpace(search))
            {
                var searchLower = search.ToLower();
                query = query.Where(t => 
                    t.Name.ToLower().Contains(searchLower) ||
                    (t.Description != null && t.Description.ToLower().Contains(searchLower)) ||
                    (t.Location != null && t.Location.ToLower().Contains(searchLower)));
            }

            // Filtro por precio
            if (minPrice.HasValue)
            {
                query = query.Where(t => t.Price >= minPrice.Value);
            }
            if (maxPrice.HasValue)
            {
                query = query.Where(t => t.Price <= maxPrice.Value);
            }

            // Filtro por duración
            if (minDuration.HasValue)
            {
                query = query.Where(t => t.DurationHours >= minDuration.Value);
            }
            if (maxDuration.HasValue)
            {
                query = query.Where(t => t.DurationHours <= maxDuration.Value);
            }

            // Filtro por ubicación
            if (!string.IsNullOrWhiteSpace(location))
            {
                var locationLower = location.ToLower();
                query = query.Where(t => t.Location != null && t.Location.ToLower().Contains(locationLower));
            }

            // TODO: Filtro por categoría (cuando se implemente el sistema de categorías)
            // if (!string.IsNullOrWhiteSpace(category))
            // {
            //     query = query.Where(t => t.Category == category);
            // }

            // Ordenamiento
            query = sortBy.ToLower() switch
            {
                "price" => sortOrder.ToLower() == "asc" 
                    ? query.OrderBy(t => t.Price)
                    : query.OrderByDescending(t => t.Price),
                "duration" => sortOrder.ToLower() == "asc"
                    ? query.OrderBy(t => t.DurationHours)
                    : query.OrderByDescending(t => t.DurationHours),
                "name" => sortOrder.ToLower() == "asc"
                    ? query.OrderBy(t => t.Name)
                    : query.OrderByDescending(t => t.Name),
                _ => sortOrder.ToLower() == "asc"
                    ? query.OrderBy(t => t.CreatedAt)
                    : query.OrderByDescending(t => t.CreatedAt)
            };

            var tours = await query.ToListAsync();

            _logger.LogInformation("Tours encontrados en BD: {Count}", tours.Count);

            if (!tours.Any())
            {
                _logger.LogWarning("No se encontraron tours en BD, usando datos mock como fallback");
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
                _logger.LogInformation("Retornando {Count} tours mock", mockTours.Count);
                return Ok(mockTours);
            }

            // Convertir a DTOs
            _logger.LogInformation("Convirtiendo {Count} tours a DTOs...", tours.Count);
            var result = tours.Select(t => new TourDto
            {
                Id = t.Id,
                Name = t.Name ?? string.Empty,
                Description = t.Description ?? string.Empty,
                Itinerary = t.Itinerary,
                Includes = t.Includes,
                Price = t.Price >= 0 ? t.Price : 0, // Garantizar precio válido (nunca null ni negativo)
                DurationHours = t.DurationHours,
                Location = t.Location ?? string.Empty,
                TourDate = t.TourDate,
                AvailableSpots = t.AvailableSpots,
                MaxCapacity = t.MaxCapacity,
                IsActive = t.IsActive,
                TourImages = t.TourImages.Select(i => new TourImageDto
                {
                    ImageUrl = i.ImageUrl ?? string.Empty,
                    IsPrimary = i.IsPrimary
                }).ToList()
            }).ToList();

            _logger.LogInformation("Tours convertidos: {Count}", result.Count);
            foreach (var tour in result)
            {
                _logger.LogInformation("Tour: {Name} (ID: {Id}), Precio: {Price}, Imágenes: {ImageCount}", 
                    tour.Name, tour.Id, tour.Price, tour.TourImages?.Count ?? 0);
            }

            _logger.LogInformation("=== FIN GetTours - Retornando {Count} tours ===", result.Count);
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
                Includes = tour.Includes,
                Price = tour.Price,
                DurationHours = tour.DurationHours,
                Location = tour.Location,
                TourDate = tour.TourDate,
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

    /// <summary>
    /// Obtiene el contenido de la página de inicio (público)
    /// </summary>
    [HttpGet("homepage-content")]
    public async Task<ActionResult<HomePageContentPublicDto>> GetHomePageContent()
    {
        try
        {
            var content = await _context.HomePageContent.FirstOrDefaultAsync();
            
            if (content == null)
            {
                // Retornar valores por defecto si no existe
                return Ok(new HomePageContentPublicDto
                {
                    HeroTitle = "Descubre Panamá",
                    HeroSubtitle = "Explora los destinos más increíbles con nuestros tours exclusivos",
                    HeroSearchPlaceholder = "Buscar tours...",
                    ToursSectionTitle = "Tours Disponibles",
                    ToursSectionSubtitle = "Selecciona tu próxima aventura",
                    FooterBrandText = "ToursPanama",
                    FooterDescription = "Tu plataforma de confianza para descubrir Panamá",
                    FooterCopyright = "© 2024 ToursPanama. Todos los derechos reservados.",
                    NavBrandText = "ToursPanama",
                    NavToursLink = "Tours",
                    NavBookingsLink = "Mis Reservas",
                    NavLoginLink = "Iniciar Sesión",
                    NavLogoutButton = "Cerrar Sesión",
                    HeroSearchButton = "Buscar",
                    LoadingToursText = "Cargando tours...",
                    ErrorLoadingToursText = "Error al cargar los tours. Por favor, intenta de nuevo.",
                    NoToursFoundText = "No se encontraron tours disponibles.",
                    PageTitle = "ToursPanama — Descubre los Mejores Tours en Panamá",
                    MetaDescription = "Plataforma moderna de reservas de tours en Panamá. Explora, reserva y disfruta de las mejores experiencias turísticas.",
                    LogoUrl = null,
                    FaviconUrl = null,
                    LogoUrlSocial = null,
                    HeroImageUrl = null
                });
            }

            var result = new HomePageContentPublicDto
            {
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
                HeroSearchButton = content.HeroSearchButton,
                LoadingToursText = content.LoadingToursText,
                ErrorLoadingToursText = content.ErrorLoadingToursText,
                NoToursFoundText = content.NoToursFoundText,
                PageTitle = content.PageTitle,
                MetaDescription = content.MetaDescription,
                LogoUrl = content.LogoUrl,
                FaviconUrl = content.FaviconUrl,
                LogoUrlSocial = content.LogoUrlSocial,
                HeroImageUrl = content.HeroImageUrl
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
    /// Obtiene las fechas disponibles de un tour
    /// </summary>
    [HttpGet("{tourId}/dates")]
    public async Task<ActionResult<IEnumerable<TourDateDto>>> GetTourDates(Guid tourId)
    {
        try
        {
            var now = DateTime.UtcNow;
            
            var tourDates = await _context.TourDates
                .Where(td => td.TourId == tourId)
                .Where(td => td.IsActive)
                .Where(td => td.TourDateTime > now) // Solo fechas futuras
                .Where(td => td.AvailableSpots > 0) // Solo fechas con cupos disponibles
                .OrderBy(td => td.TourDateTime)
                .ToListAsync();

            var result = tourDates.Select(td => new TourDateDto
            {
                Id = td.Id,
                TourDateTime = td.TourDateTime,
                AvailableSpots = td.AvailableSpots,
                IsActive = td.IsActive
            });

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener fechas del tour {TourId}", tourId);
            throw;
        }
    }

    /// <summary>
    /// Obtiene la lista de países disponibles para seleccionar en reservas
    /// </summary>
    [HttpGet("countries")]
    public async Task<ActionResult<IEnumerable<CountryDto>>> GetCountries()
    {
        try
        {
            var countries = await _context.Countries
                .Where(c => c.IsActive)
                .OrderBy(c => c.DisplayOrder)
                .ThenBy(c => c.Name)
                .Select(c => new CountryDto
                {
                    Id = c.Id,
                    Code = c.Code,
                    Name = c.Name
                })
                .ToListAsync();

            return Ok(countries);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener países");
            throw;
        }
    }

    /// <summary>
    /// Búsqueda avanzada de tours con múltiples filtros
    /// </summary>
    [HttpGet("search")]
    public async Task<ActionResult<SearchToursResponseDto>> SearchTours(
        [FromQuery] string? q = null,
        [FromQuery] decimal? minPrice = null,
        [FromQuery] decimal? maxPrice = null,
        [FromQuery] int? minDuration = null,
        [FromQuery] int? maxDuration = null,
        [FromQuery] string? location = null,
        [FromQuery] string? category = null,
        [FromQuery] DateTime? availableDate = null,
        [FromQuery] string? sortBy = "created",
        [FromQuery] string? sortOrder = "desc",
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        try
        {
            var query = _context.Tours
                .Include(t => t.TourImages)
                .Where(t => t.IsActive);

            // Búsqueda por texto
            if (!string.IsNullOrWhiteSpace(q))
            {
                var searchLower = q.ToLower();
                query = query.Where(t => 
                    t.Name.ToLower().Contains(searchLower) ||
                    (t.Description != null && t.Description.ToLower().Contains(searchLower)) ||
                    (t.Location != null && t.Location.ToLower().Contains(searchLower)) ||
                    (t.Itinerary != null && t.Itinerary.ToLower().Contains(searchLower)));
            }

            // Filtros
            if (minPrice.HasValue)
                query = query.Where(t => t.Price >= minPrice.Value);
            if (maxPrice.HasValue)
                query = query.Where(t => t.Price <= maxPrice.Value);
            if (minDuration.HasValue)
                query = query.Where(t => t.DurationHours >= minDuration.Value);
            if (maxDuration.HasValue)
                query = query.Where(t => t.DurationHours <= maxDuration.Value);
            if (!string.IsNullOrWhiteSpace(location))
            {
                var locationLower = location.ToLower();
                query = query.Where(t => t.Location != null && t.Location.ToLower().Contains(locationLower));
            }

            // Filtro por fecha disponible
            if (availableDate.HasValue)
            {
                var date = availableDate.Value.Date;
                query = query.Where(t => 
                    t.TourDates.Any(td => td.TourDateTime.Date == date && td.IsActive && td.AvailableSpots > 0) ||
                    (t.TourDate.HasValue && t.TourDate.Value.Date == date && t.AvailableSpots > 0));
            }

            // Ordenamiento
            query = sortBy.ToLower() switch
            {
                "price" => sortOrder.ToLower() == "asc" 
                    ? query.OrderBy(t => t.Price)
                    : query.OrderByDescending(t => t.Price),
                "duration" => sortOrder.ToLower() == "asc"
                    ? query.OrderBy(t => t.DurationHours)
                    : query.OrderByDescending(t => t.DurationHours),
                "name" => sortOrder.ToLower() == "asc"
                    ? query.OrderBy(t => t.Name)
                    : query.OrderByDescending(t => t.Name),
                "popularity" => query.OrderByDescending(t => t.Bookings.Count(b => b.Status == BookingStatus.Confirmed)),
                _ => sortOrder.ToLower() == "asc"
                    ? query.OrderBy(t => t.CreatedAt)
                    : query.OrderByDescending(t => t.CreatedAt)
            };

            // Paginación
            var totalCount = await query.CountAsync();
            var tours = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var result = tours.Select(t => new TourDto
            {
                Id = t.Id,
                Name = t.Name ?? string.Empty,
                Description = t.Description ?? string.Empty,
                Itinerary = t.Itinerary,
                Includes = t.Includes,
                Price = t.Price >= 0 ? t.Price : 0,
                DurationHours = t.DurationHours,
                Location = t.Location ?? string.Empty,
                TourDate = t.TourDate,
                AvailableSpots = t.AvailableSpots,
                MaxCapacity = t.MaxCapacity,
                IsActive = t.IsActive,
                TourImages = t.TourImages.Select(i => new TourImageDto
                {
                    ImageUrl = i.ImageUrl ?? string.Empty,
                    IsPrimary = i.IsPrimary
                }).ToList()
            }).ToList();

            var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);

            return Ok(new SearchToursResponseDto
            {
                Tours = result,
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize,
                TotalPages = totalPages,
                HasNextPage = page < totalPages,
                HasPreviousPage = page > 1
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error en búsqueda de tours");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Obtiene tours relacionados/recomendados
    /// </summary>
    [HttpGet("{id}/related")]
    public async Task<ActionResult<IEnumerable<TourDto>>> GetRelatedTours(Guid id, [FromQuery] int limit = 4)
    {
        try
        {
            var tour = await _context.Tours
                .FirstOrDefaultAsync(t => t.Id == id);

            if (tour == null)
                return NotFound(new { message = "Tour no encontrado" });

            // Buscar tours similares por ubicación
            var relatedTours = await _context.Tours
                .Include(t => t.TourImages)
                .Where(t => t.Id != id && 
                           t.IsActive &&
                           (t.Location == tour.Location || 
                            (tour.Location != null && t.Location != null && t.Location.Contains(tour.Location))))
                .OrderByDescending(t => t.CreatedAt)
                .Take(limit)
                .ToListAsync();

            // Si no hay suficientes por ubicación, completar con tours recientes
            if (relatedTours.Count < limit)
            {
                var additionalTours = await _context.Tours
                    .Include(t => t.TourImages)
                    .Where(t => t.Id != id && 
                               t.IsActive &&
                               !relatedTours.Any(rt => rt.Id == t.Id))
                    .OrderByDescending(t => t.CreatedAt)
                    .Take(limit - relatedTours.Count)
                    .ToListAsync();

                relatedTours.AddRange(additionalTours);
            }

            var result = relatedTours.Select(t => new TourDto
            {
                Id = t.Id,
                Name = t.Name ?? string.Empty,
                Description = t.Description ?? string.Empty,
                Itinerary = t.Itinerary,
                Includes = t.Includes,
                Price = t.Price >= 0 ? t.Price : 0,
                DurationHours = t.DurationHours,
                Location = t.Location ?? string.Empty,
                TourDate = t.TourDate,
                AvailableSpots = t.AvailableSpots,
                MaxCapacity = t.MaxCapacity,
                IsActive = t.IsActive,
                TourImages = t.TourImages.Select(i => new TourImageDto
                {
                    ImageUrl = i.ImageUrl ?? string.Empty,
                    IsPrimary = i.IsPrimary
                }).ToList()
            }).ToList();

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener tours relacionados");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Obtiene tours destacados/populares
    /// </summary>
    [HttpGet("featured")]
    public async Task<ActionResult<IEnumerable<TourDto>>> GetFeaturedTours([FromQuery] int limit = 6)
    {
        try
        {
            var featuredTours = await _context.Tours
                .Include(t => t.TourImages)
                .Where(t => t.IsActive)
                .OrderByDescending(t => t.Bookings.Count(b => b.Status == BookingStatus.Confirmed))
                .ThenByDescending(t => t.CreatedAt)
                .Take(limit)
                .ToListAsync();

            var result = featuredTours.Select(t => new TourDto
            {
                Id = t.Id,
                Name = t.Name ?? string.Empty,
                Description = t.Description ?? string.Empty,
                Itinerary = t.Itinerary,
                Includes = t.Includes,
                Price = t.Price >= 0 ? t.Price : 0,
                DurationHours = t.DurationHours,
                Location = t.Location ?? string.Empty,
                TourDate = t.TourDate,
                AvailableSpots = t.AvailableSpots,
                MaxCapacity = t.MaxCapacity,
                IsActive = t.IsActive,
                TourImages = t.TourImages.Select(i => new TourImageDto
                {
                    ImageUrl = i.ImageUrl ?? string.Empty,
                    IsPrimary = i.IsPrimary
                }).ToList()
            }).ToList();

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener tours destacados");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Agrega un tour a favoritos (requiere autenticación)
    /// </summary>
    [HttpPost("{id}/favorite")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult> AddToFavorites(Guid id)
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            // Verificar que el tour existe
            var tour = await _context.Tours.FindAsync(id);
            if (tour == null)
            {
                return NotFound(new { message = "Tour no encontrado" });
            }

            // Verificar que no esté ya en favoritos
            var existingFavorite = await _context.UserFavorites
                .FirstOrDefaultAsync(uf => uf.UserId == userId && uf.TourId == id);

            if (existingFavorite != null)
            {
                return BadRequest(new { message = "Este tour ya está en tus favoritos" });
            }

            var favorite = new UserFavorite
            {
                UserId = userId,
                TourId = id
            };

            _context.UserFavorites.Add(favorite);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Tour agregado a favoritos" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al agregar tour a favoritos {TourId}", id);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Elimina un tour de favoritos (requiere autenticación)
    /// </summary>
    [HttpDelete("{id}/favorite")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult> RemoveFromFavorites(Guid id)
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var favorite = await _context.UserFavorites
                .FirstOrDefaultAsync(uf => uf.UserId == userId && uf.TourId == id);

            if (favorite == null)
            {
                return NotFound(new { message = "Este tour no está en tus favoritos" });
            }

            _context.UserFavorites.Remove(favorite);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Tour eliminado de favoritos" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al eliminar tour de favoritos {TourId}", id);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Obtiene los tours favoritos del usuario actual
    /// </summary>
    [HttpGet("favorites")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult<IEnumerable<TourDto>>> GetFavorites()
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var favoriteTourIds = await _context.UserFavorites
                .Where(uf => uf.UserId == userId)
                .Select(uf => uf.TourId)
                .ToListAsync();

            var tours = await _context.Tours
                .Include(t => t.TourImages)
                .Where(t => favoriteTourIds.Contains(t.Id) && t.IsActive)
                .OrderByDescending(t => t.CreatedAt)
                .ToListAsync();

            var result = tours.Select(t => new TourDto
            {
                Id = t.Id,
                Name = t.Name ?? string.Empty,
                Description = t.Description ?? string.Empty,
                Itinerary = t.Itinerary,
                Includes = t.Includes,
                Price = t.Price >= 0 ? t.Price : 0,
                DurationHours = t.DurationHours,
                Location = t.Location ?? string.Empty,
                TourDate = t.TourDate,
                AvailableSpots = t.AvailableSpots,
                MaxCapacity = t.MaxCapacity,
                IsActive = t.IsActive,
                TourImages = t.TourImages.Select(i => new TourImageDto
                {
                    ImageUrl = i.ImageUrl ?? string.Empty,
                    IsPrimary = i.IsPrimary
                }).ToList()
            }).ToList();

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener tours favoritos");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Verifica si un tour está en favoritos del usuario actual
    /// </summary>
    [HttpGet("{id}/favorite/check")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult<bool>> CheckFavorite(Guid id)
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var isFavorite = await _context.UserFavorites
                .AnyAsync(uf => uf.UserId == userId && uf.TourId == id);

            return Ok(isFavorite);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al verificar favorito {TourId}", id);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }
}

public class SearchToursResponseDto
{
    public List<TourDto> Tours { get; set; } = new();
    public int TotalCount { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalPages { get; set; }
    public bool HasNextPage { get; set; }
    public bool HasPreviousPage { get; set; }
}

public class TourDateDto
{
    public Guid Id { get; set; }
    public DateTime TourDateTime { get; set; }
    public int AvailableSpots { get; set; }
    public bool IsActive { get; set; }
}

// DTOs temporales hasta que se implemente la capa Application
public class TourDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? Itinerary { get; set; }
    public string? Includes { get; set; }
    public decimal Price { get; set; } = 0; // Valor por defecto para garantizar que nunca sea null
    public int DurationHours { get; set; }
    public string? Location { get; set; }
    public DateTime? TourDate { get; set; } // Fecha principal del tour
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

public class HomePageContentPublicDto
{
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
    public string HeroSearchButton { get; set; } = string.Empty;
    public string LoadingToursText { get; set; } = string.Empty;
    public string ErrorLoadingToursText { get; set; } = string.Empty;
    public string NoToursFoundText { get; set; } = string.Empty;
    public string PageTitle { get; set; } = string.Empty;
    public string MetaDescription { get; set; } = string.Empty;
    public string? LogoUrl { get; set; }
    public string? FaviconUrl { get; set; }
    public string? LogoUrlSocial { get; set; }
    public string? HeroImageUrl { get; set; }
}

public class CountryDto
{
    public Guid Id { get; set; }
    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
}
