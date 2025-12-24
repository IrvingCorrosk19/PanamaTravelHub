using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Application.Exceptions;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Application.Validators;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Infrastructure.Data;
using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;

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

    public AuthController(
        ILogger<AuthController> logger,
        ApplicationDbContext context,
        IPasswordHasher passwordHasher,
        IJwtService jwtService,
        IConfiguration configuration)
    {
        _logger = logger;
        _context = context;
        _passwordHasher = passwordHasher;
        _jwtService = jwtService;
        _configuration = configuration;
    }

    /// <summary>
    /// Registro de nuevo usuario
    /// </summary>
    [HttpPost("register")]
    public async Task<ActionResult<AuthResponseDto>> Register([FromBody] RegisterRequestDto request)
    {
        _logger.LogInformation("Registro de usuario: {Email}", request.Email);

        // Verificar si el usuario ya existe
        var existingUser = await _context.Users
            .FirstOrDefaultAsync(u => u.Email.ToLower() == request.Email.ToLower().Trim());

        if (existingUser != null)
        {
            throw new BusinessException("Este email ya está registrado", "EMAIL_ALREADY_EXISTS");
        }

        // Hashear password con BCrypt
        var passwordHash = _passwordHasher.HashPassword(request.Password.Trim());

        // Crear usuario
        var user = new User
        {
            Email = request.Email.Trim().ToLower(),
            PasswordHash = passwordHash,
            FirstName = request.FirstName.Trim(),
            LastName = request.LastName.Trim(),
            IsActive = true
        };

        await _context.Users.AddAsync(user);
        await _context.SaveChangesAsync();

        // Asignar rol Customer por defecto
        var customerRole = await _context.Roles.FirstOrDefaultAsync(r => r.Name == "Customer");
        if (customerRole != null)
        {
            var userRole = new UserRole
            {
                UserId = user.Id,
                RoleId = customerRole.Id
            };
            await _context.UserRoles.AddAsync(userRole);
            await _context.SaveChangesAsync();
        }

        _logger.LogInformation("Usuario registrado exitosamente: {Email}, ID: {UserId}", user.Email, user.Id);

        // Generar tokens
        var roles = new List<string> { "Customer" };
        var accessToken = _jwtService.GenerateAccessToken(user.Id, user.Email, roles);
        var refreshToken = await CreateRefreshTokenAsync(user.Id);

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
            }
        });
    }

    /// <summary>
    /// Login de usuario
    /// </summary>
    [HttpPost("login")]
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
                await Task.Delay(500);
                throw new UnauthorizedAccessException("Email o contraseña incorrectos");
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

                throw new UnauthorizedAccessException("Email o contraseña incorrectos");
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

            // Obtener roles
            var roles = user.UserRoles
                .Select(ur => ur.Role.Name)
                .ToList();

            // Generar tokens
            var accessToken = _jwtService.GenerateAccessToken(user.Id, user.Email, roles);
            var refreshToken = await CreateRefreshTokenAsync(user.Id);

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
                }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error en login para email: {Email}", request?.Email);
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
            }
        });
    }

    /// <summary>
    /// Logout - revoca el refresh token
    /// </summary>
    [HttpPost("logout")]
    [Authorize]
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

        return Ok(new { message = "Logout exitoso" });
    }

    /// <summary>
    /// Obtener información del usuario actual
    /// </summary>
    [HttpGet("me")]
    [Authorize]
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
            Roles = roles
        });
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
}

// DTOs

public class AuthResponseDto
{
    public string AccessToken { get; set; } = string.Empty;
    public string RefreshToken { get; set; } = string.Empty;
    public UserDto User { get; set; } = new();
}

public class UserDto
{
    public Guid Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public List<string> Roles { get; set; } = new();
}

// RefreshTokenRequestDto está definido en PanamaTravelHub.Application.Validators

public class LogoutRequestDto
{
    public string? RefreshToken { get; set; }
}
