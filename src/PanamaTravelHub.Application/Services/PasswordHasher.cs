using System.Security.Cryptography;
using System.Text;

namespace PanamaTravelHub.Application.Services;

/// <summary>
/// Implementación de IPasswordHasher usando BCrypt
/// </summary>
public class PasswordHasher : IPasswordHasher
{
    private const int BcryptWorkFactor = 12; // Balance entre seguridad y performance

    public string HashPassword(string password)
    {
        if (string.IsNullOrWhiteSpace(password))
            throw new ArgumentException("Password cannot be null or empty", nameof(password));

        return BCrypt.Net.BCrypt.HashPassword(password, BcryptWorkFactor);
    }

    public bool VerifyPassword(string password, string passwordHash)
    {
        if (string.IsNullOrWhiteSpace(password) || string.IsNullOrWhiteSpace(passwordHash))
            return false;

        // Si es un hash BCrypt, verificar con BCrypt
        if (IsBcryptHash(passwordHash))
        {
            try
            {
                return BCrypt.Net.BCrypt.Verify(password, passwordHash);
            }
            catch
            {
                return false;
            }
        }

        // Si es un hash SHA256 antiguo, verificar y migrar
        // Esto permite migración gradual de usuarios existentes
        var sha256Hash = HashWithSha256(password);
        if (sha256Hash == passwordHash)
        {
            // El hash coincide, pero es SHA256. En el próximo login se migrará a BCrypt
            return true;
        }

        return false;
    }

    public bool IsBcryptHash(string hash)
    {
        // Los hashes BCrypt siempre empiezan con $2a$, $2b$, $2x$, o $2y$
        return !string.IsNullOrWhiteSpace(hash) && 
               (hash.StartsWith("$2a$") || 
                hash.StartsWith("$2b$") || 
                hash.StartsWith("$2x$") || 
                hash.StartsWith("$2y$"));
    }

    /// <summary>
    /// Método helper para verificar hashes SHA256 antiguos (solo para migración)
    /// </summary>
    private string HashWithSha256(string password)
    {
        using var sha256 = SHA256.Create();
        var bytes = Encoding.UTF8.GetBytes(password);
        var hash = sha256.ComputeHash(bytes);
        return Convert.ToBase64String(hash);
    }
}

