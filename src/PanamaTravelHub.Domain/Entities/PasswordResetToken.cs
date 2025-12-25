namespace PanamaTravelHub.Domain.Entities;

/// <summary>
/// Entidad para tokens de recuperación de contraseña
/// </summary>
public class PasswordResetToken : BaseEntity
{
    public Guid UserId { get; set; }
    public string Token { get; set; } = string.Empty; // Token único (UUID o hash)
    public DateTime ExpiresAt { get; set; }
    public bool IsUsed { get; set; } = false;
    public DateTime? UsedAt { get; set; }
    public string? IpAddress { get; set; }
    public string? UserAgent { get; set; }

    // Navigation property
    public User User { get; set; } = null!;
}
