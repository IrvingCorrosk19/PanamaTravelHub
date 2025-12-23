using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Application.Exceptions;
using PanamaTravelHub.Application.Validators;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Infrastructure.Data;
using PanamaTravelHub.Infrastructure.Repositories;
using System.Security.Cryptography;
using System.Text;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly ILogger<AuthController> _logger;
    private readonly ApplicationDbContext _context;
    private readonly IRepository<User> _userRepository;

    public AuthController(
        ILogger<AuthController> logger,
        ApplicationDbContext context,
        IRepository<User> userRepository)
    {
        _logger = logger;
        _context = context;
        _userRepository = userRepository;
    }

    /// <summary>
    /// Registro de nuevo usuario
    /// </summary>
    [HttpPost("register")]
    public async Task<ActionResult<AuthResponseDto>> Register([FromBody] RegisterRequestDto request)
    {
        _logger.LogInformation("Registro de usuario: {Email}", request.Email);

        // La validación se hace automáticamente por FluentValidation
        // Verificar si el usuario ya existe
        var existingUser = await _context.Users
            .FirstOrDefaultAsync(u => u.Email.ToLower() == request.Email.ToLower().Trim());

        if (existingUser != null)
        {
            throw new BusinessException("Este email ya está registrado", "EMAIL_ALREADY_EXISTS");
        }

        // Hashear password (usando SHA256 simple por ahora, luego se puede cambiar a BCrypt)
        var password = request.Password.Trim();
        var passwordHash = HashPassword(password);

        // Crear usuario en BD
        var user = new User
        {
            Email = request.Email.Trim().ToLower(),
            PasswordHash = passwordHash,
            FirstName = request.FirstName.Trim(),
            LastName = request.LastName.Trim(),
            IsActive = true
        };

        await _userRepository.AddAsync(user);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Usuario registrado exitosamente: {Email}, ID: {UserId}", user.Email, user.Id);

        var token = $"mock_token_{Guid.NewGuid()}";

        return Ok(new AuthResponseDto
        {
            Token = token,
            User = new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName
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
            _logger.LogInformation("Login de usuario: {Email}", request.Email);

            if (request == null)
            {
                throw new BusinessException("El request no puede ser nulo", "INVALID_REQUEST");
            }

            // La validación se hace automáticamente por FluentValidation
            // Buscar usuario en BD
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email.ToLower() == request.Email.ToLower().Trim());

            if (user == null)
            {
                // No revelar que el usuario no existe (protección contra user enumeration)
                await Task.Delay(500); // Simular tiempo de procesamiento
                throw new UnauthorizedAccessException("Email o contraseña incorrectos");
            }

            // Verificar password
            var passwordHash = HashPassword(request.Password.Trim());
            if (user.PasswordHash != passwordHash)
            {
                // Incrementar intentos fallidos
                user.FailedLoginAttempts++;
                await _userRepository.UpdateAsync(user);
                await _context.SaveChangesAsync();

                throw new UnauthorizedAccessException("Email o contraseña incorrectos");
            }

            // Verificar si el usuario está activo
            if (!user.IsActive)
            {
                throw new BusinessException("Tu cuenta está desactivada. Contacta al administrador.", "ACCOUNT_DISABLED");
            }

            // Actualizar último login
            user.LastLoginAt = DateTime.UtcNow;
            user.FailedLoginAttempts = 0; // Resetear intentos fallidos
            await _userRepository.UpdateAsync(user);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Usuario autenticado exitosamente: {Email}, ID: {UserId}", user.Email, user.Id);

            var token = $"mock_token_{Guid.NewGuid()}";

            return Ok(new AuthResponseDto
            {
                Token = token,
                User = new UserDto
                {
                    Id = user.Id,
                    Email = user.Email,
                    FirstName = user.FirstName,
                    LastName = user.LastName
                }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error en login para email: {Email}", request?.Email);
            throw; // Re-lanzar para que el middleware lo maneje
        }
    }

    /// <summary>
    /// Hashea una contraseña usando SHA256 (temporal, luego cambiar a BCrypt)
    /// </summary>
    private string HashPassword(string password)
    {
        using var sha256 = SHA256.Create();
        var bytes = Encoding.UTF8.GetBytes(password);
        var hash = sha256.ComputeHash(bytes);
        return Convert.ToBase64String(hash);
    }
}

// DTOs de respuesta (los de request están en Application.Validators)

public class AuthResponseDto
{
    public string Token { get; set; } = string.Empty;
    public UserDto User { get; set; } = new();
}

public class UserDto
{
    public Guid Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
}
