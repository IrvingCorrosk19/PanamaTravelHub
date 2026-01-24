using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Domain.Enums;
using PanamaTravelHub.Infrastructure.Data;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/payments/partial")]
[Authorize(Policy = "AdminOrCustomer")]
public class PartialPaymentsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<PartialPaymentsController> _logger;

    public PartialPaymentsController(ApplicationDbContext context, ILogger<PartialPaymentsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Crea un plan de pagos en cuotas para una reserva
    /// </summary>
    [HttpPost("installments")]
    public async Task<ActionResult> CreateInstallmentPlan(
        [FromBody] CreateInstallmentPlanRequestDto request)
    {
        try
        {
            var booking = await _context.Bookings
                .Include(b => b.Payments)
                .FirstOrDefaultAsync(b => b.Id == request.BookingId);

            if (booking == null)
            {
                return NotFound(new { message = "Reserva no encontrada" });
            }

            if (request.NumberOfInstallments < 2 || request.NumberOfInstallments > 12)
            {
                return BadRequest(new { message = "El número de cuotas debe estar entre 2 y 12" });
            }

            var installmentAmount = booking.TotalAmount / request.NumberOfInstallments;
            var remainder = booking.TotalAmount % request.NumberOfInstallments;
            var firstInstallmentAmount = installmentAmount + remainder; // Primera cuota incluye el resto

            booking.AllowPartialPayments = true;
            booking.PaymentPlanType = 1; // Installments

            // Crear registros de pagos para cada cuota
            var payments = new List<Payment>();
            var parentPayment = new Payment
            {
                BookingId = booking.Id,
                Provider = PaymentProvider.Stripe, // Por defecto
                Status = PaymentStatus.Initiated,
                Amount = booking.TotalAmount,
                IsPartial = true,
                TotalInstallments = request.NumberOfInstallments
            };
            payments.Add(parentPayment);

            for (int i = 1; i <= request.NumberOfInstallments; i++)
            {
                var amount = i == 1 ? firstInstallmentAmount : installmentAmount;
                var installmentPayment = new Payment
                {
                    BookingId = booking.Id,
                    Provider = PaymentProvider.Stripe,
                    Status = PaymentStatus.Initiated,
                    Amount = amount,
                    IsPartial = true,
                    InstallmentNumber = i,
                    TotalInstallments = request.NumberOfInstallments,
                    ParentPaymentId = parentPayment.Id
                };
                payments.Add(installmentPayment);
            }

            _context.Payments.AddRange(payments);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Plan de cuotas creado exitosamente",
                totalInstallments = request.NumberOfInstallments,
                installmentAmount = installmentAmount,
                firstInstallmentAmount = firstInstallmentAmount
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creando plan de cuotas");
            return StatusCode(500, new { message = "Error al crear plan de cuotas" });
        }
    }

    /// <summary>
    /// Realiza un pago parcial
    /// </summary>
    [HttpPost("pay")]
    public async Task<ActionResult> MakePartialPayment(
        [FromBody] MakePartialPaymentRequestDto request)
    {
        try
        {
            var booking = await _context.Bookings
                .Include(b => b.Payments)
                .FirstOrDefaultAsync(b => b.Id == request.BookingId);

            if (booking == null)
            {
                return NotFound(new { message = "Reserva no encontrada" });
            }

            if (!booking.AllowPartialPayments)
            {
                return BadRequest(new { message = "Esta reserva no permite pagos parciales" });
            }

            var totalPaid = booking.Payments
                .Where(p => p.Status == PaymentStatus.Captured)
                .Sum(p => p.Amount);

            var remainingAmount = booking.TotalAmount - totalPaid;

            if (request.Amount > remainingAmount)
            {
                return BadRequest(new { message = $"El monto excede el saldo pendiente de ${remainingAmount:F2}" });
            }

            if (request.Amount <= 0)
            {
                return BadRequest(new { message = "El monto debe ser mayor a 0" });
            }

            var partialPayment = new Payment
            {
                BookingId = booking.Id,
                Provider = request.Provider ?? PaymentProvider.Stripe,
                Status = PaymentStatus.Initiated,
                Amount = request.Amount,
                IsPartial = true,
                Currency = request.Currency ?? "USD"
            };

            _context.Payments.Add(partialPayment);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Pago parcial registrado",
                paymentId = partialPayment.Id,
                amount = partialPayment.Amount,
                remainingAmount = remainingAmount - request.Amount
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error procesando pago parcial");
            return StatusCode(500, new { message = "Error al procesar pago parcial" });
        }
    }

    /// <summary>
    /// Obtiene el estado de pagos de una reserva
    /// </summary>
    [HttpGet("booking/{bookingId}/status")]
    public async Task<ActionResult> GetPaymentStatus(Guid bookingId)
    {
        try
        {
            var booking = await _context.Bookings
                .Include(b => b.Payments)
                .FirstOrDefaultAsync(b => b.Id == bookingId);

            if (booking == null)
            {
                return NotFound(new { message = "Reserva no encontrada" });
            }

            var totalPaid = booking.Payments
                .Where(p => p.Status == PaymentStatus.Captured)
                .Sum(p => p.Amount);

            var pendingPayments = booking.Payments
                .Where(p => p.Status == PaymentStatus.Initiated || p.Status == PaymentStatus.Authorized)
                .ToList();

            return Ok(new
            {
                totalAmount = booking.TotalAmount,
                totalPaid = totalPaid,
                remainingAmount = booking.TotalAmount - totalPaid,
                paymentPercentage = booking.TotalAmount > 0 ? (totalPaid / booking.TotalAmount) * 100 : 0,
                allowPartialPayments = booking.AllowPartialPayments,
                paymentPlanType = booking.PaymentPlanType,
                pendingPayments = pendingPayments.Select(p => new
                {
                    id = p.Id,
                    amount = p.Amount,
                    status = p.Status.ToString(),
                    installmentNumber = p.InstallmentNumber
                })
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error obteniendo estado de pagos");
            return StatusCode(500, new { message = "Error al obtener estado de pagos" });
        }
    }
}

// DTOs
public class CreateInstallmentPlanRequestDto
{
    public Guid BookingId { get; set; }
    public int NumberOfInstallments { get; set; }
}

public class MakePartialPaymentRequestDto
{
    public Guid BookingId { get; set; }
    public decimal Amount { get; set; }
    public PaymentProvider? Provider { get; set; }
    public string? Currency { get; set; }
}
