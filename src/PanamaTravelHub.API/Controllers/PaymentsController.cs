using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using PanamaTravelHub.Application.DTOs;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Domain.Enums;
using PanamaTravelHub.Infrastructure.Data;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/payments")]
[Authorize]
public class PaymentsController : ControllerBase
{
    private readonly IPaymentProviderFactory _paymentProviderFactory;
    private readonly ApplicationDbContext _context;
    private readonly ILogger<PaymentsController> _logger;
    private readonly IConfiguration _configuration;
    private readonly IEmailNotificationService _emailNotificationService;

    public PaymentsController(
        IPaymentProviderFactory paymentProviderFactory,
        ApplicationDbContext context,
        ILogger<PaymentsController> logger,
        IConfiguration configuration,
        IEmailNotificationService emailNotificationService)
    {
        _paymentProviderFactory = paymentProviderFactory;
        _context = context;
        _logger = logger;
        _configuration = configuration;
        _emailNotificationService = emailNotificationService;
    }

    /// <summary>
    /// Obtiene la clave pública de Stripe para el frontend
    /// </summary>
    [HttpGet("stripe/config")]
    [AllowAnonymous]
    public ActionResult<StripeConfigDto> GetStripeConfig()
    {
        var publishableKey = _configuration["Stripe:PublishableKey"];
        if (string.IsNullOrEmpty(publishableKey))
        {
            return BadRequest(new { message = "Stripe no está configurado" });
        }

        return Ok(new StripeConfigDto
        {
            PublishableKey = publishableKey
        });
    }

