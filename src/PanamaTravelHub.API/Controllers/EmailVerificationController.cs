using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Infrastructure.Data;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/auth/email-verification")]
public class EmailVerificationController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<EmailVerificationController> _logger;
    private readonly IEmailNotificationService _emailNotificationService;

    public EmailVerificationController(
        ApplicationDbContext context,
        ILogger<EmailVerificationController> logger,
        IEmailNotificationService emailNotificationService)
    {
        _context = context;
        _logger = logger;
        _emailNotificationService = emailNotificationService;
    }

    /// <summary>
    /// Envía email de verificación
    /// </summary>
    [HttpPost("send")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult> SendVerificationEmail()
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return NotFound(new { message = "Usuario no encontrado" });
            }

            if (user.EmailVerified)
            {
                return BadRequest(new { message = "Tu email ya está verificado" });
            }

            // Generar nuevo token si no existe
            if (string.IsNullOrEmpty(user.EmailVerificationToken))
            {
                user.EmailVerificationToken = Guid.NewGuid().ToString("N");
                await _context.SaveChangesAsync();
            }

            // Generar link de verificación
            var verificationLink = $"{Request.Scheme}://{Request.Host}/verify-email.html?token={user.EmailVerificationToken}";

            // Enviar email de verificación
            try
            {
                await _emailNotificationService.QueueTemplatedEmailAsync(
                    user.Email,
                    "Verifica tu correo electrónico - PanamaTravelHub",
                    "email-verification",
                    new
                    {
                        CustomerName = $"{user.FirstName} {user.LastName}",
                        VerificationLink = verificationLink,
                        Year = DateTime.UtcNow.Year
                    },
                    Domain.Enums.EmailNotificationType.EmailVerification,
                    user.Id,
                    null
                );
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al enviar email de verificación");
                // No fallar si el email no se puede enviar
            }

            return Ok(new { message = "Email de verificación enviado. Revisa tu bandeja de entrada." });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al enviar email de verificación");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Verifica el email con el token
    /// </summary>
    [HttpPost("verify")]
    [AllowAnonymous]
    public async Task<ActionResult> VerifyEmail([FromBody] VerifyEmailRequestDto request)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(request.Token))
            {
                return BadRequest(new { message = "Token de verificación requerido" });
            }

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.EmailVerificationToken == request.Token);

            if (user == null)
            {
                return BadRequest(new { message = "Token de verificación inválido o expirado" });
            }

            if (user.EmailVerified)
            {
                return BadRequest(new { message = "Este email ya está verificado" });
            }

            // Verificar email
            user.EmailVerified = true;
            user.EmailVerifiedAt = DateTime.UtcNow;
            user.EmailVerificationToken = null; // Limpiar token usado
            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            _logger.LogInformation("Email verificado exitosamente para usuario: {Email}", user.Email);

            return Ok(new { message = "Email verificado exitosamente" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al verificar email");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Obtiene el estado de verificación del email del usuario actual
    /// </summary>
    [HttpGet("status")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult<EmailVerificationStatusDto>> GetVerificationStatus()
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return NotFound(new { message = "Usuario no encontrado" });
            }

            var result = new EmailVerificationStatusDto
            {
                IsVerified = user.EmailVerified,
                VerifiedAt = user.EmailVerifiedAt,
                Email = user.Email
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener estado de verificación");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }
}

// DTOs
public class VerifyEmailRequestDto
{
    public string Token { get; set; } = string.Empty;
}

public class EmailVerificationStatusDto
{
    public bool IsVerified { get; set; }
    public DateTime? VerifiedAt { get; set; }
    public string Email { get; set; } = string.Empty;
}
