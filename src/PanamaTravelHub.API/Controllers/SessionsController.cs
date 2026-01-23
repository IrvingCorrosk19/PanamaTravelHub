using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Infrastructure.Data;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/auth/sessions")]
[Authorize(Policy = "AdminOrCustomer")]
public class SessionsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<SessionsController> _logger;

    public SessionsController(
        ApplicationDbContext context,
        ILogger<SessionsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Obtiene todas las sesiones activas del usuario actual
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<SessionDto>>> GetSessions()
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var currentTokenId = User.FindFirst("jti")?.Value; // JWT ID del token actual

            var refreshTokens = await _context.RefreshTokens
                .Where(rt => rt.UserId == userId && 
                           !rt.IsRevoked && 
                           rt.ExpiresAt > DateTime.UtcNow)
                .OrderByDescending(rt => rt.CreatedAt)
                .Select(rt => new SessionDto
                {
                    TokenId = rt.Id.ToString(),
                    IpAddress = rt.IpAddress ?? "Unknown",
                    UserAgent = rt.UserAgent ?? "Unknown",
                    CreatedAt = rt.CreatedAt,
                    ExpiresAt = rt.ExpiresAt,
                    IsCurrent = rt.Id.ToString() == currentTokenId
                })
                .ToListAsync();

            return Ok(refreshTokens);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener sesiones");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Cierra una sesión específica
    /// </summary>
    [HttpDelete("{tokenId}")]
    public async Task<ActionResult> CloseSession(Guid tokenId)
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var refreshToken = await _context.RefreshTokens
                .FirstOrDefaultAsync(rt => rt.Id == tokenId && rt.UserId == userId);

            if (refreshToken == null)
            {
                return NotFound(new { message = "Sesión no encontrada" });
            }

            if (refreshToken.IsRevoked)
            {
                return BadRequest(new { message = "Esta sesión ya está cerrada" });
            }

            refreshToken.IsRevoked = true;
            refreshToken.RevokedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Sesión cerrada exitosamente" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al cerrar sesión {TokenId}", tokenId);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Cierra todas las sesiones excepto la actual
    /// </summary>
    [HttpPost("close-all-others")]
    public async Task<ActionResult> CloseAllOtherSessions()
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var currentTokenId = User.FindFirst("jti")?.Value;

            var otherTokens = await _context.RefreshTokens
                .Where(rt => rt.UserId == userId && 
                           !rt.IsRevoked && 
                           rt.ExpiresAt > DateTime.UtcNow &&
                           (currentTokenId == null || rt.Id.ToString() != currentTokenId))
                .ToListAsync();

            foreach (var token in otherTokens)
            {
                token.IsRevoked = true;
                token.RevokedAt = DateTime.UtcNow;
            }

            if (otherTokens.Any())
            {
                await _context.SaveChangesAsync();
            }

            return Ok(new { message = $"Se cerraron {otherTokens.Count} sesiones" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al cerrar otras sesiones");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }
}

// DTOs
public class SessionDto
{
    public string TokenId { get; set; } = string.Empty;
    public string IpAddress { get; set; } = string.Empty;
    public string UserAgent { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime ExpiresAt { get; set; }
    public bool IsCurrent { get; set; }
}
