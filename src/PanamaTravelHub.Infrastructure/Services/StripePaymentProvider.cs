using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Domain.Enums;
using Stripe;
using Stripe.Checkout;

namespace PanamaTravelHub.Infrastructure.Services;

/// <summary>
/// Implementación del proveedor de pago Stripe
/// </summary>
public class StripePaymentProvider : IPaymentProvider
{
    private readonly ILogger<StripePaymentProvider> _logger;
    private readonly IConfiguration _configuration;

    public PaymentProvider Provider => PaymentProvider.Stripe;

    public StripePaymentProvider(ILogger<StripePaymentProvider> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;

        // Configurar la API key de Stripe
        var apiKey = _configuration["Stripe:SecretKey"];
        if (string.IsNullOrEmpty(apiKey))
        {
            _logger.LogWarning("Stripe SecretKey no configurada. Los pagos no funcionarán.");
        }
        else
        {
            StripeConfiguration.ApiKey = apiKey;
        }
    }

    public async Task<PaymentIntentResult> CreatePaymentIntentAsync(
        decimal amount,
        string currency,
        Dictionary<string, string>? metadata = null,
        string? customerEmail = null)
    {
        try
        {
            // Stripe usa centavos, convertir dólares a centavos
            var amountInCents = (long)(amount * 100);

            var options = new PaymentIntentCreateOptions
            {
                Amount = amountInCents,
                Currency = currency.ToLower(),
                Metadata = metadata ?? new Dictionary<string, string>(),
                AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
                {
                    Enabled = true
                }
            };

            if (!string.IsNullOrEmpty(customerEmail))
            {
                options.ReceiptEmail = customerEmail;
            }

            var service = new PaymentIntentService();
            var paymentIntent = await service.CreateAsync(options);

            return new PaymentIntentResult
            {
                Success = true,
                PaymentIntentId = paymentIntent.Id,
                ClientSecret = paymentIntent.ClientSecret
            };
        }
        catch (StripeException ex)
        {
            _logger.LogError(ex, "Error al crear PaymentIntent en Stripe");
            return new PaymentIntentResult
            {
                Success = false,
                ErrorMessage = ex.Message
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error inesperado al crear PaymentIntent");
            return new PaymentIntentResult
            {
                Success = false,
                ErrorMessage = "Error inesperado al procesar el pago"
            };
        }
    }

    public async Task<PaymentConfirmationResult> ConfirmPaymentAsync(string paymentIntentId)
    {
        try
        {
            var service = new PaymentIntentService();
            var paymentIntent = await service.GetAsync(paymentIntentId);

            var status = paymentIntent.Status switch
            {
                "succeeded" => PaymentStatus.Captured,
                "requires_capture" => PaymentStatus.Authorized,
                "processing" => PaymentStatus.Authorized,
                "requires_payment_method" => PaymentStatus.Failed,
                "canceled" => PaymentStatus.Failed,
                _ => PaymentStatus.Failed
            };

            return new PaymentConfirmationResult
            {
                Success = status == PaymentStatus.Captured || status == PaymentStatus.Authorized,
                TransactionId = paymentIntent.LatestChargeId,
                Status = status,
                ErrorMessage = status == PaymentStatus.Failed ? paymentIntent.LastPaymentError?.Message : null
            };
        }
        catch (StripeException ex)
        {
            _logger.LogError(ex, "Error al confirmar pago en Stripe: {PaymentIntentId}", paymentIntentId);
            return new PaymentConfirmationResult
            {
                Success = false,
                Status = PaymentStatus.Failed,
                ErrorMessage = ex.Message
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error inesperado al confirmar pago");
            return new PaymentConfirmationResult
            {
                Success = false,
                Status = PaymentStatus.Failed,
                ErrorMessage = "Error inesperado al procesar el pago"
            };
        }
    }

    public async Task<WebhookResult> ProcessWebhookAsync(string payload, string signature)
    {
        try
        {
            var webhookSecret = _configuration["Stripe:WebhookSecret"];
            if (string.IsNullOrEmpty(webhookSecret))
            {
                _logger.LogWarning("Stripe WebhookSecret no configurada. Los webhooks no se pueden verificar.");
                return new WebhookResult
                {
                    Success = false,
                    ErrorMessage = "Webhook secret no configurado"
                };
            }

            var stripeEvent = EventUtility.ConstructEvent(
                payload,
                signature,
                webhookSecret
            );

            _logger.LogInformation("Webhook recibido: {EventType} - {EventId}", stripeEvent.Type, stripeEvent.Id);

            PaymentStatus? status = null;
            string? paymentIntentId = null;
            string? transactionId = null;

            switch (stripeEvent.Type)
            {
                case Events.PaymentIntentSucceeded:
                    var paymentIntentSucceeded = stripeEvent.Data.Object as PaymentIntent;
                    if (paymentIntentSucceeded != null)
                    {
                        paymentIntentId = paymentIntentSucceeded.Id;
                        transactionId = paymentIntentSucceeded.LatestChargeId;
                        status = PaymentStatus.Captured;
                    }
                    break;

                case Events.PaymentIntentPaymentFailed:
                    var paymentIntentFailed = stripeEvent.Data.Object as PaymentIntent;
                    if (paymentIntentFailed != null)
                    {
                        paymentIntentId = paymentIntentFailed.Id;
                        status = PaymentStatus.Failed;
                    }
                    break;

                case Events.ChargeRefunded:
                    var chargeRefunded = stripeEvent.Data.Object as Charge;
                    if (chargeRefunded != null)
                    {
                        paymentIntentId = chargeRefunded.PaymentIntentId;
                        transactionId = chargeRefunded.Id;
                        status = PaymentStatus.Refunded;
                    }
                    break;

                default:
                    _logger.LogInformation("Evento de webhook no manejado: {EventType}", stripeEvent.Type);
                    return new WebhookResult
                    {
                        Success = true, // No es un error, solo no lo manejamos
                        ErrorMessage = $"Evento no manejado: {stripeEvent.Type}"
                    };
            }

            return new WebhookResult
            {
                Success = status != null,
                PaymentIntentId = paymentIntentId,
                Status = status,
                TransactionId = transactionId
            };
        }
        catch (StripeException ex)
        {
            _logger.LogError(ex, "Error al procesar webhook de Stripe");
            return new WebhookResult
            {
                Success = false,
                ErrorMessage = ex.Message
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error inesperado al procesar webhook");
            return new WebhookResult
            {
                Success = false,
                ErrorMessage = "Error inesperado al procesar el webhook"
            };
        }
    }

    public async Task<RefundResult> ProcessRefundAsync(string paymentIntentId, decimal? amount = null)
    {
        try
        {
            // Primero obtener el PaymentIntent para obtener el Charge ID
            var paymentIntentService = new PaymentIntentService();
            var paymentIntent = await paymentIntentService.GetAsync(paymentIntentId);

            if (paymentIntent.LatestChargeId == null)
            {
                return new RefundResult
                {
                    Success = false,
                    ErrorMessage = "No se encontró un charge asociado a este payment intent"
                };
            }

            var refundService = new RefundService();
            var refundOptions = new RefundCreateOptions
            {
                Charge = paymentIntent.LatestChargeId
            };

            if (amount.HasValue)
            {
                // Stripe usa centavos
                refundOptions.Amount = (long)(amount.Value * 100);
            }

            var refund = await refundService.CreateAsync(refundOptions);

            return new RefundResult
            {
                Success = refund.Status == "succeeded" || refund.Status == "pending",
                RefundId = refund.Id,
                RefundAmount = amount ?? (refund.Amount / 100m)
            };
        }
        catch (StripeException ex)
        {
            _logger.LogError(ex, "Error al procesar reembolso en Stripe: {PaymentIntentId}", paymentIntentId);
            return new RefundResult
            {
                Success = false,
                ErrorMessage = ex.Message
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error inesperado al procesar reembolso");
            return new RefundResult
            {
                Success = false,
                ErrorMessage = "Error inesperado al procesar el reembolso"
            };
        }
    }
}

