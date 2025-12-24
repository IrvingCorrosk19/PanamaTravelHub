using PanamaTravelHub.Domain.Enums;

namespace PanamaTravelHub.Application.DTOs;

public class CreatePaymentRequestDto
{
    public Guid BookingId { get; set; }
    public string? Currency { get; set; }
    public PaymentProvider? Provider { get; set; } // Stripe, PayPal, o Yappy
}

public class ConfirmPaymentRequestDto
{
    public string PaymentIntentId { get; set; } = string.Empty;
}

public class RefundRequestDto
{
    public Guid PaymentId { get; set; }
    public decimal? Amount { get; set; }
}

