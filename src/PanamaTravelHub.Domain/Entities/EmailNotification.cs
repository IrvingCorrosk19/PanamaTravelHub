using PanamaTravelHub.Domain.Enums;

namespace PanamaTravelHub.Domain.Entities;

public class EmailNotification : BaseEntity
{
    public Guid? UserId { get; set; }
    public Guid? BookingId { get; set; }
    public EmailNotificationType Type { get; set; }
    public EmailNotificationStatus Status { get; set; } = EmailNotificationStatus.Pending;
    public string ToEmail { get; set; } = string.Empty;
    public string Subject { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public DateTime? SentAt { get; set; }
    public int RetryCount { get; set; } = 0;
    public string? ErrorMessage { get; set; }
    public DateTime? ScheduledFor { get; set; }

    // Navigation properties
    public User? User { get; set; }
    public Booking? Booking { get; set; }
}
