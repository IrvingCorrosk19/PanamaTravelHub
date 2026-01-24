namespace PanamaTravelHub.Application.DTOs;

public class InvoiceViewModel
{
    public string InvoiceNumber { get; set; } = null!;
    public DateTime IssuedAt { get; set; }

    // Cliente
    public string CustomerName { get; set; } = null!;
    public string CustomerEmail { get; set; } = null!;
    public string? CustomerPhone { get; set; }

    // Tour
    public string TourName { get; set; } = null!;
    public DateTime? TourDate { get; set; }
    public int Participants { get; set; }
    public string? TourLocation { get; set; }

    // Montos
    public decimal Subtotal { get; set; }
    public decimal Discount { get; set; }
    public decimal Taxes { get; set; }
    public decimal Total { get; set; }

    // Metadata
    public string Currency { get; set; } = "USD";
    public string Language { get; set; } = "ES"; // ES | EN
}
