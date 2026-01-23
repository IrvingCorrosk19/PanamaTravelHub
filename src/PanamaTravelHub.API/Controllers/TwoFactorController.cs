using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Infrastructure.Data;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using OtpNet;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/auth/2fa")]
[Authorize(Policy = "AdminOrCustomer")]
public class TwoFactorController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<TwoFactorController> _logger;

    public TwoFactorController(
        ApplicationDbContext context,
        ILogger<TwoFactorController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Habilita 2FA para el usuario actual
    /// </summary>
    [HttpPost("enable")]
    public async Task<ActionResult<TwoFactorSetupDto>> Enable2FA()
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

            // Verificar si ya tiene 2FA habilitado
            var existing2FA = await _context.UserTwoFactors
                .FirstOrDefaultAsync(ut => ut.UserId == userId);

            if (existing2FA != null && existing2FA.IsEnabled)
            {
                return BadRequest(new { message = "2FA ya está habilitado para tu cuenta" });
            }

            // Generar clave secreta TOTP
            var secretBytes = new byte[20];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(secretBytes);
            }
            var secretKey = Base32Encoding.ToString(secretBytes);

            // Generar backup codes
            var backupCodes = new List<string>();
            for (int i = 0; i < 10; i++)
            {
                var code = GenerateBackupCode();
                backupCodes.Add(code);
            }

            // Hashear backup codes antes de guardar
            var hashedBackupCodes = backupCodes.Select(code => 
                Convert.ToBase64String(SHA256.HashData(Encoding.UTF8.GetBytes(code)))
            ).ToList();

            if (existing2FA == null)
            {
                existing2FA = new UserTwoFactor
                {
                    UserId = userId,
                    SecretKey = secretKey,
                    IsEnabled = false, // Se habilitará después de verificar
                    BackupCodes = System.Text.Json.JsonSerializer.Serialize(hashedBackupCodes),
                    EnabledAt = null
                };
                _context.UserTwoFactors.Add(existing2FA);
            }
            else
            {
                existing2FA.SecretKey = secretKey;
                existing2FA.BackupCodes = System.Text.Json.JsonSerializer.Serialize(hashedBackupCodes);
                existing2FA.IsEnabled = false;
            }

            await _context.SaveChangesAsync();

            // Generar QR code URL para Google Authenticator
            var issuer = "PanamaTravelHub";
            var accountName = user.Email;
            var qrCodeUrl = $"otpauth://totp/{Uri.EscapeDataString(issuer)}:{Uri.EscapeDataString(accountName)}?secret={secretKey}&issuer={Uri.EscapeDataString(issuer)}";

            return Ok(new TwoFactorSetupDto
            {
                SecretKey = secretKey,
                QrCodeUrl = qrCodeUrl,
                BackupCodes = backupCodes, // Solo se muestran una vez
                Message = "Escanea el código QR con Google Authenticator y luego verifica con un código"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al habilitar 2FA");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Verifica el código 2FA y completa la habilitación
    /// </summary>
    [HttpPost("verify")]
    public async Task<ActionResult> Verify2FA([FromBody] Verify2FARequestDto request)
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var twoFactor = await _context.UserTwoFactors
                .FirstOrDefaultAsync(ut => ut.UserId == userId);

            if (twoFactor == null || string.IsNullOrEmpty(twoFactor.SecretKey))
            {
                return BadRequest(new { message = "Primero debes habilitar 2FA" });
            }

            // Verificar código TOTP
            var secretBytes = Base32Encoding.ToBytes(twoFactor.SecretKey);
            var totp = new Totp(secretBytes);
            var isValid = totp.VerifyTotp(request.Code, out _, new VerificationWindow(1, 1));

            if (!isValid)
            {
                return BadRequest(new { message = "Código 2FA inválido" });
            }

            // Habilitar 2FA
            twoFactor.IsEnabled = true;
            twoFactor.EnabledAt = DateTime.UtcNow;
            twoFactor.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "2FA habilitado exitosamente" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al verificar 2FA");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Deshabilita 2FA para el usuario actual
    /// </summary>
    [HttpPost("disable")]
    public async Task<ActionResult> Disable2FA([FromBody] Disable2FARequestDto request)
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var twoFactor = await _context.UserTwoFactors
                .FirstOrDefaultAsync(ut => ut.UserId == userId);

            if (twoFactor == null || !twoFactor.IsEnabled)
            {
                return BadRequest(new { message = "2FA no está habilitado" });
            }

            // Verificar código antes de deshabilitar
            if (!string.IsNullOrEmpty(twoFactor.SecretKey))
            {
                var secretBytes = Base32Encoding.ToBytes(twoFactor.SecretKey);
                var totp = new Totp(secretBytes);
                var isValid = totp.VerifyTotp(request.Code, out _, new VerificationWindow(1, 1));

                if (!isValid)
                {
                    // Intentar con backup code
                    if (string.IsNullOrEmpty(request.BackupCode))
                    {
                        return BadRequest(new { message = "Código 2FA inválido" });
                    }

                    var backupCodes = System.Text.Json.JsonSerializer.Deserialize<List<string>>(twoFactor.BackupCodes ?? "[]") ?? new List<string>();
                    var hashedInput = Convert.ToBase64String(SHA256.HashData(Encoding.UTF8.GetBytes(request.BackupCode)));

                    if (!backupCodes.Contains(hashedInput))
                    {
                        return BadRequest(new { message = "Código de respaldo inválido" });
                    }

                    // Remover backup code usado
                    backupCodes.Remove(hashedInput);
                    twoFactor.BackupCodes = System.Text.Json.JsonSerializer.Serialize(backupCodes);
                }
            }

            // Deshabilitar 2FA
            twoFactor.IsEnabled = false;
            twoFactor.SecretKey = null;
            twoFactor.BackupCodes = null;
            twoFactor.EnabledAt = null;
            twoFactor.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "2FA deshabilitado exitosamente" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al deshabilitar 2FA");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Verifica código 2FA durante el login
    /// </summary>
    [HttpPost("verify-login")]
    [AllowAnonymous]
    public async Task<ActionResult<Verify2FALoginResponseDto>> VerifyLogin2FA([FromBody] Verify2FALoginRequestDto request)
    {
        try
        {
            // Buscar usuario por email (ya autenticado con password)
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email.ToLower() == request.Email.ToLower());

            if (user == null)
            {
                return BadRequest(new { message = "Usuario no encontrado" });
            }

            var twoFactor = await _context.UserTwoFactors
                .FirstOrDefaultAsync(ut => ut.UserId == user.Id);

            if (twoFactor == null || !twoFactor.IsEnabled)
            {
                return BadRequest(new { message = "2FA no está habilitado para este usuario" });
            }

            // Verificar código TOTP
            bool isValid = false;
            if (!string.IsNullOrEmpty(twoFactor.SecretKey))
            {
                var secretBytes = Base32Encoding.ToBytes(twoFactor.SecretKey);
                var totp = new Totp(secretBytes);
                isValid = totp.VerifyTotp(request.Code, out _, new VerificationWindow(1, 1));
            }

            // Si no es válido, intentar con backup code
            if (!isValid && !string.IsNullOrEmpty(request.BackupCode))
            {
                var backupCodes = System.Text.Json.JsonSerializer.Deserialize<List<string>>(twoFactor.BackupCodes ?? "[]") ?? new List<string>();
                var hashedInput = Convert.ToBase64String(SHA256.HashData(Encoding.UTF8.GetBytes(request.BackupCode)));

                if (backupCodes.Contains(hashedInput))
                {
                    isValid = true;
                    // Remover backup code usado
                    backupCodes.Remove(hashedInput);
                    twoFactor.BackupCodes = System.Text.Json.JsonSerializer.Serialize(backupCodes);
                    twoFactor.UpdatedAt = DateTime.UtcNow;
                    await _context.SaveChangesAsync();
                }
            }

            if (!isValid)
            {
                return BadRequest(new { message = "Código 2FA inválido" });
            }

            // Actualizar último uso
            twoFactor.LastUsedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new Verify2FALoginResponseDto
            {
                IsValid = true,
                Message = "Código 2FA verificado correctamente"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al verificar 2FA en login");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Obtiene el estado de 2FA del usuario actual
    /// </summary>
    [HttpGet("status")]
    public async Task<ActionResult<TwoFactorStatusDto>> Get2FAStatus()
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var twoFactor = await _context.UserTwoFactors
                .FirstOrDefaultAsync(ut => ut.UserId == userId);

            var result = new TwoFactorStatusDto
            {
                IsEnabled = twoFactor != null && twoFactor.IsEnabled,
                IsSmsEnabled = twoFactor?.IsSmsEnabled ?? false,
                EnabledAt = twoFactor?.EnabledAt,
                LastUsedAt = twoFactor?.LastUsedAt
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener estado de 2FA");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    // Helper methods
    private string GenerateBackupCode()
    {
        const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        var random = new Random();
        return new string(Enumerable.Repeat(chars, 8)
            .Select(s => s[random.Next(s.Length)]).ToArray());
    }
}

// DTOs
public class TwoFactorSetupDto
{
    public string SecretKey { get; set; } = string.Empty;
    public string QrCodeUrl { get; set; } = string.Empty;
    public List<string> BackupCodes { get; set; } = new();
    public string Message { get; set; } = string.Empty;
}

public class Verify2FARequestDto
{
    public string Code { get; set; } = string.Empty;
}

public class Disable2FARequestDto
{
    public string? Code { get; set; }
    public string? BackupCode { get; set; }
}

public class Verify2FALoginRequestDto
{
    public string Email { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string? BackupCode { get; set; }
}

public class Verify2FALoginResponseDto
{
    public bool IsValid { get; set; }
    public string Message { get; set; } = string.Empty;
}

public class TwoFactorStatusDto
{
    public bool IsEnabled { get; set; }
    public bool IsSmsEnabled { get; set; }
    public DateTime? EnabledAt { get; set; }
    public DateTime? LastUsedAt { get; set; }
}
