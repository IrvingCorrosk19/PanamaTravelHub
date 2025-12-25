using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Infrastructure.Data;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BlogController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<BlogController> _logger;

    public BlogController(
        ApplicationDbContext context,
        ILogger<BlogController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Obtiene todos los posts de blog publicados
    /// </summary>
    /// <param name="page">Número de página (default: 1)</param>
    /// <param name="pageSize">Tamaño de página (default: 10, max: 50)</param>
    /// <param name="search">Término de búsqueda opcional</param>
    [HttpGet]
    public async Task<ActionResult<BlogPostsResponseDto>> GetBlogPosts(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] string? search = null)
    {
        try
        {
            // Validar parámetros
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 10;
            if (pageSize > 50) pageSize = 50;

            var query = _context.Pages
                .Where(p => p.IsPublished && 
                           p.PublishedAt != null &&
                           p.PublishedAt <= DateTime.UtcNow &&
                           (p.Template == "Blog" || p.Template == "blog" || string.IsNullOrEmpty(p.Template)));

            // Búsqueda opcional
            if (!string.IsNullOrWhiteSpace(search))
            {
                var searchLower = search.ToLower();
                query = query.Where(p => 
                    p.Title.ToLower().Contains(searchLower) ||
                    (p.Excerpt != null && p.Excerpt.ToLower().Contains(searchLower)) ||
                    p.Content.ToLower().Contains(searchLower));
            }

            // Ordenar por fecha de publicación (más reciente primero)
            query = query.OrderByDescending(p => p.PublishedAt)
                        .ThenByDescending(p => p.CreatedAt);

            // Obtener total de registros
            var totalCount = await query.CountAsync();

            // Aplicar paginación
            var posts = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(p => new BlogPostDto
                {
                    Id = p.Id,
                    Title = p.Title,
                    Slug = p.Slug,
                    Excerpt = p.Excerpt ?? string.Empty,
                    PublishedAt = p.PublishedAt!.Value,
                    CreatedAt = p.CreatedAt,
                    MetaTitle = p.MetaTitle,
                    MetaDescription = p.MetaDescription
                })
                .ToListAsync();

            var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);

            var response = new BlogPostsResponseDto
            {
                Posts = posts,
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize,
                TotalPages = totalPages,
                HasNextPage = page < totalPages,
                HasPreviousPage = page > 1
            };

            return Ok(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener posts de blog");
            throw;
        }
    }

    /// <summary>
    /// Obtiene un post de blog específico por slug
    /// </summary>
    [HttpGet("{slug}")]
    public async Task<ActionResult<BlogPostDetailDto>> GetBlogPost(string slug)
    {
        try
        {
            var post = await _context.Pages
                .Where(p => p.Slug == slug &&
                           p.IsPublished &&
                           p.PublishedAt != null &&
                           p.PublishedAt <= DateTime.UtcNow &&
                           (p.Template == "Blog" || p.Template == "blog" || string.IsNullOrEmpty(p.Template)))
                .Select(p => new BlogPostDetailDto
                {
                    Id = p.Id,
                    Title = p.Title,
                    Slug = p.Slug,
                    Content = p.Content,
                    Excerpt = p.Excerpt ?? string.Empty,
                    PublishedAt = p.PublishedAt!.Value,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt,
                    MetaTitle = p.MetaTitle,
                    MetaDescription = p.MetaDescription,
                    MetaKeywords = p.MetaKeywords
                })
                .FirstOrDefaultAsync();

            if (post == null)
            {
                return NotFound(new { message = "Post de blog no encontrado" });
            }

            return Ok(post);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener post de blog con slug: {Slug}", slug);
            throw;
        }
    }

    /// <summary>
    /// Obtiene los posts más recientes (útil para sidebar o home)
    /// </summary>
    /// <param name="limit">Número máximo de posts a retornar (default: 5, max: 20)</param>
    [HttpGet("recent")]
    public async Task<ActionResult<IEnumerable<BlogPostDto>>> GetRecentPosts([FromQuery] int limit = 5)
    {
        try
        {
            if (limit < 1) limit = 5;
            if (limit > 20) limit = 20;

            var posts = await _context.Pages
                .Where(p => p.IsPublished &&
                           p.PublishedAt != null &&
                           p.PublishedAt <= DateTime.UtcNow &&
                           (p.Template == "Blog" || p.Template == "blog" || string.IsNullOrEmpty(p.Template)))
                .OrderByDescending(p => p.PublishedAt)
                .Take(limit)
                .Select(p => new BlogPostDto
                {
                    Id = p.Id,
                    Title = p.Title,
                    Slug = p.Slug,
                    Excerpt = p.Excerpt ?? string.Empty,
                    PublishedAt = p.PublishedAt!.Value,
                    CreatedAt = p.CreatedAt,
                    MetaTitle = p.MetaTitle,
                    MetaDescription = p.MetaDescription
                })
                .ToListAsync();

            return Ok(posts);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener posts recientes");
            throw;
        }
    }
}

// DTOs
public class BlogPostDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public string Excerpt { get; set; } = string.Empty;
    public DateTime PublishedAt { get; set; }
    public DateTime CreatedAt { get; set; }
    public string? MetaTitle { get; set; }
    public string? MetaDescription { get; set; }
}

public class BlogPostDetailDto : BlogPostDto
{
    public string Content { get; set; } = string.Empty;
    public DateTime? UpdatedAt { get; set; }
    public string? MetaKeywords { get; set; }
}

public class BlogPostsResponseDto
{
    public List<BlogPostDto> Posts { get; set; } = new();
    public int TotalCount { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalPages { get; set; }
    public bool HasNextPage { get; set; }
    public bool HasPreviousPage { get; set; }
}

