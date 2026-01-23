namespace PanamaTravelHub.Domain.Entities;

public class LoginHistory : BaseEntity
{
    public Guid UserId { get; set; }
    public string IpAddress { get; set; } = string.Empty;
    public string? UserAgent { get; set; }
    public bool IsSuccessful { get; set; }
    public string? FailureReason { get; set; }
    public string? Location { get; set; } // País/ciudad (opcional, desde geolocalización IP)
    
    // Navigation properties
    public User User { get; set; } = null!;
}
