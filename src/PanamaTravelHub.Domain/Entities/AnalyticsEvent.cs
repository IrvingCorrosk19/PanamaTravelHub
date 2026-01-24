using System.ComponentModel.DataAnnotations;

namespace PanamaTravelHub.Domain.Entities;

public class AnalyticsEvent : BaseEntity
{
    [Required]
    [MaxLength(100)]
    public string Event { get; set; } = string.Empty;
    
    [MaxLength(50)]
    public string? EntityType { get; set; }
    
    public Guid? EntityId { get; set; }
    
    [Required]
    public Guid SessionId { get; set; }
    
    public Guid? UserId { get; set; }
    
    // Metadata flexible (JSONB en PostgreSQL)
    public string? Metadata { get; set; }
    
    [MaxLength(20)]
    public string? Device { get; set; }
    
    public string? UserAgent { get; set; }
    
    public string? Referrer { get; set; }
    
    [MaxLength(2)]
    public string? Country { get; set; }
    
    [MaxLength(100)]
    public string? City { get; set; }
}
