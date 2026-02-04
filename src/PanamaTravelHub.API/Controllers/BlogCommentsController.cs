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
[Route("api/blog/comments")]
public class BlogCommentsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<BlogCommentsController> _logger;

    public BlogCommentsController(
        ApplicationDbContext context,
        ILogger<BlogCommentsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Obtiene comentarios de un post de blog (público, solo aprobados)
    /// </summary>
    [HttpGet("post/{blogPostId}")]
    public async Task<ActionResult<BlogCommentsResponseDto>> GetComments(
        Guid blogPostId,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        [FromQuery] Guid? parentCommentId = null) // Para obtener solo respuestas
    {
        try
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 20;
            if (pageSize > 100) pageSize = 100;

            var query = _context.BlogComments
                .Where(c => c.BlogPostId == blogPostId &&
                           c.Status == BlogCommentStatus.Approved);

            // Si se especifica parentCommentId, obtener solo respuestas
            if (parentCommentId.HasValue)
            {
                query = query.Where(c => c.ParentCommentId == parentCommentId.Value);
            }
            else
            {
                // Solo comentarios principales (sin padre)
                query = query.Where(c => c.ParentCommentId == null);
            }

            var totalCount = await query.CountAsync();

            var comments = await query
                .OrderByDescending(c => c.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(c => new BlogCommentDto
                {
                    Id = c.Id,
                    BlogPostId = c.BlogPostId,
                    UserId = c.UserId,
                    ParentCommentId = c.ParentCommentId,
                    AuthorName = c.AuthorName,
                    AuthorEmail = c.UserId.HasValue ? null : c.AuthorEmail, // Ocultar email si es usuario registrado
                    AuthorWebsite = c.AuthorWebsite,
                    Content = c.Content,
                    Likes = c.Likes,
                    Dislikes = c.Dislikes,
                    CreatedAt = c.CreatedAt,
                    UpdatedAt = c.UpdatedAt,
                    ReplyCount = _context.BlogComments.Count(r => r.ParentCommentId == c.Id && r.Status == BlogCommentStatus.Approved)
                })
                .ToListAsync();

            return Ok(new BlogCommentsResponseDto
            {
                Comments = comments.Cast<object>().ToList(),
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize,
                TotalPages = (int)Math.Ceiling(totalCount / (double)pageSize)
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener comentarios del blog post {BlogPostId}", blogPostId);
            return StatusCode(500, new { message = "Error al obtener comentarios" });
        }
    }

    /// <summary>
    /// Crea un nuevo comentario (público, requiere autenticación opcional)
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<BlogCommentDto>> CreateComment([FromBody] CreateBlogCommentRequestDto request)
    {
        try
        {
            // Validar que el post existe
            var blogPost = await _context.Pages
                .FirstOrDefaultAsync(p => p.Id == request.BlogPostId &&
                                         (p.Template == "Blog" || p.Template == "blog"));
            
            if (blogPost == null)
            {
                return NotFound(new { message = "Post de blog no encontrado" });
            }

            // Validar comentario padre si existe
            if (request.ParentCommentId.HasValue)
            {
                var parentComment = await _context.BlogComments
                    .FirstOrDefaultAsync(c => c.Id == request.ParentCommentId.Value);
                
                if (parentComment == null)
                {
                    return BadRequest(new { message = "Comentario padre no encontrado" });
                }
            }

            // Obtener usuario si está autenticado
            Guid? userId = null;
            string? userEmail = null;
            string? userName = null;

            var token = Request.Headers["Authorization"].ToString().Replace("Bearer ", "");
            if (!string.IsNullOrEmpty(token))
            {
                try
                {
                    var handler = new JwtSecurityTokenHandler();
                    var jsonToken = handler.ReadJwtToken(token);
                    var userIdClaim = jsonToken.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier);
                    if (userIdClaim != null && Guid.TryParse(userIdClaim.Value, out var parsedUserId))
                    {
                        userId = parsedUserId;
                        var user = await _context.Users.FindAsync(userId);
                        if (user != null)
                        {
                            userEmail = user.Email;
                            userName = $"{user.FirstName} {user.LastName}".Trim();
                        }
                    }
                }
                catch
                {
                    // Token inválido, continuar como anónimo
                }
            }

            var comment = new BlogComment
            {
                BlogPostId = request.BlogPostId,
                UserId = userId,
                ParentCommentId = request.ParentCommentId,
                AuthorName = userName ?? request.AuthorName,
                AuthorEmail = userEmail ?? request.AuthorEmail,
                AuthorWebsite = request.AuthorWebsite,
                Content = request.Content,
                Status = BlogCommentStatus.Pending, // Requiere moderación
                UserIp = HttpContext.Connection.RemoteIpAddress?.ToString(),
                UserAgent = Request.Headers["User-Agent"].ToString()
            };

            _context.BlogComments.Add(comment);
            await _context.SaveChangesAsync();

            var commentDto = new BlogCommentDto
            {
                Id = comment.Id,
                BlogPostId = comment.BlogPostId,
                UserId = comment.UserId,
                ParentCommentId = comment.ParentCommentId,
                AuthorName = comment.AuthorName,
                AuthorEmail = userId.HasValue ? null : comment.AuthorEmail,
                AuthorWebsite = comment.AuthorWebsite,
                Content = comment.Content,
                Likes = comment.Likes,
                Dislikes = comment.Dislikes,
                CreatedAt = comment.CreatedAt,
                UpdatedAt = comment.UpdatedAt,
                ReplyCount = 0
            };

            return CreatedAtAction(nameof(GetComment), new { id = comment.Id }, commentDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear comentario");
            return StatusCode(500, new { message = "Error al crear comentario" });
        }
    }

    /// <summary>
    /// Obtiene un comentario específico (público)
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<BlogCommentDto>> GetComment(Guid id)
    {
        var comment = await _context.BlogComments
            .Where(c => c.Id == id && c.Status == BlogCommentStatus.Approved)
            .Select(c => new BlogCommentDto
            {
                Id = c.Id,
                BlogPostId = c.BlogPostId,
                UserId = c.UserId,
                ParentCommentId = c.ParentCommentId,
                AuthorName = c.AuthorName,
                AuthorEmail = c.UserId.HasValue ? null : c.AuthorEmail,
                AuthorWebsite = c.AuthorWebsite,
                Content = c.Content,
                Likes = c.Likes,
                Dislikes = c.Dislikes,
                CreatedAt = c.CreatedAt,
                UpdatedAt = c.UpdatedAt,
                ReplyCount = _context.BlogComments.Count(r => r.ParentCommentId == c.Id && r.Status == BlogCommentStatus.Approved)
            })
            .FirstOrDefaultAsync();

        if (comment == null)
        {
            return NotFound(new { message = "Comentario no encontrado" });
        }

        return Ok(comment);
    }

    /// <summary>
    /// Actualiza un comentario (solo el autor o admin)
    /// </summary>
    [HttpPut("{id}")]
    [Authorize]
    public async Task<ActionResult<BlogCommentDto>> UpdateComment(Guid id, [FromBody] UpdateBlogCommentRequestDto request)
    {
        var comment = await _context.BlogComments.FindAsync(id);
        if (comment == null)
        {
            return NotFound(new { message = "Comentario no encontrado" });
        }

        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var isAdmin = User.IsInRole("Admin");

        // Solo el autor o admin puede editar
        if (comment.UserId != userId && !isAdmin)
        {
            return Forbid();
        }

        comment.Content = request.Content;
        if (request.AuthorWebsite != null)
        {
            comment.AuthorWebsite = request.AuthorWebsite;
        }

        await _context.SaveChangesAsync();

        var commentDto = new BlogCommentDto
        {
            Id = comment.Id,
            BlogPostId = comment.BlogPostId,
            UserId = comment.UserId,
            ParentCommentId = comment.ParentCommentId,
            AuthorName = comment.AuthorName,
            AuthorEmail = comment.UserId.HasValue ? null : comment.AuthorEmail,
            AuthorWebsite = comment.AuthorWebsite,
            Content = comment.Content,
            Likes = comment.Likes,
            Dislikes = comment.Dislikes,
            CreatedAt = comment.CreatedAt,
            UpdatedAt = comment.UpdatedAt,
            ReplyCount = await _context.BlogComments.CountAsync(r => r.ParentCommentId == comment.Id && r.Status == BlogCommentStatus.Approved)
        };

        return Ok(commentDto);
    }

    /// <summary>
    /// Elimina un comentario (solo el autor o admin)
    /// </summary>
    [HttpDelete("{id}")]
    [Authorize]
    public async Task<IActionResult> DeleteComment(Guid id)
    {
        var comment = await _context.BlogComments.FindAsync(id);
        if (comment == null)
        {
            return NotFound(new { message = "Comentario no encontrado" });
        }

        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var isAdmin = User.IsInRole("Admin");

        // Solo el autor o admin puede eliminar
        if (comment.UserId != userId && !isAdmin)
        {
            return Forbid();
        }

        _context.BlogComments.Remove(comment);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    /// <summary>
    /// Like/Dislike de un comentario (público)
    /// </summary>
    [HttpPost("{id}/like")]
    public async Task<ActionResult> LikeComment(Guid id, [FromBody] LikeCommentRequestDto request)
    {
        var comment = await _context.BlogComments.FindAsync(id);
        if (comment == null)
        {
            return NotFound(new { message = "Comentario no encontrado" });
        }

        if (request.IsLike)
        {
            comment.Likes++;
        }
        else
        {
            comment.Dislikes++;
        }

        await _context.SaveChangesAsync();

        return Ok(new { likes = comment.Likes, dislikes = comment.Dislikes });
    }

    // ========== ENDPOINTS ADMIN ==========

    /// <summary>
    /// Lista todos los comentarios (Admin) con filtros
    /// </summary>
    [HttpGet("admin")]
    [Authorize]
    public async Task<ActionResult<BlogCommentsResponseDto>> GetAllComments(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50,
        [FromQuery] BlogCommentStatus? status = null,
        [FromQuery] Guid? blogPostId = null)
    {
        try
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 50;
            if (pageSize > 100) pageSize = 100;

            var query = _context.BlogComments.AsQueryable();

            if (status.HasValue)
            {
                query = query.Where(c => c.Status == status.Value);
            }

            if (blogPostId.HasValue)
            {
                query = query.Where(c => c.BlogPostId == blogPostId.Value);
            }

            var totalCount = await query.CountAsync();

            var comments = await query
                .OrderByDescending(c => c.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(c => new BlogCommentAdminDto
                {
                    Id = c.Id,
                    BlogPostId = c.BlogPostId,
                    BlogPostTitle = _context.Pages.Where(p => p.Id == c.BlogPostId).Select(p => p.Title).FirstOrDefault() ?? "",
                    UserId = c.UserId,
                    UserEmail = c.User != null ? c.User.Email : null,
                    ParentCommentId = c.ParentCommentId,
                    AuthorName = c.AuthorName,
                    AuthorEmail = c.AuthorEmail,
                    AuthorWebsite = c.AuthorWebsite,
                    Content = c.Content,
                    Status = c.Status,
                    AdminNotes = c.AdminNotes,
                    UserIp = c.UserIp,
                    UserAgent = c.UserAgent,
                    Likes = c.Likes,
                    Dislikes = c.Dislikes,
                    CreatedAt = c.CreatedAt,
                    UpdatedAt = c.UpdatedAt,
                    ReplyCount = _context.BlogComments.Count(r => r.ParentCommentId == c.Id)
                })
                .ToListAsync();

            return Ok(new BlogCommentsResponseDto
            {
                Comments = comments.Cast<object>().ToList(),
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize,
                TotalPages = (int)Math.Ceiling(totalCount / (double)pageSize)
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener comentarios (admin)");
            return StatusCode(500, new { message = "Error al obtener comentarios" });
        }
    }

    /// <summary>
    /// Modera un comentario (Admin)
    /// </summary>
    [HttpPost("{id}/moderate")]
    [Authorize]
    public async Task<ActionResult> ModerateComment(Guid id, [FromBody] ModerateCommentRequestDto request)
    {
        var comment = await _context.BlogComments.FindAsync(id);
        if (comment == null)
        {
            return NotFound(new { message = "Comentario no encontrado" });
        }

        comment.Status = request.Status;
        comment.AdminNotes = request.AdminNotes;

        await _context.SaveChangesAsync();

        return Ok(new { message = "Comentario moderado exitosamente" });
    }
}

// DTOs
public class BlogCommentDto
{
    public Guid Id { get; set; }
    public Guid BlogPostId { get; set; }
    public Guid? UserId { get; set; }
    public Guid? ParentCommentId { get; set; }
    public string AuthorName { get; set; } = string.Empty;
    public string? AuthorEmail { get; set; }
    public string? AuthorWebsite { get; set; }
    public string Content { get; set; } = string.Empty;
    public int Likes { get; set; }
    public int Dislikes { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public int ReplyCount { get; set; }
}

public class BlogCommentAdminDto : BlogCommentDto
{
    public BlogCommentStatus Status { get; set; }
    public string? AdminNotes { get; set; }
    public string? UserIp { get; set; }
    public string? UserAgent { get; set; }
    public string? UserEmail { get; set; }
    public string BlogPostTitle { get; set; } = string.Empty;
}

public class BlogCommentsResponseDto
{
    public List<object> Comments { get; set; } = new();
    public int TotalCount { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalPages { get; set; }
}

public class CreateBlogCommentRequestDto
{
    public Guid BlogPostId { get; set; }
    public Guid? ParentCommentId { get; set; }
    public string AuthorName { get; set; } = string.Empty;
    public string AuthorEmail { get; set; } = string.Empty;
    public string? AuthorWebsite { get; set; }
    public string Content { get; set; } = string.Empty;
}

public class UpdateBlogCommentRequestDto
{
    public string Content { get; set; } = string.Empty;
    public string? AuthorWebsite { get; set; }
}

public class LikeCommentRequestDto
{
    public bool IsLike { get; set; } // true = like, false = dislike
}

public class ModerateCommentRequestDto
{
    public BlogCommentStatus Status { get; set; }
    public string? AdminNotes { get; set; }
}
