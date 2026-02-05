using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Application.Exceptions;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Application.Validators;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Domain.Enums;
using PanamaTravelHub.Infrastructure.Data;
using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Cryptography;
using OtpNet;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly ILogger<AuthController> _logger;
    private readonly ApplicationDbContext _context;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtService _jwtService;
    private readonly IConfiguration _configuration;
    private readonly IEmailNotificationService _emailNotificationService;

    public AuthController(
        ILogger<AuthController> logger,
        ApplicationDbContext context,
        IPasswordHasher passwordHasher,
        IJwtService jwtService,
        IConfiguration configuration,
        IEmailNotificationService emailNotificationService)
    {
        _logger = logger;
        _context = context;
        _passwordHasher = passwordHasher;
        _jwtService = jwtService;
        _configuration = configuration;
        _emailNotificationService = emailNotificationService;
    }

    /// <summary>
    /// Registro de nuevo usuario
    /// </summary>
    [HttpPost("register")]
    [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status409Conflict)]
    public async Task<ActionResult<AuthResponseDto>> Register([FromBody] RegisterRequestDto request)
    {
        try
        {
        _logger.LogInformation("=== INICIO Registro de usuario ===");
        var emailPreview = !string.IsNullOrEmpty(request.Email) && request.Email.Length > 5
            ? request.Email.Substring(0, 5) + "***"
            : "***";
        _logger.LogInformation("[REGISTER] Request recibido | Email: {Email} | FirstName length: {FirstNameLen} | LastName length: {LastNameLen} | Password present: {HasPassword} | ConfirmPassword present: {HasConfirm}",
            emailPreview,
            request.FirstName?.Length ?? 0,
            request.LastName?.Length ?? 0,
            !string.IsNullOrEmpty(request.Password),
            !string.IsNullOrEmpty(request.ConfirmPassword));

        // Verificar si el usuario ya existe (validación temprana)
        var emailToCheck = request.Email?.ToLower().Trim() ?? string.Empty;
        var existingUser = await _context.Users
            .FirstOrDefaultAsync(u => u.Email.ToLower() == emailToCheck);

        if (existingUser != null)
        {
            _logger.LogWarning("[REGISTER] Email ya existente, rechazando con 409 | Email: {Email}", emailPreview);
            // Devolver 409 Conflict para email duplicado
            return Conflict(new ProblemDetails
            {
                Title = "Email ya registrado",
                Detail = "Este correo electrónico ya está registrado. Por favor usa otro correo o inicia sesión.",
                Status = StatusCodes.Status409Conflict,
                Extensions = { ["errorCode"] = "EMAIL_ALREADY_EXISTS" }
            });
        }

        // Hashear password con BCrypt
        var passwordHash = _passwordHasher.HashPassword(request.Password?.Trim() ?? string.Empty);

        // Crear usuario
        var user = new User
        {
            Email = request.Email?.Trim().ToLower() ?? string.Empty,
            PasswordHash = passwordHash,
            FirstName = request.FirstName?.Trim() ?? string.Empty,
            LastName = request.LastName?.Trim() ?? string.Empty,
            IsActive = true,
            EmailVerified = false, // Requiere verificación
            EmailVerificationToken = Guid.NewGuid().ToString("N") // Token para verificación
        };

        await _context.Users.AddAsync(user);
        await _context.SaveChangesAsync();

        // Enviar email de verificación (en background)
        try
        {
            var verificationLink = $"{Request.Scheme}://{Request.Host}/verify-email.html?token={user.EmailVerificationToken}";
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
                EmailNotificationType.EmailVerification,
                user.Id,
                null
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al enviar email de verificación después del registro");
            // No fallar el registro si falla el email
        }

            // Asignar rol Customer por defecto
            var customerRole = await _context.Roles.FirstOrDefaultAsync(r => r.Name == "Customer");
            if (customerRole != null)
            {
                var userRole = new Domain.Entities.UserRole
                {
                    UserId = user.Id,
                    RoleId = customerRole.Id
                };
                await _context.UserRoles.AddAsync(userRole);
                await _context.SaveChangesAsync();
                _logger.LogInformation("[REGISTER] Rol Customer asignado al usuario {UserId}", user.Id);
            }
            else
            {
                _logger.LogWarning("[REGISTER] Rol 'Customer' no encontrado en BD. El usuario {UserId} no tiene rol asignado.", user.Id);
            }

        _logger.LogInformation("[REGISTER] Usuario creado en BD | Email: {Email}, ID: {UserId}", user.Email, user.Id);

        // Generar tokens
        var roles = new List<string> { "Customer" };
        var accessToken = _jwtService.GenerateAccessToken(user.Id, user.Email, roles);
        var refreshToken = await CreateRefreshTokenAsync(user.Id);

        // SPA: redirigir a reservas.html (no /Reservas que es Razor)
        var redirectUrl = "/reservas.html";

        _logger.LogInformation("[REGISTER] Registro exitoso | RedirectUrl: {RedirectUrl} | UserId: {UserId}", redirectUrl, user.Id);

        // Devolver 201 Created (según especificaciones)
        return CreatedAtAction(nameof(GetCurrentUser), new { id = user.Id }, new AuthResponseDto
        {
            AccessToken = accessToken,
            RefreshToken = refreshToken.Token,
            User = new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Roles = roles
            },
            RedirectUrl = redirectUrl
        });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[REGISTER] Error no controlado | Tipo: {Type} | Mensaje: {Message} | Inner: {Inner}",
                ex.GetType().Name, ex.Message, ex.InnerException?.Message ?? "(null)");
            throw;
        }
    }

    /// <summary>
    /// Login de usuario
    /// </summary>
    [HttpPost("login")]
    [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<AuthResponseDto>> Login([FromBody] LoginRequestDto request)
    {
        try
        {
            _logger.LogInformation("Intento de login: {Email}", request.Email);

            // Buscar usuario con roles
            var user = await _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Email.ToLower() == request.Email.ToLower().Trim());

            if (user == null)
            {
                // No revelar que el usuario no existe (protección contra user enumeration)
                // Delay aleatorio entre 300-700ms para evitar timing attacks
                var randomDelay = new Random().Next(300, 700);
                await Task.Delay(randomDelay);
                
                // Registrar intento fallido (sin userId porque no existe)
                var failedLoginHistory = new LoginHistory
                {
                    UserId = Guid.Empty, // Usuario no encontrado
                    IpAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown",
                    UserAgent = Request.Headers["User-Agent"].ToString(),
                    IsSuccessful = false,
                    FailureReason = "Usuario no encontrado"
                };
                _context.LoginHistories.Add(failedLoginHistory);
                await _context.SaveChangesAsync();
                
                _logger.LogWarning("Intento de login fallido: email no encontrado");
                return Unauthorized(new ProblemDetails
                {
                    Title = "Credenciales inválidas",
                    Detail = "Email o contraseña incorrectos",
                    Status = StatusCodes.Status401Unauthorized
                });
            }

            // Verificar si la cuenta está bloqueada
            if (user.LockedUntil.HasValue && user.LockedUntil.Value > DateTime.UtcNow)
            {
                var remainingMinutes = (int)Math.Ceiling((user.LockedUntil.Value - DateTime.UtcNow).TotalMinutes);
                throw new BusinessException(
                    $"Tu cuenta está bloqueada. Intenta de nuevo en {remainingMinutes} minuto(s).",
                    "ACCOUNT_LOCKED");
            }

            // Si el bloqueo expiró, resetear
            if (user.LockedUntil.HasValue && user.LockedUntil.Value <= DateTime.UtcNow)
            {
                user.LockedUntil = null;
                user.FailedLoginAttempts = 0;
            }

            // Verificar password
            var isPasswordValid = _passwordHasher.VerifyPassword(request.Password.Trim(), user.PasswordHash);

            if (!isPasswordValid)
            {
                // Incrementar intentos fallidos
                user.FailedLoginAttempts++;

                // Bloquear cuenta después de X intentos fallidos
                var maxAttempts = int.Parse(_configuration["Auth:MaxFailedLoginAttempts"] ?? "5");
                var lockoutDuration = int.Parse(_configuration["Auth:AccountLockoutDurationMinutes"] ?? "30");

                if (user.FailedLoginAttempts >= maxAttempts)
                {
                    user.LockedUntil = DateTime.UtcNow.AddMinutes(lockoutDuration);
                    _logger.LogWarning("Cuenta bloqueada por {Attempts} intentos fallidos: {Email}", 
                        user.FailedLoginAttempts, user.Email);
                }

                await _context.SaveChangesAsync();

                // Registrar intento fallido en historial
                var failedLoginHistory = new LoginHistory
                {
                    UserId = user.Id,
                    IpAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown",
                    UserAgent = Request.Headers["User-Agent"].ToString(),
                    IsSuccessful = false,
                    FailureReason = "Password incorrecto"
                };
                _context.LoginHistories.Add(failedLoginHistory);
                await _context.SaveChangesAsync();

                // No revelar si fue email o password (seguridad)
                _logger.LogWarning("Intento de login fallido: password incorrecto para {Email}", user.Email);
                return Unauthorized(new ProblemDetails
                {
                    Title = "Credenciales inválidas",
                    Detail = "Email o contraseña incorrectos",
                    Status = StatusCodes.Status401Unauthorized
                });
            }

            // Si el hash es SHA256 antiguo, migrar a BCrypt
            if (!_passwordHasher.IsBcryptHash(user.PasswordHash))
            {
                user.PasswordHash = _passwordHasher.HashPassword(request.Password.Trim());
                _logger.LogInformation("Password migrado a BCrypt para usuario: {Email}", user.Email);
            }

            // Verificar si el usuario está activo
            if (!user.IsActive)
            {
                throw new BusinessException("Tu cuenta está desactivada. Contacta al administrador.", "ACCOUNT_DISABLED");
            }

            // Resetear intentos fallidos y actualizar último login
            user.FailedLoginAttempts = 0;
            user.LockedUntil = null;
            user.LastLoginAt = DateTime.UtcNow;

            // Registrar en historial de logins
            var loginHistory = new LoginHistory
            {
                UserId = user.Id,
                IpAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown",
                UserAgent = Request.Headers["User-Agent"].ToString(),
                IsSuccessful = true
            };
            _context.LoginHistories.Add(loginHistory);

            // Revocar todos los refresh tokens anteriores del usuario (opcional, para seguridad)
            var oldTokens = await _context.RefreshTokens
                .Where(rt => rt.UserId == user.Id && !rt.IsRevoked && rt.ExpiresAt > DateTime.UtcNow)
                .ToListAsync();

            foreach (var token in oldTokens)
            {
                token.IsRevoked = true;
                token.RevokedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();

            _logger.LogInformation("Usuario autenticado exitosamente: {Email}, ID: {UserId}", user.Email, user.Id);

            // Obtener roles (evitar NullReference si Role no está cargado o fue eliminado)
            var roles = user.UserRoles?
                .Where(ur => ur.Role != null)
                .Select(ur => ur.Role!.Name)
                .ToList() ?? new List<string>();
            if (roles.Count == 0)
            {
                _logger.LogWarning("Usuario {Email} no tiene roles asignados; se asume Customer", user.Email);
                roles = new List<string> { "Customer" };
            }

            _logger.LogInformation("Roles obtenidos para usuario {Email}: {Roles}", user.Email, string.Join(", ", roles));

            // Determinar URL de redirección basada en roles (Razor Pages)
            string redirectUrl;
            if (roles.Any(r => r.Equals("Admin", StringComparison.OrdinalIgnoreCase)))
            {
                redirectUrl = "/admin.html";
                _logger.LogInformation("Usuario admin detectado, redirigiendo a panel de administración. Roles: {Roles}", string.Join(", ", roles));
            }
            else
            {
                redirectUrl = "/reservas.html";
                _logger.LogInformation("Usuario cliente detectado, redirigiendo a reservas. Roles: {Roles}", string.Join(", ", roles));
            }

            // Generar tokens
            var accessToken = _jwtService.GenerateAccessToken(user.Id, user.Email, roles);
            var refreshToken = await CreateRefreshTokenAsync(user.Id);

            // Cookie con JWT para que GET /Admin (y otras páginas Razor) reciban auth en la misma petición
            SetJwtCookie(accessToken);

            return Ok(new AuthResponseDto
            {
                AccessToken = accessToken,
                RefreshToken = refreshToken.Token,
                User = new UserDto
                {
                    Id = user.Id,
                    Email = user.Email,
                    FirstName = user.FirstName,
                    LastName = user.LastName,
                    Roles = roles
                },
                RedirectUrl = redirectUrl
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error en login para email: {Email} | Tipo: {ExceptionType} | Mensaje: {Message}", request?.Email, ex.GetType().Name, ex.Message);
            if (ex.InnerException != null)
                _logger.LogError("InnerException: {InnerType} | {InnerMessage}", ex.InnerException.GetType().Name, ex.InnerException.Message);
            throw;
        }
    }

    /// <summary>
    /// Refrescar access token usando refresh token
    /// </summary>
    [HttpPost("refresh")]
    public async Task<ActionResult<AuthResponseDto>> Refresh([FromBody] RefreshTokenRequestDto request)
    {
        _logger.LogInformation("Intento de refresh token");

        if (string.IsNullOrWhiteSpace(request.RefreshToken))
        {
            throw new BusinessException("Refresh token es requerido", "REFRESH_TOKEN_REQUIRED");
        }

        // Buscar refresh token
        var refreshToken = await _context.RefreshTokens
            .Include(rt => rt.User)
                .ThenInclude(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
            .FirstOrDefaultAsync(rt => rt.Token == request.RefreshToken);

        if (refreshToken == null)
        {
            throw new UnauthorizedAccessException("Refresh token inválido");
        }

        // Verificar si está revocado
        if (refreshToken.IsRevoked)
        {
            throw new UnauthorizedAccessException("Refresh token ha sido revocado");
        }

        // Verificar si expiró
        if (refreshToken.ExpiresAt <= DateTime.UtcNow)
        {
            refreshToken.IsRevoked = true;
            refreshToken.RevokedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            throw new UnauthorizedAccessException("Refresh token expirado");
        }

        // Verificar si el usuario está activo
        if (!refreshToken.User.IsActive)
        {
            throw new BusinessException("Tu cuenta está desactivada", "ACCOUNT_DISABLED");
        }

        // Revocar el token usado (rotación de tokens)
        refreshToken.IsRevoked = true;
        refreshToken.RevokedAt = DateTime.UtcNow;

        // Generar nuevos tokens
        var roles = refreshToken.User.UserRoles
            .Select(ur => ur.Role.Name)
            .ToList();

        var newAccessToken = _jwtService.GenerateAccessToken(refreshToken.User.Id, refreshToken.User.Email, roles);
        var newRefreshToken = await CreateRefreshTokenAsync(refreshToken.User.Id);

        // Marcar el nuevo token como reemplazo del anterior
        newRefreshToken.ReplacedByToken = newRefreshToken.Token;

        await _context.SaveChangesAsync();

        _logger.LogInformation("Token refrescado exitosamente para usuario: {Email}", refreshToken.User.Email);

        // Determinar URL de redirección basada en roles (Razor Pages)
        string redirectUrl;
        if (roles.Any(r => r.Equals("Admin", StringComparison.OrdinalIgnoreCase)))
        {
            redirectUrl = "/admin.html";
        }
        else
        {
            redirectUrl = "/reservas.html";
        }

        SetJwtCookie(newAccessToken);

        return Ok(new AuthResponseDto
        {
            AccessToken = newAccessToken,
            RefreshToken = newRefreshToken.Token,
            User = new UserDto
            {
                Id = refreshToken.User.Id,
                Email = refreshToken.User.Email,
                FirstName = refreshToken.User.FirstName,
                LastName = refreshToken.User.LastName,
                Roles = roles
            },
            RedirectUrl = redirectUrl
        });
    }

    /// <summary>
    /// Logout - revoca el refresh token
    /// </summary>
    [HttpPost("logout")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult> Logout([FromBody] LogoutRequestDto? request)
    {
        var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                         User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        // Si se proporciona un refresh token, revocarlo
        if (request != null && !string.IsNullOrWhiteSpace(request.RefreshToken))
        {
            var refreshToken = await _context.RefreshTokens
                .FirstOrDefaultAsync(rt => rt.Token == request.RefreshToken && rt.UserId == userId);

            if (refreshToken != null && !refreshToken.IsRevoked)
            {
                refreshToken.IsRevoked = true;
                refreshToken.RevokedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();
            }
        }
        else
        {
            // Revocar todos los refresh tokens del usuario
            var tokens = await _context.RefreshTokens
                .Where(rt => rt.UserId == userId && !rt.IsRevoked)
                .ToListAsync();

            foreach (var token in tokens)
            {
                token.IsRevoked = true;
                token.RevokedAt = DateTime.UtcNow;
            }

            if (tokens.Any())
            {
                await _context.SaveChangesAsync();
            }
        }

        _logger.LogInformation("Logout exitoso para usuario: {UserId}", userId);

        ClearJwtCookie();

        return Ok(new { message = "Logout exitoso" });
    }

    /// <summary>
    /// Obtener información del usuario actual
    /// </summary>
    [HttpGet("me")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult<UserDto>> GetCurrentUser()
    {
        var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                         User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var user = await _context.Users
            .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user == null)
        {
            return NotFound();
        }

        var roles = user.UserRoles
            .Select(ur => ur.Role.Name)
            .ToList();

        return Ok(new UserDto
        {
            Id = user.Id,
            Email = user.Email,
            FirstName = user.FirstName,
            LastName = user.LastName,
            Phone = user.Phone,
            Roles = roles,
            EmailVerified = user.EmailVerified,
            EmailVerifiedAt = user.EmailVerifiedAt,
            LastLoginAt = user.LastLoginAt,
            CreatedAt = user.CreatedAt
        });
    }

    /// <summary>
    /// Actualizar perfil del usuario actual
    /// </summary>
    [HttpPut("profile")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult<UserDto>> UpdateProfile([FromBody] UpdateProfileRequestDto request)
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var user = await _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
            {
                return NotFound();
            }

            // Actualizar campos si se proporcionan
            if (!string.IsNullOrWhiteSpace(request.FirstName))
            {
                user.FirstName = request.FirstName.Trim();
            }

            if (!string.IsNullOrWhiteSpace(request.LastName))
            {
                user.LastName = request.LastName.Trim();
            }

            if (request.Phone != null)
            {
                user.Phone = string.IsNullOrWhiteSpace(request.Phone) ? null : request.Phone.Trim();
            }

            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            var roles = user.UserRoles
                .Select(ur => ur.Role.Name)
                .ToList();

            return Ok(new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Phone = user.Phone,
                Roles = roles,
                EmailVerified = user.EmailVerified,
                EmailVerifiedAt = user.EmailVerifiedAt,
                LastLoginAt = user.LastLoginAt,
                CreatedAt = user.CreatedAt
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al actualizar perfil");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Cambiar contraseña del usuario actual
    /// </summary>
    [HttpPost("change-password")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult> ChangePassword([FromBody] ChangePasswordRequestDto request)
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

            // Verificar contraseña actual
            var isCurrentPasswordValid = _passwordHasher.VerifyPassword(request.CurrentPassword.Trim(), user.PasswordHash);
            if (!isCurrentPasswordValid)
            {
                return BadRequest(new ProblemDetails
                {
                    Title = "Contraseña actual incorrecta",
                    Detail = "La contraseña actual no es correcta",
                    Status = StatusCodes.Status400BadRequest
                });
            }

            // Validar que la nueva contraseña sea diferente
            var isNewPasswordSame = _passwordHasher.VerifyPassword(request.NewPassword.Trim(), user.PasswordHash);
            if (isNewPasswordSame)
            {
                return BadRequest(new ProblemDetails
                {
                    Title = "Nueva contraseña inválida",
                    Detail = "La nueva contraseña debe ser diferente a la actual",
                    Status = StatusCodes.Status400BadRequest
                });
            }

            // Hashear nueva contraseña
            var newPasswordHash = _passwordHasher.HashPassword(request.NewPassword.Trim());
            user.PasswordHash = newPasswordHash;
            user.UpdatedAt = DateTime.UtcNow;

            // Invalidar todos los refresh tokens del usuario (por seguridad)
            var userRefreshTokens = await _context.RefreshTokens
                .Where(rt => rt.UserId == userId && !rt.IsRevoked)
                .ToListAsync();

            foreach (var token in userRefreshTokens)
            {
                token.IsRevoked = true;
                token.RevokedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();

            _logger.LogInformation("Contraseña actualizada exitosamente para usuario: {Email}", user.Email);

            return Ok(new { message = "Tu contraseña ha sido actualizada exitosamente" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al cambiar contraseña");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Obtener historial de logins del usuario actual
    /// </summary>
    [HttpGet("login-history")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult<IEnumerable<LoginHistoryDto>>> GetLoginHistory([FromQuery] int limit = 20)
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var loginHistory = await _context.LoginHistories
                .Where(lh => lh.UserId == userId)
                .OrderByDescending(lh => lh.CreatedAt)
                .Take(limit)
                .Select(lh => new LoginHistoryDto
                {
                    Id = lh.Id,
                    IpAddress = lh.IpAddress ?? "Unknown",
                    UserAgent = lh.UserAgent ?? "Unknown",
                    IsSuccessful = lh.IsSuccessful,
                    FailureReason = lh.FailureReason,
                    CreatedAt = lh.CreatedAt
                })
                .ToListAsync();

            return Ok(loginHistory);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener historial de logins");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Verificar si un email ya está registrado
    /// </summary>
    [HttpGet("check-email")]
    [ProducesResponseType(typeof(bool), StatusCodes.Status200OK)]
    public async Task<ActionResult<bool>> CheckEmail([FromQuery] string email)
    {
        if (string.IsNullOrWhiteSpace(email))
        {
            return BadRequest(new ProblemDetails
            {
                Title = "Email requerido",
                Detail = "Debes proporcionar un email",
                Status = StatusCodes.Status400BadRequest
            });
        }

        var emailToCheck = email.Trim().ToLower();
        var exists = await _context.Users
            .AnyAsync(u => u.Email.ToLower() == emailToCheck);

        return Ok(exists);
    }

    /// <summary>
    /// Solicitar recuperación de contraseña
    /// </summary>
    [HttpPost("forgot-password")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult> ForgotPassword([FromBody] ForgotPasswordRequestDto request)
    {
        _logger.LogInformation("=== INICIO Solicitud de recuperación de contraseña ===");
        var emailPreview = !string.IsNullOrEmpty(request.Email) && request.Email.Length > 5 
            ? request.Email.Substring(0, 5) + "***" 
            : "***";
        _logger.LogInformation("Email: {Email}", emailPreview);

        // Buscar usuario por email
        var emailToCheck = request.Email?.Trim().ToLower() ?? string.Empty;
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Email.ToLower() == emailToCheck);

        // ⚠️ IMPORTANTE: No revelar si el email existe o no (seguridad)
        // Siempre devolver el mismo mensaje para prevenir user enumeration
        var message = "Si el correo electrónico existe en nuestro sistema, recibirás un enlace para recuperar tu contraseña en breve.";

        if (user != null && user.IsActive)
        {
            // Invalidar tokens anteriores del usuario
            var oldTokens = await _context.PasswordResetTokens
                .Where(prt => prt.UserId == user.Id && !prt.IsUsed && prt.ExpiresAt > DateTime.UtcNow)
                .ToListAsync();

            foreach (var token in oldTokens)
            {
                token.IsUsed = true;
                token.UsedAt = DateTime.UtcNow;
            }

            // Generar token único y seguro (UUID)
            var resetToken = Guid.NewGuid().ToString("N"); // Sin guiones para URL más limpia
            
            // Crear token de recuperación (expira en 15 minutos)
            var passwordResetToken = new PasswordResetToken
            {
                UserId = user.Id,
                Token = resetToken,
                ExpiresAt = DateTime.UtcNow.AddMinutes(15),
                IsUsed = false,
                IpAddress = HttpContext.Connection.RemoteIpAddress?.ToString(),
                UserAgent = Request.Headers["User-Agent"].ToString()
            };

            await _context.PasswordResetTokens.AddAsync(passwordResetToken);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Token de recuperación generado para usuario: {Email}", user.Email);

            // TODO: Enviar email con el link de recuperación
            // Por ahora solo logueamos el token (en producción enviar email)
            var resetLink = $"{Request.Scheme}://{Request.Host}/reset-password.html?token={resetToken}";
            _logger.LogInformation("Link de recuperación generado: {ResetLink}", resetLink);
            
            // En un entorno real, aquí se enviaría el email
            // await _emailService.SendPasswordResetEmailAsync(user.Email, resetLink);
        }
        else
        {
            // Delay para evitar timing attacks
            var randomDelay = new Random().Next(200, 500);
            await Task.Delay(randomDelay);
        }

        _logger.LogInformation("=== FIN Solicitud de recuperación de contraseña ===");

        // Siempre devolver éxito (no revelar si email existe)
        return Ok(new { message });
    }

    /// <summary>
    /// Resetear contraseña con token
    /// </summary>
    [HttpPost("reset-password")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> ResetPassword([FromBody] ResetPasswordRequestDto request)
    {
        _logger.LogInformation("=== INICIO Reset de contraseña ===");
        var tokenPreview = !string.IsNullOrEmpty(request.Token) && request.Token.Length > 8 
            ? request.Token.Substring(0, 8) + "***" 
            : "***";
        _logger.LogInformation("Token recibido: {Token}", tokenPreview);

        // Buscar token válido
        var passwordResetToken = await _context.PasswordResetTokens
            .Include(prt => prt.User)
            .FirstOrDefaultAsync(prt => prt.Token == request.Token);

        if (passwordResetToken == null)
        {
            _logger.LogWarning("Token de recuperación no encontrado o inválido");
            return NotFound(new ProblemDetails
            {
                Title = "Token inválido",
                Detail = "El token de recuperación no es válido o ha expirado. Por favor solicita uno nuevo.",
                Status = StatusCodes.Status404NotFound
            });
        }

        // Validar que el token no haya sido usado
        if (passwordResetToken.IsUsed)
        {
            _logger.LogWarning("Token de recuperación ya utilizado: {Token}", tokenPreview);
            return BadRequest(new ProblemDetails
            {
                Title = "Token ya utilizado",
                Detail = "Este token de recuperación ya fue utilizado. Por favor solicita uno nuevo.",
                Status = StatusCodes.Status400BadRequest
            });
        }

        // Validar que el token no haya expirado
        if (passwordResetToken.ExpiresAt <= DateTime.UtcNow)
        {
            _logger.LogWarning("Token de recuperación expirado: {Token}", tokenPreview);
            passwordResetToken.IsUsed = true;
            passwordResetToken.UsedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return BadRequest(new ProblemDetails
            {
                Title = "Token expirado",
                Detail = "El token de recuperación ha expirado. Los tokens expiran después de 15 minutos. Por favor solicita uno nuevo.",
                Status = StatusCodes.Status400BadRequest
            });
        }

        // Validar que el usuario esté activo
        if (!passwordResetToken.User.IsActive)
        {
            _logger.LogWarning("Intento de reset de contraseña para usuario inactivo: {Email}", passwordResetToken.User.Email);
            return BadRequest(new ProblemDetails
            {
                Title = "Cuenta desactivada",
                Detail = "Tu cuenta está desactivada. Contacta al administrador.",
                Status = StatusCodes.Status400BadRequest
            });
        }

        // Hashear nueva contraseña
        var newPasswordHash = _passwordHasher.HashPassword(request.NewPassword.Trim());

        // Actualizar contraseña del usuario
        passwordResetToken.User.PasswordHash = newPasswordHash;
        passwordResetToken.User.UpdatedAt = DateTime.UtcNow;

        // Marcar token como usado
        passwordResetToken.IsUsed = true;
        passwordResetToken.UsedAt = DateTime.UtcNow;
        passwordResetToken.IpAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        passwordResetToken.UserAgent = Request.Headers["User-Agent"].ToString();

        // Invalidar todos los refresh tokens del usuario (por seguridad)
        var userRefreshTokens = await _context.RefreshTokens
            .Where(rt => rt.UserId == passwordResetToken.User.Id && !rt.IsRevoked)
            .ToListAsync();

        foreach (var token in userRefreshTokens)
        {
            token.IsRevoked = true;
            token.RevokedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();

        _logger.LogInformation("Contraseña actualizada exitosamente para usuario: {Email}", passwordResetToken.User.Email);
        _logger.LogInformation("=== FIN Reset de contraseña (exitoso) ===");

        return Ok(new { message = "Tu contraseña ha sido actualizada exitosamente. Ya puedes iniciar sesión con tu nueva contraseña." });
    }

    /// <summary>
    /// Crea un refresh token para un usuario
    /// </summary>
    private async Task<RefreshToken> CreateRefreshTokenAsync(Guid userId)
    {
        var expirationDays = int.Parse(_configuration["Jwt:RefreshTokenExpirationDays"] ?? "7");
        var token = _jwtService.GenerateRefreshToken();

        var refreshToken = new RefreshToken
        {
            UserId = userId,
            Token = token,
            ExpiresAt = DateTime.UtcNow.AddDays(expirationDays),
            IpAddress = HttpContext.Connection.RemoteIpAddress?.ToString(),
            UserAgent = Request.Headers["User-Agent"].ToString()
        };

        await _context.RefreshTokens.AddAsync(refreshToken);
        await _context.SaveChangesAsync();

        return refreshToken;
    }

    private const string JwtCookieName = "accessToken";

    private void SetJwtCookie(string accessToken)
    {
        var expirationMinutes = int.Parse(_configuration["Jwt:AccessTokenExpirationMinutes"] ?? "15");
        Response.Cookies.Append(JwtCookieName, accessToken, new CookieOptions
        {
            HttpOnly = true,
            Secure = false, // true en producción con HTTPS
            SameSite = SameSiteMode.Lax,
            Path = "/",
            MaxAge = TimeSpan.FromMinutes(expirationMinutes)
        });
    }

    private void ClearJwtCookie()
    {
        Response.Cookies.Delete(JwtCookieName, new CookieOptions { Path = "/" });
    }
}

// DTOs

public class AuthResponseDto
{
    public string AccessToken { get; set; } = string.Empty;
    public string RefreshToken { get; set; } = string.Empty;
    public UserDto User { get; set; } = new();
    public string RedirectUrl { get; set; } = string.Empty;
}

public class UserDto
{
    public Guid Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public List<string> Roles { get; set; } = new();
    public bool EmailVerified { get; set; }
    public DateTime? EmailVerifiedAt { get; set; }
    public DateTime? LastLoginAt { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class UpdateProfileRequestDto
{
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public string? Phone { get; set; }
}

public class ChangePasswordRequestDto
{
    public string CurrentPassword { get; set; } = string.Empty;
    public string NewPassword { get; set; } = string.Empty;
    public string ConfirmPassword { get; set; } = string.Empty;
}

public class LoginHistoryDto
{
    public Guid Id { get; set; }
    public string IpAddress { get; set; } = string.Empty;
    public string UserAgent { get; set; } = string.Empty;
    public bool IsSuccessful { get; set; }
    public string? FailureReason { get; set; }
    public DateTime CreatedAt { get; set; }
}

// RefreshTokenRequestDto está definido en PanamaTravelHub.Application.Validators

public class LogoutRequestDto
{
    public string? RefreshToken { get; set; }
}