    /// <summary>
    /// Crea un pago para una reserva
    /// </summary>
    [HttpPost("create")]
    public async Task<ActionResult<CreatePaymentResponseDto>> CreatePayment([FromBody] CreatePaymentRequestDto request)
    {
        try
        {
            // Verificar que la reserva existe y pertenece al usuario
            var booking = await _context.Bookings
                .Include(b => b.User)
                .FirstOrDefaultAsync(b => b.Id == request.BookingId);

            if (booking == null)
            {
                return NotFound(new { message = "Reserva no encontrada" });
            }

            // TODO: Verificar que el usuario actual es el dueño de la reserva
            // var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            // Verificar que la reserva no tenga un pago exitoso ya
            var existingPayment = await _context.Payments
                .FirstOrDefaultAsync(p => p.BookingId == request.BookingId && 
                                         (p.Status == PaymentStatus.Captured || p.Status == PaymentStatus.Authorized));

            if (existingPayment != null)
            {
                return BadRequest(new { message = "Esta reserva ya tiene un pago procesado" });
            }

            // Obtener el proveedor de pago según el método seleccionado
            var provider = request.Provider ?? PaymentProvider.Stripe; // Por defecto Stripe
            var paymentProvider = _paymentProviderFactory.GetProvider(provider);

            // Crear el payment intent en el proveedor
            var metadata = new Dictionary<string, string>
            {
                { "bookingId", booking.Id.ToString() },
                { "userId", booking.UserId.ToString() }
            };

            var paymentIntentResult = await paymentProvider.CreatePaymentIntentAsync(
                booking.TotalAmount,
                request.Currency ?? "USD",
                metadata,
                booking.User.Email
            );

            if (!paymentIntentResult.Success)
            {
                return BadRequest(new { message = paymentIntentResult.ErrorMessage ?? "Error al crear el pago" });
            }

            // Crear el registro de pago en la base de datos
            var payment = new Payment
            {
                BookingId = booking.Id,
                Provider = provider,
                Status = PaymentStatus.Initiated,
                Amount = booking.TotalAmount,
                Currency = request.Currency ?? "USD",
                ProviderPaymentIntentId = paymentIntentResult.PaymentIntentId
            };

            _context.Payments.Add(payment);
            await _context.SaveChangesAsync();

            return Ok(new CreatePaymentResponseDto
            {
                PaymentId = payment.Id,
                PaymentIntentId = paymentIntentResult.PaymentIntentId ?? string.Empty,
                ClientSecret = paymentIntentResult.ClientSecret,
                CheckoutUrl = paymentIntentResult.CheckoutUrl,
                Amount = payment.Amount,
                Currency = payment.Currency
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear pago para reserva {BookingId}", request.BookingId);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Confirma un pago después de que el usuario completa el checkout
    /// </summary>
    [HttpPost("confirm")]
    public async Task<ActionResult<ConfirmPaymentResponseDto>> ConfirmPayment([FromBody] ConfirmPaymentRequestDto request)
    {
        try
        {
            // Buscar el pago en la base de datos
            var payment = await _context.Payments
                .Include(p => p.Booking)
                .FirstOrDefaultAsync(p => p.ProviderPaymentIntentId == request.PaymentIntentId);

            if (payment == null)
            {
                return NotFound(new { message = "Pago no encontrado" });
            }

            // Obtener el proveedor correcto según el pago
            var paymentProvider = _paymentProviderFactory.GetProvider(payment.Provider);
            
            // Confirmar el pago con el proveedor
            var confirmationResult = await paymentProvider.ConfirmPaymentAsync(request.PaymentIntentId);

            if (!confirmationResult.Success)
            {
                // Actualizar el estado del pago a Failed
                payment.Status = PaymentStatus.Failed;
                payment.FailureReason = confirmationResult.ErrorMessage;
                await _context.SaveChangesAsync();

                return BadRequest(new { message = confirmationResult.ErrorMessage ?? "Error al confirmar el pago" });
            }

            // Actualizar el pago en la base de datos
            payment.Status = confirmationResult.Status;
            payment.ProviderTransactionId = confirmationResult.TransactionId;

            if (confirmationResult.Status == PaymentStatus.Captured)
            {
                payment.CapturedAt = DateTime.UtcNow;
                // Actualizar el estado de la reserva a Confirmed
                payment.Booking.Status = BookingStatus.Confirmed;
                
                // Cargar relaciones para el email
                await _context.Entry(payment.Booking)
                    .Reference(b => b.User)
                    .LoadAsync();
                await _context.Entry(payment.Booking)
                    .Reference(b => b.Tour)
                    .LoadAsync();
                
                // Enviar email de confirmación de pago
                try
                {
                    var customerEmail = payment.Booking.User.Email;
                    var customerName = $"{payment.Booking.User.FirstName} {payment.Booking.User.LastName}";
                    
                    await _emailNotificationService.QueueTemplatedEmailAsync(
                        customerEmail,
                        $"Confirmación de Pago - {payment.Booking.Tour.Name}",
                        "payment-confirmation",
                        new
                        {
                            CustomerName = customerName,
                            Amount = payment.Amount.ToString("C"),
                            PaymentMethod = payment.Provider.ToString(),
                            TransactionId = payment.ProviderTransactionId ?? "N/A",
                            PaymentDate = DateTime.UtcNow.ToString("dd/MM/yyyy HH:mm"),
                            BookingId = payment.Booking.Id.ToString(),
                            Year = DateTime.UtcNow.Year
                        },
                        Domain.Enums.EmailNotificationType.PaymentConfirmation,
                        payment.Booking.UserId,
                        payment.Booking.Id
                    );
                    
                    // También enviar email de confirmación de reserva
                    await _emailNotificationService.QueueTemplatedEmailAsync(
                        customerEmail,
                        $"Reserva Confirmada - {payment.Booking.Tour.Name}",
                        "booking-confirmation",
                        new
                        {
                            CustomerName = customerName,
                            TourName = payment.Booking.Tour.Name,
                            TourDate = payment.Booking.TourDate?.TourDateTime.ToString("dd/MM/yyyy HH:mm") ?? "Por confirmar",
                            NumberOfParticipants = payment.Booking.NumberOfParticipants,
                            TotalAmount = payment.Booking.TotalAmount.ToString("C"),
                            BookingId = payment.Booking.Id.ToString(),
                            Year = DateTime.UtcNow.Year
                        },
                        Domain.Enums.EmailNotificationType.BookingConfirmation,
                        payment.Booking.UserId,
                        payment.Booking.Id
                    );
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error al enviar emails de confirmación para booking {BookingId}", payment.Booking.Id);
                    // No fallar la confirmación del pago si falla el email
                }
            }
            else if (confirmationResult.Status == PaymentStatus.Authorized)
            {
                payment.AuthorizedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();

            return Ok(new ConfirmPaymentResponseDto
            {
                PaymentId = payment.Id,
                Status = payment.Status.ToString(),
                TransactionId = payment.ProviderTransactionId
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al confirmar pago {PaymentIntentId}", request.PaymentIntentId);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Procesa un webhook del proveedor de pago
    /// </summary>
    [HttpPost("webhook/{provider}")]
    [AllowAnonymous] // Los webhooks deben ser públicos pero verificados por firma
    public async Task<IActionResult> ProcessWebhook(
        [FromRoute] string provider,
        [FromBody] string payload)
    {
        try
        {
            // Obtener la firma del header
            var signature = Request.Headers["Stripe-Signature"].FirstOrDefault();
            if (string.IsNullOrEmpty(signature))
            {
                return BadRequest(new { message = "Firma de webhook no proporcionada" });
            }

            // Procesar el webhook según el proveedor
            PaymentProvider paymentProviderEnum;
            if (provider.ToLower() == "stripe")
            {
                paymentProviderEnum = PaymentProvider.Stripe;
            }
            else if (provider.ToLower() == "paypal")
            {
                paymentProviderEnum = PaymentProvider.PayPal;
            }
            else if (provider.ToLower() == "yappy")
            {
                paymentProviderEnum = PaymentProvider.Yappy;
            }
            else
            {
                return BadRequest(new { message = $"Proveedor {provider} no soportado" });
            }
            
            var paymentProvider = _paymentProviderFactory.GetProvider(paymentProviderEnum);

            var webhookResult = await paymentProvider.ProcessWebhookAsync(payload, signature);

            if (!webhookResult.Success || webhookResult.PaymentIntentId == null)
            {
                _logger.LogWarning("Webhook procesado pero sin acción: {Message}", webhookResult.ErrorMessage);
                return Ok(); // Stripe espera 200 incluso si no procesamos el evento
            }

            // Buscar el pago en la base de datos
            var payment = await _context.Payments
                .Include(p => p.Booking)
                .FirstOrDefaultAsync(p => p.ProviderPaymentIntentId == webhookResult.PaymentIntentId);

            if (payment == null)
            {
                _logger.LogWarning("Pago no encontrado para PaymentIntentId: {PaymentIntentId}", webhookResult.PaymentIntentId);
                return Ok(); // Retornar 200 para que Stripe no reintente
            }

            // Actualizar el estado del pago
            if (webhookResult.Status.HasValue)
            {
                payment.Status = webhookResult.Status.Value;

                if (webhookResult.Status == PaymentStatus.Captured)
                {
                    payment.CapturedAt = DateTime.UtcNow;
                    payment.Booking.Status = BookingStatus.Confirmed;
                }
                else if (webhookResult.Status == PaymentStatus.Refunded)
                {
                    payment.RefundedAt = DateTime.UtcNow;
                }
                else if (webhookResult.Status == PaymentStatus.Failed)
                {
                    payment.FailureReason = webhookResult.ErrorMessage;
                }

                if (!string.IsNullOrEmpty(webhookResult.TransactionId))
                {
                    payment.ProviderTransactionId = webhookResult.TransactionId;
                }

                await _context.SaveChangesAsync();
            }

            return Ok();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al procesar webhook de {Provider}", provider);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Procesa un reembolso
    /// </summary>
    [HttpPost("refund")]
    [Authorize(Policy = "AdminOnly")]
    public async Task<ActionResult<RefundResponseDto>> ProcessRefund([FromBody] RefundRequestDto request)
    {
        try
        {
            var payment = await _context.Payments
                .Include(p => p.Booking)
                .FirstOrDefaultAsync(p => p.Id == request.PaymentId);

            if (payment == null)
            {
                return NotFound(new { message = "Pago no encontrado" });
            }

            if (payment.Status != PaymentStatus.Captured)
            {
                return BadRequest(new { message = "Solo se pueden reembolsar pagos capturados" });
            }

            if (string.IsNullOrEmpty(payment.ProviderPaymentIntentId))
            {
                return BadRequest(new { message = "PaymentIntentId no encontrado" });
            }

            var paymentProvider = _paymentProviderFactory.GetProvider(payment.Provider);
            var refundResult = await paymentProvider.ProcessRefundAsync(
                payment.ProviderPaymentIntentId,
                request.Amount
            );

            if (!refundResult.Success)
            {
                return BadRequest(new { message = refundResult.ErrorMessage ?? "Error al procesar el reembolso" });
            }

            // Actualizar el pago
            payment.Status = PaymentStatus.Refunded;
            payment.RefundedAt = DateTime.UtcNow;
            if (refundResult.RefundId != null)
            {
                payment.ProviderTransactionId = refundResult.RefundId;
            }

            // Actualizar el estado de la reserva
            payment.Booking.Status = BookingStatus.Cancelled;

            await _context.SaveChangesAsync();

            return Ok(new RefundResponseDto
            {
                PaymentId = payment.Id,
                RefundId = refundResult.RefundId,
                RefundAmount = refundResult.RefundAmount ?? payment.Amount
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al procesar reembolso para pago {PaymentId}", request.PaymentId);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }
}

// DTOs
public class CreatePaymentResponseDto
{
    public Guid PaymentId { get; set; }
    public string PaymentIntentId { get; set; } = string.Empty;
    public string? ClientSecret { get; set; }
    public string? CheckoutUrl { get; set; }
    public decimal Amount { get; set; }
    public string Currency { get; set; } = string.Empty;
}

public class ConfirmPaymentResponseDto
{
    public Guid PaymentId { get; set; }
    public string Status { get; set; } = string.Empty;
    public string? TransactionId { get; set; }
}

public class RefundResponseDto
{
    public Guid PaymentId { get; set; }
    public string? RefundId { get; set; }
    public decimal RefundAmount { get; set; }
}

public class StripeConfigDto
{
    public string PublishableKey { get; set; } = string.Empty;
}

