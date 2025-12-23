namespace PanamaTravelHub.Application.Services;

/// <summary>
/// Servicio para hashear y verificar contraseñas usando BCrypt
/// </summary>
public interface IPasswordHasher
{
    /// <summary>
    /// Hashea una contraseña usando BCrypt
    /// </summary>
    string HashPassword(string password);

    /// <summary>
    /// Verifica si una contraseña coincide con el hash almacenado
    /// </summary>
    bool VerifyPassword(string password, string passwordHash);

    /// <summary>
    /// Verifica si un hash es de BCrypt o del sistema antiguo (SHA256)
    /// </summary>
    bool IsBcryptHash(string hash);
}

