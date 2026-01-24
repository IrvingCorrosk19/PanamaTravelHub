namespace PanamaTravelHub.Domain.Entities;

public class Invoice : BaseEntity
{
    public string InvoiceNumber { get; set; } = string.Empty; // F-2026-000123
    public Guid BookingId { get; set; }
    public Guid UserId { get; set; }
    public string Currency { get; set; } = "USD";
    public decimal Subtotal { get; set; }
    public decimal Discount { get; set; }
    public decimal Taxes { get; set; } // 0 por ahora
    public decimal Total { get; set; }
    public string Language { get; set; } = "ES"; // ES | EN
    public DateTime IssuedAt { get; set; }
    public string? PdfUrl { get; set; }
    public string Status { get; set; } = "Issued"; // Issued | Void

    // Navigation properties
    public Booking Booking { get; set; } = null!;
    public User User { get; set; } = null!;
}
