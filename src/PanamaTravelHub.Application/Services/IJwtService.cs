using System.Security.Claims;

namespace PanamaTravelHub.Application.Services;

/// <summary>
/// Servicio para generar y validar tokens JWT
/// </summary>
public interface IJwtService
{
    /// <summary>
    /// Genera un access token JWT para un usuario
    /// </summary>
    string GenerateAccessToken(Guid userId, string email, IEnumerable<string> roles);

    /// <summary>
    /// Genera un refresh token (string aleatorio)
    /// </summary>
    string GenerateRefreshToken();

    /// <summary>
    /// Obtiene los claims del usuario desde un token
    /// </summary>
    ClaimsPrincipal? GetPrincipalFromToken(string token);

    /// <summary>
    /// Valida si un token es válido
    /// </summary>
    bool ValidateToken(string token);
}

