using Microsoft.AspNetCore.Mvc;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly ILogger<AuthController> _logger;

    public AuthController(ILogger<AuthController> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// Registro de nuevo usuario
    /// </summary>
    [HttpPost("register")]
    public async Task<ActionResult<AuthResponseDto>> Register([FromBody] RegisterRequestDto request)
    {
        try
        {
            // TODO: Implementar lógica real de registro
            // Por ahora retornamos un token mock
            _logger.LogInformation("Registro de usuario: {Email}", request.Email);

            // Validación básica
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
            {
                return BadRequest(new { message = "Email y contraseña son requeridos" });
            }

            // Validar que las contraseñas coincidan (sin espacios y case-sensitive)
            var password = request.Password?.Trim() ?? string.Empty;
            var confirmPassword = request.ConfirmPassword?.Trim() ?? string.Empty;

            // Log para debugging (solo en desarrollo)
            _logger.LogInformation("Password comparison - Length: {PasswordLength} vs {ConfirmLength}, Equal: {AreEqual}", 
                password.Length, confirmPassword.Length, password == confirmPassword);

            if (string.IsNullOrEmpty(confirmPassword))
            {
                return BadRequest(new { message = "Debes confirmar tu contraseña" });
            }

            if (password != confirmPassword)
            {
                return BadRequest(new { message = "Las contraseñas no coinciden. Por favor verifica que ambas sean exactamente iguales." });
            }

            if (password.Length < 6)
            {
                return BadRequest(new { message = "La contraseña debe tener al menos 6 caracteres" });
            }

            // TODO: Crear usuario en BD, hashear password, etc.
            var token = $"mock_token_{Guid.NewGuid()}";

            return Ok(new AuthResponseDto
            {
                Token = token,
                User = new UserDto
                {
                    Id = Guid.NewGuid(),
                    Email = request.Email,
                    FirstName = request.FirstName,
                    LastName = request.LastName
                }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error en registro");
            return StatusCode(500, new { message = "Error al registrar usuario" });
        }
    }

    /// <summary>
    /// Login de usuario
    /// </summary>
    [HttpPost("login")]
    public async Task<ActionResult<AuthResponseDto>> Login([FromBody] LoginRequestDto request)
    {
        try
        {
            // TODO: Implementar lógica real de login
            _logger.LogInformation("Login de usuario: {Email}", request.Email);

            // Validación básica
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
            {
                return BadRequest(new { message = "Email y contraseña son requeridos" });
            }

            // TODO: Validar credenciales en BD
            // Por ahora aceptamos cualquier email/password para testing
            var token = $"mock_token_{Guid.NewGuid()}";

            return Ok(new AuthResponseDto
            {
                Token = token,
                User = new UserDto
                {
                    Id = Guid.NewGuid(),
                    Email = request.Email,
                    FirstName = "Usuario",
                    LastName = "Demo"
                }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error en login");
            return StatusCode(500, new { message = "Error al iniciar sesión" });
        }
    }
}

// DTOs temporales
public class RegisterRequestDto
{
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string? ConfirmPassword { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
}

public class LoginRequestDto
{
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

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
