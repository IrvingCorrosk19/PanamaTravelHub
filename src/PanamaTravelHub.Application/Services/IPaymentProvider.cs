using PanamaTravelHub.Domain.Enums;

namespace PanamaTravelHub.Application.Services;

/// <summary>
/// Interfaz para proveedores de pago (Stripe, PayPal, Yappy)
/// </summary>
public interface IPaymentProvider
{
    /// <summary>
    /// Tipo de proveedor de pago
    /// </summary>
    PaymentProvider Provider { get; }

    /// <summary>
    /// Crea un PaymentIntent o equivalente para iniciar un pago
    /// </summary>
    /// <param name="amount">Monto en centavos (para Stripe) o dólares</param>
    /// <param name="currency">Código de moneda (USD, EUR, etc.)</param>
    /// <param name="metadata">Metadatos adicionales (bookingId, userId, etc.)</param>
    /// <param name="customerEmail">Email del cliente</param>
    /// <returns>Resultado con el ID del payment intent y URL de checkout si aplica</returns>
    Task<PaymentIntentResult> CreatePaymentIntentAsync(
        decimal amount,
        string currency,
        Dictionary<string, string>? metadata = null,
        string? customerEmail = null);

    /// <summary>
    /// Confirma un pago después de que el usuario completa el checkout
    /// </summary>
    /// <param name="paymentIntentId">ID del payment intent del proveedor</param>
    /// <returns>Resultado con el estado del pago y transaction ID</returns>
    Task<PaymentConfirmationResult> ConfirmPaymentAsync(string paymentIntentId);

    /// <summary>
    /// Procesa un webhook del proveedor de pago
    /// </summary>
    /// <param name="payload">Payload del webhook</param>
    /// <param name="signature">Firma del webhook para verificación</param>
    /// <returns>Resultado del procesamiento del webhook</returns>
    Task<WebhookResult> ProcessWebhookAsync(string payload, string signature);

    /// <summary>
    /// Procesa un reembolso
    /// </summary>
    /// <param name="paymentIntentId">ID del payment intent original</param>
    /// <param name="amount">Monto a reembolsar (null = reembolso total)</param>
    /// <returns>Resultado del reembolso</returns>
    Task<RefundResult> ProcessRefundAsync(string paymentIntentId, decimal? amount = null);
}

/// <summary>
/// Resultado de la creación de un PaymentIntent
/// </summary>
public class PaymentIntentResult
{
    public bool Success { get; set; }
    public string? PaymentIntentId { get; set; }
    public string? ClientSecret { get; set; } // Para Stripe Checkout
    public string? CheckoutUrl { get; set; } // Para PayPal o Yappy
    public string? ErrorMessage { get; set; }
}

/// <summary>
/// Resultado de la confirmación de un pago
/// </summary>
public class PaymentConfirmationResult
{
    public bool Success { get; set; }
    public string? TransactionId { get; set; }
    public PaymentStatus Status { get; set; }
    public string? ErrorMessage { get; set; }
}

/// <summary>
/// Resultado del procesamiento de un webhook
/// </summary>
public class WebhookResult
{
    public bool Success { get; set; }
    public string? PaymentIntentId { get; set; }
    public PaymentStatus? Status { get; set; }
    public string? TransactionId { get; set; }
    public string? ErrorMessage { get; set; }
}

/// <summary>
/// Resultado de un reembolso
/// </summary>
public class RefundResult
{
    public bool Success { get; set; }
    public string? RefundId { get; set; }
    public decimal? RefundAmount { get; set; }
    public string? ErrorMessage { get; set; }
}

