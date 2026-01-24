using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Domain.Enums;
using PanamaTravelHub.Infrastructure.Data;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/tours/{tourId}/reviews")]
public class TourReviewsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<TourReviewsController> _logger;

    public TourReviewsController(
        ApplicationDbContext context,
        ILogger<TourReviewsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Obtiene todas las reseñas de un tour (aprobadas)
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<ReviewsResponseDto>> GetReviews(
        Guid tourId,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] int? minRating = null)
    {
        try
        {
            var query = _context.TourReviews
                .Include(tr => tr.User)
                .Where(tr => tr.TourId == tourId && tr.IsApproved);

            if (minRating.HasValue)
            {
                query = query.Where(tr => tr.Rating >= minRating.Value);
            }

            var totalCount = await query.CountAsync();
            var reviews = await query
                .OrderByDescending(tr => tr.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(tr => new ReviewDto
                {
                    Id = tr.Id,
                    UserName = $"{tr.User.FirstName} {tr.User.LastName}",
                    UserEmail = tr.User.Email,
                    Rating = tr.Rating,
                    Title = tr.Title,
                    Comment = tr.Comment,
                    IsVerified = tr.IsVerified,
                    CreatedAt = tr.CreatedAt
                })
                .ToListAsync();

            // Calcular estadísticas
            var stats = await _context.TourReviews
                .Where(tr => tr.TourId == tourId && tr.IsApproved)
                .GroupBy(tr => tr.Rating)
                .Select(g => new { Rating = g.Key, Count = g.Count() })
                .ToListAsync();

            var totalReviews = stats.Sum(s => s.Count);
            var averageRating = totalReviews > 0
                ? stats.Sum(s => s.Rating * s.Count) / (decimal)totalReviews
                : 0;

            var ratingDistribution = new Dictionary<int, int>
            {
                { 5, stats.FirstOrDefault(s => s.Rating == 5)?.Count ?? 0 },
                { 4, stats.FirstOrDefault(s => s.Rating == 4)?.Count ?? 0 },
                { 3, stats.FirstOrDefault(s => s.Rating == 3)?.Count ?? 0 },
                { 2, stats.FirstOrDefault(s => s.Rating == 2)?.Count ?? 0 },
                { 1, stats.FirstOrDefault(s => s.Rating == 1)?.Count ?? 0 }
            };

            var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);

            return Ok(new ReviewsResponseDto
            {
                Reviews = reviews,
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize,
                TotalPages = totalPages,
                HasNextPage = page < totalPages,
                HasPreviousPage = page > 1,
                Statistics = new ReviewStatisticsDto
                {
                    AverageRating = averageRating,
                    TotalReviews = totalReviews,
                    RatingDistribution = ratingDistribution
                }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener reseñas del tour {TourId}", tourId);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Crea una nueva reseña (requiere autenticación)
    /// </summary>
    [HttpPost]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult<ReviewDto>> CreateReview(
        Guid tourId,
        [FromBody] CreateReviewRequestDto request)
    {
        try
        {
            // Obtener userId del token
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized(new { message = "Usuario no autenticado" });
            }

            // Verificar que el tour existe
            var tour = await _context.Tours.FindAsync(tourId);
            if (tour == null)
            {
                return NotFound(new { message = "Tour no encontrado" });
            }

            // Verificar que el usuario no haya dejado ya una reseña para este tour
            var existingReview = await _context.TourReviews
                .FirstOrDefaultAsync(tr => tr.TourId == tourId && tr.UserId == userId);

            if (existingReview != null)
            {
                return BadRequest(new { message = "Ya has dejado una reseña para este tour" });
            }

            // Verificar si el usuario tiene una reserva confirmada (para verificación)
            var hasConfirmedBooking = await _context.Bookings
                .AnyAsync(b => b.TourId == tourId && 
                              b.UserId == userId && 
                              b.Status == BookingStatus.Confirmed);

            var review = new TourReview
            {
                TourId = tourId,
                UserId = userId,
                Rating = request.Rating,
                Title = request.Title,
                Comment = request.Comment,
                IsApproved = false, // Requiere moderación
                IsVerified = hasConfirmedBooking
            };

            _context.TourReviews.Add(review);
            await _context.SaveChangesAsync();

            // Cargar usuario para respuesta
            await _context.Entry(review)
                .Reference(tr => tr.User)
                .LoadAsync();

            var result = new ReviewDto
            {
                Id = review.Id,
                UserName = $"{review.User.FirstName} {review.User.LastName}",
                UserEmail = review.User.Email,
                Rating = review.Rating,
                Title = review.Title,
                Comment = review.Comment,
                IsVerified = review.IsVerified,
                CreatedAt = review.CreatedAt
            };

            return CreatedAtAction(nameof(GetReview), new { tourId, reviewId = review.Id }, result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear reseña para tour {TourId}", tourId);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Obtiene una reseña específica
    /// </summary>
    [HttpGet("{reviewId}")]
    public async Task<ActionResult<ReviewDto>> GetReview(Guid tourId, Guid reviewId)
    {
        try
        {
            var review = await _context.TourReviews
                .Include(tr => tr.User)
                .FirstOrDefaultAsync(tr => tr.Id == reviewId && tr.TourId == tourId && tr.IsApproved);

            if (review == null)
            {
                return NotFound(new { message = "Reseña no encontrada" });
            }

            var result = new ReviewDto
            {
                Id = review.Id,
                UserName = $"{review.User.FirstName} {review.User.LastName}",
                UserEmail = review.User.Email,
                Rating = review.Rating,
                Title = review.Title,
                Comment = review.Comment,
                IsVerified = review.IsVerified,
                CreatedAt = review.CreatedAt
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener reseña {ReviewId}", reviewId);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Aprueba una reseña (Admin)
    /// </summary>
    [HttpPost("{reviewId}/approve")]
    [Authorize(Policy = "AdminOnly")]
    public async Task<ActionResult> ApproveReview(Guid tourId, Guid reviewId)
    {
        try
        {
            var review = await _context.TourReviews
                .FirstOrDefaultAsync(tr => tr.Id == reviewId && tr.TourId == tourId);

            if (review == null)
            {
                return NotFound(new { message = "Reseña no encontrada" });
            }

            review.IsApproved = true;
            review.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Reseña aprobada exitosamente" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al aprobar reseña {ReviewId}", reviewId);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Rechaza una reseña (Admin)
    /// </summary>
    [HttpPost("{reviewId}/reject")]
    [Authorize(Policy = "AdminOnly")]
    public async Task<ActionResult> RejectReview(Guid tourId, Guid reviewId)
    {
        try
        {
            var review = await _context.TourReviews
                .FirstOrDefaultAsync(tr => tr.Id == reviewId && tr.TourId == tourId);

            if (review == null)
            {
                return NotFound(new { message = "Reseña no encontrada" });
            }

            review.IsApproved = false;
            review.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Reseña rechazada exitosamente" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al rechazar reseña {ReviewId}", reviewId);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Elimina una reseña (Admin o el propio usuario)
    /// </summary>
    [HttpDelete("{reviewId}")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult> DeleteReview(Guid tourId, Guid reviewId)
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var review = await _context.TourReviews
                .FirstOrDefaultAsync(tr => tr.Id == reviewId && tr.TourId == tourId);

            if (review == null)
            {
                return NotFound(new { message = "Reseña no encontrada" });
            }

            // Verificar que sea el dueño o admin
            if (review.UserId != userId && !User.IsInRole("Admin"))
            {
                return StatusCode(403, new { message = "No tienes permisos para eliminar esta reseña" });
            }

            _context.TourReviews.Remove(review);
            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al eliminar reseña {ReviewId}", reviewId);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Obtiene todas las reviews para moderación (Admin)
    /// </summary>
    [HttpGet("admin")]
    [Authorize(Policy = "AdminOnly")]
    public async Task<ActionResult<AdminReviewsResponseDto>> GetAllReviews(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50,
        [FromQuery] bool? isApproved = null,
        [FromQuery] Guid? tourId = null)
    {
        try
        {
            var query = _context.TourReviews
                .Include(tr => tr.User)
                .Include(tr => tr.Tour)
                .AsQueryable();

            if (isApproved.HasValue)
            {
                query = query.Where(tr => tr.IsApproved == isApproved.Value);
            }

            if (tourId.HasValue)
            {
                query = query.Where(tr => tr.TourId == tourId.Value);
            }

            var totalCount = await query.CountAsync();
            var reviews = await query
                .OrderByDescending(tr => tr.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(tr => new AdminReviewDto
                {
                    Id = tr.Id,
                    TourId = tr.TourId,
                    TourName = tr.Tour.Name,
                    UserId = tr.UserId,
                    UserName = $"{tr.User.FirstName} {tr.User.LastName}",
                    UserEmail = tr.User.Email,
                    Rating = tr.Rating,
                    Title = tr.Title,
                    Comment = tr.Comment,
                    IsApproved = tr.IsApproved,
                    IsVerified = tr.IsVerified,
                    CreatedAt = tr.CreatedAt
                })
                .ToListAsync();

            return Ok(new AdminReviewsResponseDto
            {
                Reviews = reviews,
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize,
                TotalPages = (int)Math.Ceiling(totalCount / (double)pageSize)
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener reviews para moderación");
            return StatusCode(500, new { message = "Error al obtener reviews" });
        }
    }
}

// DTOs adicionales para Admin
public class AdminReviewDto
{
    public Guid Id { get; set; }
    public Guid TourId { get; set; }
    public string TourName { get; set; } = string.Empty;
    public Guid UserId { get; set; }
    public string UserName { get; set; } = string.Empty;
    public string UserEmail { get; set; } = string.Empty;
    public int Rating { get; set; }
    public string? Title { get; set; }
    public string? Comment { get; set; }
    public bool IsApproved { get; set; }
    public bool IsVerified { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class AdminReviewsResponseDto
{
    public List<AdminReviewDto> Reviews { get; set; } = new();
    public int TotalCount { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalPages { get; set; }
}

// DTOs
public class ReviewDto
{
    public Guid Id { get; set; }
    public string UserName { get; set; } = string.Empty;
    public string UserEmail { get; set; } = string.Empty;
    public int Rating { get; set; }
    public string? Title { get; set; }
    public string? Comment { get; set; }
    public bool IsVerified { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreateReviewRequestDto
{
    public int Rating { get; set; }
    public string? Title { get; set; }
    public string? Comment { get; set; }
}

public class ReviewsResponseDto
{
    public List<ReviewDto> Reviews { get; set; } = new();
    public int TotalCount { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalPages { get; set; }
    public bool HasNextPage { get; set; }
    public bool HasPreviousPage { get; set; }
    public ReviewStatisticsDto Statistics { get; set; } = new();
}

public class ReviewStatisticsDto
{
    public decimal AverageRating { get; set; }
    public int TotalReviews { get; set; }
    public Dictionary<int, int> RatingDistribution { get; set; } = new();
}
