using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Domain.Enums;

namespace PanamaTravelHub.Infrastructure.Services;

/// <summary>
/// Implementación del proveedor de pago Yappy (Modo de Pruebas)
/// Yappy es un método de pago panameño basado en códigos QR
/// </summary>
public class YappyPaymentProvider : IPaymentProvider
{
    private readonly ILogger<YappyPaymentProvider> _logger;
    private readonly IConfiguration _configuration;

    public PaymentProvider Provider => PaymentProvider.Yappy;

    public YappyPaymentProvider(ILogger<YappyPaymentProvider> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;
    }

    public async Task<PaymentIntentResult> CreatePaymentIntentAsync(
        decimal amount,
        string currency,
        Dictionary<string, string>? metadata = null,
        string? customerEmail = null)
    {
        try
        {
            var merchantId = _configuration["Yappy:MerchantId"];
            var isTestMode = _configuration["Yappy:TestMode"] != "false"; // Por defecto modo prueba

            if (string.IsNullOrEmpty(merchantId))
            {
                _logger.LogWarning("Yappy MerchantId no configurado. Usando modo simulación.");
            }

            // En modo de pruebas, generamos un código QR simulado
            var baseUrl = _configuration["BaseUrl"] ?? "https://localhost:5001";
            var paymentId = $"yappy_{Guid.NewGuid()}";
            var checkoutUrl = $"{baseUrl}/api/payments/yappy/qr?paymentId={paymentId}&amount={amount}";

            _logger.LogInformation("Yappy PaymentIntent creado. Modo: {Mode}, Amount: {Amount} {Currency}", 
                isTestMode ? "Pruebas" : "Producción", amount, currency);

            await Task.CompletedTask; // Para cumplir con async
            return new PaymentIntentResult
            {
                Success = true,
                PaymentIntentId = paymentId,
                CheckoutUrl = checkoutUrl
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear PaymentIntent en Yappy");
            await Task.CompletedTask; // Para cumplir con async
            return new PaymentIntentResult
            {
                Success = false,
                ErrorMessage = ex.Message
            };
        }
    }

    public async Task<PaymentConfirmationResult> ConfirmPaymentAsync(string paymentIntentId)
    {
        try
        {
            // En modo de pruebas, simulamos una confirmación exitosa
            if (paymentIntentId.StartsWith("yappy_"))
            {
                _logger.LogInformation("Confirmando pago Yappy simulado: {PaymentIntentId}", paymentIntentId);
                
                // Simular delay de procesamiento
                await Task.Delay(1000);
                
                return new PaymentConfirmationResult
                {
                    Success = true,
                    Status = PaymentStatus.Captured,
                    TransactionId = $"yappy_txn_{Guid.NewGuid()}"
                };
            }

            return new PaymentConfirmationResult
            {
                Success = false,
                ErrorMessage = "Pago no encontrado"
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al confirmar pago en Yappy: {PaymentIntentId}", paymentIntentId);
            return new PaymentConfirmationResult
            {
                Success = false,
                ErrorMessage = ex.Message
            };
        }
    }

    public Task<WebhookResult> ProcessWebhookAsync(string payload, string signature)
    {
        // Implementación básica para webhooks de Yappy
        _logger.LogInformation("Webhook de Yappy recibido");
        
        return Task.FromResult(new WebhookResult
        {
            Success = true,
            ErrorMessage = "Webhook procesado (modo simulación)"
        });
    }

    public async Task<RefundResult> ProcessRefundAsync(string paymentIntentId, decimal? amount = null)
    {
        try
        {
            _logger.LogInformation("Procesando reembolso Yappy: {PaymentIntentId}, Amount: {Amount}", 
                paymentIntentId, amount);
            
            await Task.Delay(500); // Simular delay
            
            return new RefundResult
            {
                Success = true,
                RefundId = $"yappy_refund_{Guid.NewGuid()}",
                RefundAmount = amount
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al procesar reembolso en Yappy");
            return new RefundResult
            {
                Success = false,
                ErrorMessage = ex.Message
            };
        }
    }
}

