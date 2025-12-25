namespace PanamaTravelHub.Domain.Entities;

public class AuditLog : BaseEntity
{
    public Guid? UserId { get; set; }
    public string EntityType { get; set; } = string.Empty;
    public Guid EntityId { get; set; }
    public string Action { get; set; } = string.Empty; // CREATE, UPDATE, DELETE, etc.
    public string? BeforeState { get; set; } // JSONB
    public string? AfterState { get; set; } // JSONB
    public string? IpAddress { get; set; }
    public string? UserAgent { get; set; }
    public Guid? CorrelationId { get; set; }

    // Navigation properties
    public User? User { get; set; }
}
