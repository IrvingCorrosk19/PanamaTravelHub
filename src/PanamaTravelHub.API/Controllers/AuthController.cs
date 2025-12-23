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
            _logger.LogInformation("=== INICIO LOGIN ===");
            _logger.LogInformation("Request recibido. Email: {Email}, Request es null: {IsNull}", 
                request?.Email ?? "NULL", request == null);

            if (request == null)
            {
                _logger.LogError("Request es null en Login");
                throw new BusinessException("El request no puede ser nulo", "INVALID_REQUEST");
            }

            if (string.IsNullOrWhiteSpace(request.Email))
            {
                _logger.LogWarning("Email vacío en request de login");
            }

            if (string.IsNullOrWhiteSpace(request.Password))
            {
                _logger.LogWarning("Password vacío en request de login");
            }

            _logger.LogInformation("Buscando usuario en BD con email: {Email}", request.Email);

            // La validación se hace automáticamente por FluentValidation
            // Buscar usuario en BD con sus roles
            var user = await _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Email.ToLower() == request.Email.ToLower().Trim());

            _logger.LogInformation("Usuario encontrado: {Found}, Email: {Email}", user != null, request.Email);

            if (user == null)
            {
                _logger.LogWarning("Usuario no encontrado para email: {Email}", request.Email);
                // No revelar que el usuario no existe (protección contra user enumeration)
                await Task.Delay(500); // Simular tiempo de procesamiento
                throw new UnauthorizedAccessException("Email o contraseña incorrectos");
            }

            _logger.LogInformation("Usuario encontrado. ID: {UserId}, IsActive: {IsActive}", user.Id, user.IsActive);

            // Verificar password
            _logger.LogInformation("Verificando contraseña...");
            var passwordHash = HashPassword(request.Password.Trim());
            _logger.LogInformation("Hash generado. Comparando con hash almacenado...");
            
            if (user.PasswordHash != passwordHash)
            {
                _logger.LogWarning("Contraseña incorrecta para usuario: {Email}. Hash almacenado: {StoredHash}, Hash recibido: {ReceivedHash}", 
                    request.Email, user.PasswordHash?.Substring(0, Math.Min(20, user.PasswordHash?.Length ?? 0)), 
                    passwordHash?.Substring(0, Math.Min(20, passwordHash?.Length ?? 0)));
                
                // Incrementar intentos fallidos
                user.FailedLoginAttempts++;
                await _userRepository.UpdateAsync(user);
                await _context.SaveChangesAsync();

                throw new UnauthorizedAccessException("Email o contraseña incorrectos");
            }

            _logger.LogInformation("Contraseña correcta para usuario: {Email}", request.Email);

            // Verificar si el usuario está activo
            if (!user.IsActive)
            {
                throw new BusinessException("Tu cuenta está desactivada. Contacta al administrador.", "ACCOUNT_DISABLED");
            }

            // Actualizar último login
            // Asegurar que el DateTime sea UTC explícitamente
            user.LastLoginAt = DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Utc);
            user.FailedLoginAttempts = 0; // Resetear intentos fallidos
            await _userRepository.UpdateAsync(user);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Usuario autenticado exitosamente: {Email}, ID: {UserId}", user.Email, user.Id);

            var token = $"mock_token_{Guid.NewGuid()}";

            // Obtener roles del usuario
            var roles = user.UserRoles
                .Select(ur => ur.Role.Name)
                .ToList();

            return Ok(new AuthResponseDto
            {
                Token = token,
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
            _logger.LogError(ex, "=== ERROR EN LOGIN ===");
            _logger.LogError("Email: {Email}", request?.Email ?? "NULL");
            _logger.LogError("Tipo de excepción: {ExceptionType}", ex.GetType().Name);
            _logger.LogError("Mensaje: {Message}", ex.Message);
            _logger.LogError("StackTrace: {StackTrace}", ex.StackTrace);
            if (ex.InnerException != null)
            {
                _logger.LogError("InnerException: {InnerMessage}", ex.InnerException.Message);
            }
            _logger.LogError("=== FIN ERROR LOGIN ===");
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
    public List<string> Roles { get; set; } = new();
}
