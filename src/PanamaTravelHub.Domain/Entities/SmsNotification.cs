using PanamaTravelHub.Domain.Enums;

namespace PanamaTravelHub.Domain.Entities;

public class SmsNotification : BaseEntity
{
    public Guid? UserId { get; set; }
    public Guid? BookingId { get; set; }
    public SmsNotificationType Type { get; set; }
    public SmsNotificationStatus Status { get; set; } = SmsNotificationStatus.Pending;
    public string ToPhoneNumber { get; set; } = string.Empty; // E.164 format (+50760000000)
    public string Message { get; set; } = string.Empty;
    public DateTime? SentAt { get; set; }
    public int RetryCount { get; set; } = 0;
    public string? ErrorMessage { get; set; }
    public DateTime? ScheduledFor { get; set; }
    public string? ProviderMessageId { get; set; } // ID del mensaje del proveedor (Twilio, etc.)
    public string? ProviderResponse { get; set; } // Respuesta completa del proveedor (JSON)

    // Navigation properties
    public User? User { get; set; }
    public Booking? Booking { get; set; }
}

