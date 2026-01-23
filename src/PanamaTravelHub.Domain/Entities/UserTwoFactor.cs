namespace PanamaTravelHub.Domain.Entities;

public class UserTwoFactor : BaseEntity
{
    public Guid UserId { get; set; }
    
    // TOTP (Time-based One-Time Password)
    public string? SecretKey { get; set; } // Clave secreta para TOTP (Google Authenticator, etc.)
    public bool IsEnabled { get; set; } = false;
    
    // Backup codes (códigos de respaldo)
    public string? BackupCodes { get; set; } // JSON array de códigos hasheados
    
    // SMS/Email OTP (opcional)
    public string? PhoneNumber { get; set; } // Para SMS OTP
    public bool IsSmsEnabled { get; set; } = false;
    
    // Metadata
    public DateTime? EnabledAt { get; set; }
    public DateTime? LastUsedAt { get; set; }
    
    // Navigation properties
    public User User { get; set; } = null!;
}
