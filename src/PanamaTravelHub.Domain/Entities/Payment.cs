using PanamaTravelHub.Domain.Enums;

namespace PanamaTravelHub.Domain.Entities;

public class Payment : BaseEntity
{
    public Guid BookingId { get; set; }
    public PaymentProvider Provider { get; set; }
    public PaymentStatus Status { get; set; } = PaymentStatus.Initiated;
    public decimal Amount { get; set; }
    public string? ProviderTransactionId { get; set; }
    public string? ProviderPaymentIntentId { get; set; }
    public string? Currency { get; set; } = "USD";
    public DateTime? AuthorizedAt { get; set; }
    public DateTime? CapturedAt { get; set; }
    public DateTime? RefundedAt { get; set; }
    public string? FailureReason { get; set; }
    public string? Metadata { get; set; } // JSON para datos adicionales
    
    // Pagos parciales y cuotas
    public bool IsPartial { get; set; } = false;
    public int? InstallmentNumber { get; set; }
    public int? TotalInstallments { get; set; }
    public Guid? ParentPaymentId { get; set; }

    // Navigation properties
    public Booking Booking { get; set; } = null!;
    public Payment? ParentPayment { get; set; }
    public ICollection<Payment> ChildPayments { get; set; } = new List<Payment>();
}
