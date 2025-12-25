using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Application.DTOs;
using PanamaTravelHub.Application.Exceptions;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Application.Validators;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Infrastructure.Data;
using PanamaTravelHub.Infrastructure.Repositories;
using System.IO;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/admin")]
[Authorize(Policy = "AdminOnly")]
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
                for (int i = 0; i < request.Images.Count; i++)
                {
                    var imageUrl = request.Images[i];
                    var tourImage = new TourImage
                    {
                        TourId = tour.Id,
                        ImageUrl = imageUrl,
                        DisplayOrder = i,
                        IsPrimary = i == 0 // Primera imagen es principal
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
                ImageUrl = tour.TourImages.FirstOrDefault(i => i.IsPrimary)?.ImageUrl,
                Images = tour.TourImages.OrderBy(i => i.DisplayOrder).Select(i => i.ImageUrl).ToList()
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
                Images = tour.TourImages.OrderBy(i => i.DisplayOrder).Select(i => i.ImageUrl).ToList()
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
                    for (int i = 0; i < request.Images.Count; i++)
                    {
                        var imageUrl = request.Images[i];
                        var tourImage = new TourImage
                        {
                            TourId = tour.Id,
                            ImageUrl = imageUrl,
                            DisplayOrder = i,
                            IsPrimary = i == 0 // Primera imagen es principal
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
                Images = tour.TourImages.OrderBy(i => i.DisplayOrder).Select(i => i.ImageUrl).ToList()
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
                HeroSearchButton = content.HeroSearchButton,
                ToursSectionTitle = content.ToursSectionTitle,
                ToursSectionSubtitle = content.ToursSectionSubtitle,
                LoadingToursText = content.LoadingToursText,
                ErrorLoadingToursText = content.ErrorLoadingToursText,
                NoToursFoundText = content.NoToursFoundText,
                FooterBrandText = content.FooterBrandText,
                FooterDescription = content.FooterDescription,
                FooterCopyright = content.FooterCopyright,
                NavBrandText = content.NavBrandText,
                NavToursLink = content.NavToursLink,
                NavBookingsLink = content.NavBookingsLink,
                NavLoginLink = content.NavLoginLink,
                NavLogoutButton = content.NavLogoutButton,
                PageTitle = content.PageTitle,
                MetaDescription = content.MetaDescription,
                LogoUrl = content.LogoUrl,
                FaviconUrl = content.FaviconUrl,
                LogoUrlSocial = content.LogoUrlSocial,
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

            // Actualizar todos los campos directamente (permite null y string vacío para limpiar)
            content.HeroTitle = request.HeroTitle ?? string.Empty;
            content.HeroSubtitle = request.HeroSubtitle ?? string.Empty;
            content.HeroSearchPlaceholder = request.HeroSearchPlaceholder ?? string.Empty;
            content.HeroSearchButton = request.HeroSearchButton ?? string.Empty;
            content.ToursSectionTitle = request.ToursSectionTitle ?? string.Empty;
            content.ToursSectionSubtitle = request.ToursSectionSubtitle ?? string.Empty;
            content.LoadingToursText = request.LoadingToursText ?? string.Empty;
            content.ErrorLoadingToursText = request.ErrorLoadingToursText ?? string.Empty;
            content.NoToursFoundText = request.NoToursFoundText ?? string.Empty;
            content.FooterBrandText = request.FooterBrandText ?? string.Empty;
            content.FooterDescription = request.FooterDescription ?? string.Empty;
            content.FooterCopyright = request.FooterCopyright ?? string.Empty;
            content.NavBrandText = request.NavBrandText ?? string.Empty;
            content.NavToursLink = request.NavToursLink ?? string.Empty;
            content.NavBookingsLink = request.NavBookingsLink ?? string.Empty;
            content.NavLoginLink = request.NavLoginLink ?? string.Empty;
            content.NavLogoutButton = request.NavLogoutButton ?? string.Empty;
            content.PageTitle = request.PageTitle ?? string.Empty;
            content.MetaDescription = request.MetaDescription ?? string.Empty;

            // Campos de imágenes (pueden ser null para limpiar)
            content.LogoUrl = string.IsNullOrEmpty(request.LogoUrl) ? null : request.LogoUrl;
            content.FaviconUrl = string.IsNullOrEmpty(request.FaviconUrl) ? null : request.FaviconUrl;
            content.LogoUrlSocial = string.IsNullOrEmpty(request.LogoUrlSocial) ? null : request.LogoUrlSocial;

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
                HeroSearchButton = content.HeroSearchButton,
                LoadingToursText = content.LoadingToursText,
                ErrorLoadingToursText = content.ErrorLoadingToursText,
                NoToursFoundText = content.NoToursFoundText,
                PageTitle = content.PageTitle,
                MetaDescription = content.MetaDescription,
                LogoUrl = content.LogoUrl,
                FaviconUrl = content.FaviconUrl,
                LogoUrlSocial = content.LogoUrlSocial,
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

    /// <summary>
    /// Sube una imagen para un tour
    /// </summary>
    [HttpPost("upload-image")]
    public async Task<ActionResult<ImageUploadResponseDto>> UploadImage(IFormFile file)
    {
        try
        {
            _logger.LogInformation("Iniciando subida de imagen. FileName: {FileName}, Size: {Size}", 
                file?.FileName, file?.Length);

            if (file == null || file.Length == 0)
            {
                _logger.LogWarning("No se proporcionó ningún archivo");
                return BadRequest(new { message = "No se proporcionó ningún archivo" });
            }

            // Validar tipo de archivo
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
            var fileExtension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (!allowedExtensions.Contains(fileExtension))
            {
                _logger.LogWarning("Tipo de archivo no permitido: {Extension}", fileExtension);
                return BadRequest(new { message = "Tipo de archivo no permitido. Solo se permiten: JPG, JPEG, PNG, GIF, WEBP" });
            }

            // Validar tamaño (máximo 5MB)
            const long maxFileSize = 5 * 1024 * 1024; // 5MB
            if (file.Length > maxFileSize)
            {
                _logger.LogWarning("Archivo demasiado grande: {Size} bytes", file.Length);
                return BadRequest(new { message = "El archivo es demasiado grande. Tamaño máximo: 5MB" });
            }

            // Crear directorio de uploads si no existe
            var uploadsPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "tours");
            if (!Directory.Exists(uploadsPath))
            {
                _logger.LogInformation("Creando directorio de uploads: {Path}", uploadsPath);
                Directory.CreateDirectory(uploadsPath);
            }

            // Generar nombre único para el archivo
            var fileName = $"{Guid.NewGuid()}{fileExtension}";
            var filePath = Path.Combine(uploadsPath, fileName);

            _logger.LogInformation("Guardando archivo en: {FilePath}", filePath);

            // Guardar archivo
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // Retornar URL relativa
            var imageUrl = $"/uploads/tours/{fileName}";

            _logger.LogInformation("Imagen subida exitosamente. URL: {Url}", imageUrl);

            return Ok(new ImageUploadResponseDto
            {
                Url = imageUrl,
                FileName = fileName,
                Size = file.Length
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al subir imagen. FileName: {FileName}", file?.FileName);
            return StatusCode(500, new { message = "Error al subir la imagen: " + ex.Message });
        }
    }

    // ============================================
    // MEDIA LIBRARY ENDPOINTS
    // ============================================

    /// <summary>
    /// Obtiene todos los archivos de la media library
    /// </summary>
    [HttpGet("media")]
    public async Task<ActionResult<IEnumerable<MediaFileDto>>> GetMediaFiles(
        [FromQuery] string? category = null,
        [FromQuery] bool? isImage = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50)
    {
        try
        {
            var query = _context.MediaFiles.AsQueryable();

            if (!string.IsNullOrEmpty(category))
            {
                query = query.Where(m => m.Category == category);
            }

            if (isImage.HasValue)
            {
                query = query.Where(m => m.IsImage == isImage.Value);
            }

            var totalCount = await query.CountAsync();
            var mediaFiles = await query
                .OrderByDescending(m => m.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var result = mediaFiles.Select(m => new MediaFileDto
            {
                Id = m.Id,
                FileName = m.FileName,
                FileUrl = m.FileUrl,
                MimeType = m.MimeType,
                FileSize = m.FileSize,
                AltText = m.AltText,
                Description = m.Description,
                Category = m.Category,
                IsImage = m.IsImage,
                Width = m.Width,
                Height = m.Height,
                CreatedAt = m.CreatedAt
            });

            Response.Headers["X-Total-Count"] = totalCount.ToString();
            Response.Headers["X-Page"] = page.ToString();
            Response.Headers["X-Page-Size"] = pageSize.ToString();

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener archivos de media");
            throw;
        }
    }

    /// <summary>
    /// Sube un archivo a la media library
    /// </summary>
    [HttpPost("media")]
    public async Task<ActionResult<MediaFileDto>> UploadMediaFile(
        IFormFile file,
        [FromForm] string? altText = null,
        [FromForm] string? description = null,
        [FromForm] string? category = null)
    {
        try
        {
            if (file == null || file.Length == 0)
            {
                return BadRequest(new { message = "No se proporcionó ningún archivo" });
            }

            // Validar tamaño (máximo 10MB)
            const long maxFileSize = 10 * 1024 * 1024; // 10MB
            if (file.Length > maxFileSize)
            {
                return BadRequest(new { message = "El archivo es demasiado grande. Tamaño máximo: 10MB" });
            }

            // Crear directorio de uploads si no existe
            var uploadsPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "media");
            if (!Directory.Exists(uploadsPath))
            {
                Directory.CreateDirectory(uploadsPath);
            }

            // Generar nombre único
            var fileExtension = Path.GetExtension(file.FileName).ToLowerInvariant();
            var fileName = $"{Guid.NewGuid()}{fileExtension}";
            var filePath = Path.Combine(uploadsPath, fileName);

            // Guardar archivo
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var fileUrl = $"/uploads/media/{fileName}";
            var isImage = file.ContentType.StartsWith("image/");

            // Obtener dimensiones si es imagen (opcional, requiere paquete adicional)
            // Por ahora, dejamos width y height como null
            // Se pueden obtener usando SixLabors.ImageSharp u otro paquete si es necesario
            int? width = null;
            int? height = null;

            // Obtener ID del usuario actual (si está autenticado)
            var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier);
            Guid? uploadedBy = userIdClaim != null && Guid.TryParse(userIdClaim.Value, out var userId) ? userId : null;

            var mediaFile = new MediaFile
            {
                FileName = file.FileName,
                FilePath = filePath,
                FileUrl = fileUrl,
                MimeType = file.ContentType,
                FileSize = file.Length,
                AltText = altText,
                Description = description,
                Category = category,
                IsImage = isImage,
                Width = width,
                Height = height,
                UploadedBy = uploadedBy,
                CreatedAt = DateTime.UtcNow
            };

            _context.MediaFiles.Add(mediaFile);
            await _context.SaveChangesAsync();

            var result = new MediaFileDto
            {
                Id = mediaFile.Id,
                FileName = mediaFile.FileName,
                FileUrl = mediaFile.FileUrl,
                MimeType = mediaFile.MimeType,
                FileSize = mediaFile.FileSize,
                AltText = mediaFile.AltText,
                Description = mediaFile.Description,
                Category = mediaFile.Category,
                IsImage = mediaFile.IsImage,
                Width = mediaFile.Width,
                Height = mediaFile.Height,
                CreatedAt = mediaFile.CreatedAt
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al subir archivo a media library");
            return StatusCode(500, new { message = "Error al subir el archivo: " + ex.Message });
        }
    }

    /// <summary>
    /// Elimina un archivo de la media library
    /// </summary>
    [HttpDelete("media/{id}")]
    public async Task<IActionResult> DeleteMediaFile(Guid id)
    {
        try
        {
            var mediaFile = await _context.MediaFiles.FindAsync(id);
            if (mediaFile == null)
            {
                return NotFound(new { message = "Archivo no encontrado" });
            }

            // Eliminar archivo físico
            if (System.IO.File.Exists(mediaFile.FilePath))
            {
                System.IO.File.Delete(mediaFile.FilePath);
            }

            _context.MediaFiles.Remove(mediaFile);
            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al eliminar archivo de media library");
            throw;
        }
    }

    // ============================================
    // PAGES ENDPOINTS
    // ============================================

    /// <summary>
    /// Obtiene todas las páginas
    /// </summary>
    [HttpGet("pages")]
    public async Task<ActionResult<IEnumerable<PageDto>>> GetPages(
        [FromQuery] bool? isPublished = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50)
    {
        try
        {
            var query = _context.Pages.AsQueryable();

            if (isPublished.HasValue)
            {
                query = query.Where(p => p.IsPublished == isPublished.Value);
            }

            var totalCount = await query.CountAsync();
            var pages = await query
                .OrderBy(p => p.DisplayOrder)
                .ThenByDescending(p => p.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var result = pages.Select(p => new PageDto
            {
                Id = p.Id,
                Title = p.Title,
                Slug = p.Slug,
                Excerpt = p.Excerpt,
                IsPublished = p.IsPublished,
                PublishedAt = p.PublishedAt,
                DisplayOrder = p.DisplayOrder,
                CreatedAt = p.CreatedAt,
                UpdatedAt = p.UpdatedAt
            });

            Response.Headers["X-Total-Count"] = totalCount.ToString();
            Response.Headers["X-Page"] = page.ToString();
            Response.Headers["X-Page-Size"] = pageSize.ToString();

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener páginas");
            throw;
        }
    }

    /// <summary>
    /// Obtiene una página por ID
    /// </summary>
    [HttpGet("pages/{id}")]
    public async Task<ActionResult<PageDetailDto>> GetPage(Guid id)
    {
        try
        {
            var page = await _context.Pages.FindAsync(id);
            if (page == null)
            {
                return NotFound(new { message = "Página no encontrada" });
            }

            var result = new PageDetailDto
            {
                Id = page.Id,
                Title = page.Title,
                Slug = page.Slug,
                Content = page.Content,
                Excerpt = page.Excerpt,
                MetaTitle = page.MetaTitle,
                MetaDescription = page.MetaDescription,
                MetaKeywords = page.MetaKeywords,
                IsPublished = page.IsPublished,
                PublishedAt = page.PublishedAt,
                Template = page.Template,
                DisplayOrder = page.DisplayOrder,
                CreatedAt = page.CreatedAt,
                UpdatedAt = page.UpdatedAt
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener página");
            throw;
        }
    }

    /// <summary>
    /// Crea una nueva página
    /// </summary>
    [HttpPost("pages")]
    public async Task<ActionResult<PageDetailDto>> CreatePage([FromBody] CreatePageRequestDto request)
    {
        try
        {
            // Verificar que el slug sea único
            var existingPage = await _context.Pages.FirstOrDefaultAsync(p => p.Slug == request.Slug);
            if (existingPage != null)
            {
                return BadRequest(new { message = "Ya existe una página con este slug" });
            }

            var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier);
            Guid? createdBy = userIdClaim != null && Guid.TryParse(userIdClaim.Value, out var userId) ? userId : null;

            var page = new Page
            {
                Title = request.Title,
                Slug = request.Slug,
                Content = request.Content ?? string.Empty,
                Excerpt = request.Excerpt,
                MetaTitle = request.MetaTitle,
                MetaDescription = request.MetaDescription,
                MetaKeywords = request.MetaKeywords,
                IsPublished = request.IsPublished ?? false,
                PublishedAt = request.IsPublished == true ? DateTime.UtcNow : null,
                Template = request.Template,
                DisplayOrder = request.DisplayOrder ?? 0,
                CreatedBy = createdBy,
                CreatedAt = DateTime.UtcNow
            };

            _context.Pages.Add(page);
            await _context.SaveChangesAsync();

            var result = new PageDetailDto
            {
                Id = page.Id,
                Title = page.Title,
                Slug = page.Slug,
                Content = page.Content,
                Excerpt = page.Excerpt,
                MetaTitle = page.MetaTitle,
                MetaDescription = page.MetaDescription,
                MetaKeywords = page.MetaKeywords,
                IsPublished = page.IsPublished,
                PublishedAt = page.PublishedAt,
                Template = page.Template,
                DisplayOrder = page.DisplayOrder,
                CreatedAt = page.CreatedAt,
                UpdatedAt = page.UpdatedAt
            };

            return CreatedAtAction(nameof(GetPage), new { id = page.Id }, result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear página");
            throw;
        }
    }

    /// <summary>
    /// Actualiza una página
    /// </summary>
    [HttpPut("pages/{id}")]
    public async Task<ActionResult<PageDetailDto>> UpdatePage(Guid id, [FromBody] UpdatePageRequestDto request)
    {
        try
        {
            var page = await _context.Pages.FindAsync(id);
            if (page == null)
            {
                return NotFound(new { message = "Página no encontrada" });
            }

            // Verificar que el slug sea único (si cambió)
            if (request.Slug != null && request.Slug != page.Slug)
            {
                var existingPage = await _context.Pages.FirstOrDefaultAsync(p => p.Slug == request.Slug && p.Id != id);
                if (existingPage != null)
                {
                    return BadRequest(new { message = "Ya existe una página con este slug" });
                }
            }

            var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier);
            Guid? updatedBy = userIdClaim != null && Guid.TryParse(userIdClaim.Value, out var userId) ? userId : null;

            if (request.Title != null) page.Title = request.Title;
            if (request.Slug != null) page.Slug = request.Slug;
            if (request.Content != null) page.Content = request.Content;
            if (request.Excerpt != null) page.Excerpt = request.Excerpt;
            if (request.MetaTitle != null) page.MetaTitle = request.MetaTitle;
            if (request.MetaDescription != null) page.MetaDescription = request.MetaDescription;
            if (request.MetaKeywords != null) page.MetaKeywords = request.MetaKeywords;
            if (request.IsPublished.HasValue)
            {
                page.IsPublished = request.IsPublished.Value;
                page.PublishedAt = request.IsPublished.Value && page.PublishedAt == null ? DateTime.UtcNow : page.PublishedAt;
            }
            if (request.Template != null) page.Template = request.Template;
            if (request.DisplayOrder.HasValue) page.DisplayOrder = request.DisplayOrder.Value;
            
            page.UpdatedBy = updatedBy;
            page.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            var result = new PageDetailDto
            {
                Id = page.Id,
                Title = page.Title,
                Slug = page.Slug,
                Content = page.Content,
                Excerpt = page.Excerpt,
                MetaTitle = page.MetaTitle,
                MetaDescription = page.MetaDescription,
                MetaKeywords = page.MetaKeywords,
                IsPublished = page.IsPublished,
                PublishedAt = page.PublishedAt,
                Template = page.Template,
                DisplayOrder = page.DisplayOrder,
                CreatedAt = page.CreatedAt,
                UpdatedAt = page.UpdatedAt
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al actualizar página");
            throw;
        }
    }

    /// <summary>
    /// Elimina una página
    /// </summary>
    [HttpDelete("pages/{id}")]
    public async Task<IActionResult> DeletePage(Guid id)
    {
        try
        {
            var page = await _context.Pages.FindAsync(id);
            if (page == null)
            {
                return NotFound(new { message = "Página no encontrada" });
            }

            _context.Pages.Remove(page);
            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al eliminar página");
            throw;
        }
    }

    /// <summary>
    /// Obtiene las fechas de un tour (Admin)
    /// </summary>
    [HttpGet("tours/{tourId}/dates")]
    public async Task<ActionResult<IEnumerable<AdminTourDateDto>>> GetTourDates(Guid tourId)
    {
        try
        {
            var tourDates = await _context.TourDates
                .Where(td => td.TourId == tourId)
                .OrderBy(td => td.TourDateTime)
                .ToListAsync();

            var result = tourDates.Select(td => new AdminTourDateDto
            {
                Id = td.Id,
                TourDateTime = td.TourDateTime,
                AvailableSpots = td.AvailableSpots,
                IsActive = td.IsActive,
                CreatedAt = td.CreatedAt
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
    /// Crea una nueva fecha para un tour (Admin)
    /// </summary>
    [HttpPost("tours/{tourId}/dates")]
    public async Task<ActionResult<AdminTourDateDto>> CreateTourDate(Guid tourId, [FromBody] CreateTourDateRequestDto request)
    {
        try
        {
            // Verificar que el tour existe
            var tour = await _tourRepository.GetByIdAsync(tourId);
            if (tour == null)
            {
                return NotFound(new { message = "Tour no encontrado" });
            }

            // Validar que la fecha sea futura
            if (request.TourDateTime <= DateTime.UtcNow)
            {
                return BadRequest(new { message = "La fecha del tour debe ser futura" });
            }

            // Validar que no exista otra fecha igual para el mismo tour
            var existingDate = await _context.TourDates
                .FirstOrDefaultAsync(td => td.TourId == tourId && 
                                          td.TourDateTime == request.TourDateTime);

            if (existingDate != null)
            {
                return BadRequest(new { message = "Ya existe una fecha con esta fecha y hora para este tour" });
            }

            var tourDate = new TourDate
            {
                TourId = tourId,
                TourDateTime = DateTime.SpecifyKind(request.TourDateTime, DateTimeKind.Utc),
                AvailableSpots = request.AvailableSpots ?? tour.MaxCapacity,
                IsActive = request.IsActive ?? true
            };

            _context.TourDates.Add(tourDate);
            await _context.SaveChangesAsync();

            var result = new AdminTourDateDto
            {
                Id = tourDate.Id,
                TourDateTime = tourDate.TourDateTime,
                AvailableSpots = tourDate.AvailableSpots,
                IsActive = tourDate.IsActive,
                CreatedAt = tourDate.CreatedAt
            };

            return CreatedAtAction(nameof(GetTourDates), new { tourId }, result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear fecha para tour {TourId}", tourId);
            throw;
        }
    }

    /// <summary>
    /// Actualiza una fecha de tour (Admin)
    /// </summary>
    [HttpPut("tours/dates/{dateId}")]
    public async Task<ActionResult<AdminTourDateDto>> UpdateTourDate(Guid dateId, [FromBody] UpdateTourDateRequestDto request)
    {
        try
        {
            var tourDate = await _context.TourDates.FindAsync(dateId);
            if (tourDate == null)
            {
                return NotFound(new { message = "Fecha de tour no encontrada" });
            }

            // Validar que la fecha sea futura si se está cambiando
            if (request.TourDateTime.HasValue && request.TourDateTime.Value <= DateTime.UtcNow)
            {
                return BadRequest(new { message = "La fecha del tour debe ser futura" });
            }

            if (request.TourDateTime.HasValue)
            {
                tourDate.TourDateTime = DateTime.SpecifyKind(request.TourDateTime.Value, DateTimeKind.Utc);
            }

            if (request.AvailableSpots.HasValue)
            {
                if (request.AvailableSpots.Value < 0)
                {
                    return BadRequest(new { message = "Los cupos disponibles no pueden ser negativos" });
                }
                tourDate.AvailableSpots = request.AvailableSpots.Value;
            }

            if (request.IsActive.HasValue)
            {
                tourDate.IsActive = request.IsActive.Value;
            }

            tourDate.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            var result = new AdminTourDateDto
            {
                Id = tourDate.Id,
                TourDateTime = tourDate.TourDateTime,
                AvailableSpots = tourDate.AvailableSpots,
                IsActive = tourDate.IsActive,
                CreatedAt = tourDate.CreatedAt
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al actualizar fecha de tour {DateId}", dateId);
            throw;
        }
    }

    /// <summary>
    /// Elimina una fecha de tour (Admin)
    /// </summary>
    [HttpDelete("tours/dates/{dateId}")]
    public async Task<IActionResult> DeleteTourDate(Guid dateId)
    {
        try
        {
            var tourDate = await _context.TourDates
                .Include(td => td.Bookings)
                .FirstOrDefaultAsync(td => td.Id == dateId);

            if (tourDate == null)
            {
                return NotFound(new { message = "Fecha de tour no encontrada" });
            }

            // Verificar si hay reservas confirmadas para esta fecha
            var hasConfirmedBookings = tourDate.Bookings.Any(b => b.Status == Domain.Enums.BookingStatus.Confirmed);
            if (hasConfirmedBookings)
            {
                // En lugar de eliminar, desactivar
                tourDate.IsActive = false;
                tourDate.UpdatedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();
                return Ok(new { message = "La fecha ha sido desactivada porque tiene reservas confirmadas" });
            }

            _context.TourDates.Remove(tourDate);
            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al eliminar fecha de tour {DateId}", dateId);
            throw;
        }
    }

    /// <summary>
    /// Obtiene todos los usuarios (Admin)
    /// </summary>
    [HttpGet("users")]
    public async Task<ActionResult<IEnumerable<AdminUserDto>>> GetUsers(
        [FromQuery] string? search = null,
        [FromQuery] bool? isActive = null,
        [FromQuery] string? role = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50)
    {
        try
        {
            var query = _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .Include(u => u.Bookings)
                .AsQueryable();

            // Búsqueda por email, nombre o apellido
            if (!string.IsNullOrEmpty(search))
            {
                search = search.ToLower();
                query = query.Where(u => 
                    u.Email.ToLower().Contains(search) ||
                    u.FirstName.ToLower().Contains(search) ||
                    u.LastName.ToLower().Contains(search));
            }

            // Filtro por estado activo
            if (isActive.HasValue)
            {
                query = query.Where(u => u.IsActive == isActive.Value);
            }

            // Filtro por rol
            if (!string.IsNullOrEmpty(role))
            {
                query = query.Where(u => u.UserRoles.Any(ur => ur.Role.Name.ToLower() == role.ToLower()));
            }

            // Paginación
            var totalCount = await query.CountAsync();
            var users = await query
                .OrderByDescending(u => u.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var result = users.Select(u => new AdminUserDto
            {
                Id = u.Id,
                Email = u.Email,
                FirstName = u.FirstName,
                LastName = u.LastName,
                Phone = u.Phone,
                IsActive = u.IsActive,
                Roles = u.UserRoles.Select(ur => ur.Role.Name).ToList(),
                FailedLoginAttempts = u.FailedLoginAttempts,
                LockedUntil = u.LockedUntil,
                LastLoginAt = u.LastLoginAt,
                CreatedAt = u.CreatedAt,
                TotalBookings = u.Bookings.Count
            });

            Response.Headers["X-Total-Count"] = totalCount.ToString();
            Response.Headers["X-Page"] = page.ToString();
            Response.Headers["X-Page-Size"] = pageSize.ToString();

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener usuarios");
            throw;
        }
    }

    /// <summary>
    /// Obtiene un usuario por ID (Admin)
    /// </summary>
    [HttpGet("users/{id}")]
    public async Task<ActionResult<AdminUserDetailDto>> GetUser(Guid id)
    {
        try
        {
            var user = await _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .Include(u => u.Bookings)
                    .ThenInclude(b => b.Tour)
                .FirstOrDefaultAsync(u => u.Id == id);

            if (user == null)
            {
                return NotFound(new { message = "Usuario no encontrado" });
            }

            var result = new AdminUserDetailDto
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Phone = user.Phone,
                IsActive = user.IsActive,
                Roles = user.UserRoles.Select(ur => ur.Role.Name).ToList(),
                FailedLoginAttempts = user.FailedLoginAttempts,
                LockedUntil = user.LockedUntil,
                LastLoginAt = user.LastLoginAt,
                CreatedAt = user.CreatedAt,
                Bookings = user.Bookings.Select(b => new AdminUserBookingDto
                {
                    Id = b.Id,
                    TourName = b.Tour.Name,
                    Status = b.Status.ToString(),
                    NumberOfParticipants = b.NumberOfParticipants,
                    TotalAmount = b.TotalAmount,
                    TourDate = b.TourDate?.TourDateTime,
                    CreatedAt = b.CreatedAt
                }).OrderByDescending(b => b.CreatedAt).ToList()
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener usuario {UserId}", id);
            throw;
        }
    }

    /// <summary>
    /// Actualiza un usuario (Admin)
    /// </summary>
    [HttpPut("users/{id}")]
    public async Task<ActionResult<AdminUserDto>> UpdateUser(Guid id, [FromBody] UpdateUserRequestDto request)
    {
        try
        {
            var user = await _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == id);

            if (user == null)
            {
                return NotFound(new { message = "Usuario no encontrado" });
            }

            // Actualizar campos básicos
            if (!string.IsNullOrEmpty(request.FirstName))
            {
                user.FirstName = request.FirstName;
            }

            if (!string.IsNullOrEmpty(request.LastName))
            {
                user.LastName = request.LastName;
            }

            if (request.Phone != null)
            {
                user.Phone = request.Phone;
            }

            if (request.IsActive.HasValue)
            {
                user.IsActive = request.IsActive.Value;
                
                // Si se activa, limpiar bloqueo
                if (request.IsActive.Value)
                {
                    user.LockedUntil = null;
                    user.FailedLoginAttempts = 0;
                }
            }

            // Actualizar roles si se proporcionan
            if (request.Roles != null && request.Roles.Any())
            {
                // Obtener IDs de roles por nombre
                var roleNames = request.Roles.Select(r => r.ToLower()).ToList();
                var roles = await _context.Roles
                    .Where(r => roleNames.Contains(r.Name.ToLower()))
                    .ToListAsync();

                // Eliminar roles actuales
                _context.UserRoles.RemoveRange(user.UserRoles);

                // Agregar nuevos roles
                foreach (var role in roles)
                {
                    user.UserRoles.Add(new UserRole
                    {
                        UserId = user.Id,
                        RoleId = role.Id
                    });
                }
            }

            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            // Recargar para obtener roles actualizados
            await _context.Entry(user)
                .Collection(u => u.UserRoles)
                .Query()
                .Include(ur => ur.Role)
                .LoadAsync();

            await _context.Entry(user)
                .Collection(u => u.Bookings)
                .LoadAsync();

            var result = new AdminUserDto
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Phone = user.Phone,
                IsActive = user.IsActive,
                Roles = user.UserRoles.Select(ur => ur.Role.Name).ToList(),
                FailedLoginAttempts = user.FailedLoginAttempts,
                LockedUntil = user.LockedUntil,
                LastLoginAt = user.LastLoginAt,
                CreatedAt = user.CreatedAt,
                TotalBookings = user.Bookings.Count
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al actualizar usuario {UserId}", id);
            throw;
        }
    }

    /// <summary>
    /// Desbloquea un usuario (Admin)
    /// </summary>
    [HttpPost("users/{id}/unlock")]
    public async Task<ActionResult> UnlockUser(Guid id)
    {
        try
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
            {
                return NotFound(new { message = "Usuario no encontrado" });
            }

            user.LockedUntil = null;
            user.FailedLoginAttempts = 0;
            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Usuario desbloqueado exitosamente" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al desbloquear usuario {UserId}", id);
            throw;
        }
    }

    /// <summary>
    /// Obtiene los roles disponibles
    /// </summary>
    [HttpGet("roles")]
    public async Task<ActionResult<IEnumerable<RoleDto>>> GetRoles()
    {
        try
        {
            var roles = await _context.Roles
                .OrderBy(r => r.Name)
                .ToListAsync();

            var result = roles.Select(r => new RoleDto
            {
                Id = r.Id,
                Name = r.Name,
                Description = r.Description
            });

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener roles");
            throw;
        }
    }
}

public class AdminTourDateDto
{
    public Guid Id { get; set; }
    public DateTime TourDateTime { get; set; }
    public int AvailableSpots { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
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
    public string HeroSearchButton { get; set; } = string.Empty;
    public string LoadingToursText { get; set; } = string.Empty;
    public string ErrorLoadingToursText { get; set; } = string.Empty;
    public string NoToursFoundText { get; set; } = string.Empty;
    public string PageTitle { get; set; } = string.Empty;
    public string MetaDescription { get; set; } = string.Empty;
    public string? LogoUrl { get; set; }
    public string? FaviconUrl { get; set; }
    public string? LogoUrlSocial { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class ImageUploadResponseDto
{
    public string Url { get; set; } = string.Empty;
    public string FileName { get; set; } = string.Empty;
    public long Size { get; set; }
}

public class AdminUserDto
{
    public Guid Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public bool IsActive { get; set; }
    public List<string> Roles { get; set; } = new();
    public int FailedLoginAttempts { get; set; }
    public DateTime? LockedUntil { get; set; }
    public DateTime? LastLoginAt { get; set; }
    public DateTime CreatedAt { get; set; }
    public int TotalBookings { get; set; }
}

public class AdminUserDetailDto : AdminUserDto
{
    public List<AdminUserBookingDto> Bookings { get; set; } = new();
}

public class AdminUserBookingDto
{
    public Guid Id { get; set; }
    public string TourName { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public int NumberOfParticipants { get; set; }
    public decimal TotalAmount { get; set; }
    public DateTime? TourDate { get; set; }
    public DateTime CreatedAt { get; set; }
}

// UpdateUserRequestDto está definido en PanamaTravelHub.Application.Validators

public class RoleDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
}

// Media Library DTOs
public class MediaFileDto
{
    public Guid Id { get; set; }
    public string FileName { get; set; } = string.Empty;
    public string FileUrl { get; set; } = string.Empty;
    public string MimeType { get; set; } = string.Empty;
    public long FileSize { get; set; }
    public string? AltText { get; set; }
    public string? Description { get; set; }
    public string? Category { get; set; }
    public bool IsImage { get; set; }
    public int? Width { get; set; }
    public int? Height { get; set; }
    public DateTime CreatedAt { get; set; }
}

// Pages DTOs
public class PageDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public string? Excerpt { get; set; }
    public bool IsPublished { get; set; }
    public DateTime? PublishedAt { get; set; }
    public int DisplayOrder { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class PageDetailDto : PageDto
{
    public string Content { get; set; } = string.Empty;
    public string? MetaTitle { get; set; }
    public string? MetaDescription { get; set; }
    public string? MetaKeywords { get; set; }
    public string? Template { get; set; }
}

public class CreatePageRequestDto
{
    public string Title { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public string? Content { get; set; }
    public string? Excerpt { get; set; }
    public string? MetaTitle { get; set; }
    public string? MetaDescription { get; set; }
    public string? MetaKeywords { get; set; }
    public bool? IsPublished { get; set; }
    public string? Template { get; set; }
    public int? DisplayOrder { get; set; }
}

public class UpdatePageRequestDto
{
    public string? Title { get; set; }
    public string? Slug { get; set; }
    public string? Content { get; set; }
    public string? Excerpt { get; set; }
    public string? MetaTitle { get; set; }
    public string? MetaDescription { get; set; }
    public string? MetaKeywords { get; set; }
    public bool? IsPublished { get; set; }
    public string? Template { get; set; }
    public int? DisplayOrder { get; set; }
}

