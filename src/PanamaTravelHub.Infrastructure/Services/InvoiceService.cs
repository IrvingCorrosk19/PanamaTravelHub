using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Hosting;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Application.DTOs;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Infrastructure.Data;

namespace PanamaTravelHub.Infrastructure.Services;

public class InvoiceService : IInvoiceService
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<InvoiceService> _logger;
    private readonly InvoicePdfService _pdfService;
    private readonly IHostEnvironment _environment;
    private readonly IEmailNotificationService _emailNotificationService;

    public InvoiceService(
        ApplicationDbContext context,
        ILogger<InvoiceService> logger,
        InvoicePdfService pdfService,
        IHostEnvironment environment,
        IEmailNotificationService emailNotificationService)
    {
        _context = context;
        _logger = logger;
        _pdfService = pdfService;
        _environment = environment;
        _emailNotificationService = emailNotificationService;
    }

    public async Task<Invoice> GenerateInvoiceAsync(Booking booking, string language = "ES")
    {
        // Validar que la reserva esté confirmada
        if (booking.Status != Domain.Enums.BookingStatus.Confirmed)
        {
            throw new InvalidOperationException("Solo se pueden generar facturas para reservas confirmadas");
        }

        // Verificar si ya existe una factura para esta reserva
        var existingInvoice = await _context.Invoices
            .FirstOrDefaultAsync(i => i.BookingId == booking.Id && i.Status == "Issued");

        if (existingInvoice != null)
        {
            _logger.LogInformation("Ya existe una factura para la reserva {BookingId}: {InvoiceNumber}", 
                booking.Id, existingInvoice.InvoiceNumber);
            return existingInvoice;
        }

        var year = DateTime.UtcNow.Year;

        // Obtener o crear secuencia para el año actual (transaccional)
        var sequence = await _context.InvoiceSequences
            .FirstOrDefaultAsync(s => s.Year == year);

        if (sequence == null)
        {
            sequence = new InvoiceSequence
            {
                Year = year,
                CurrentValue = 0
            };
            _context.InvoiceSequences.Add(sequence);
            await _context.SaveChangesAsync();
        }

        // Incrementar secuencia de forma transaccional
        sequence.CurrentValue++;
        var invoiceNumber = $"F-{year}-{sequence.CurrentValue:D6}";

        // Calcular valores (por ahora sin descuentos ni impuestos)
        var subtotal = booking.TotalAmount;
        var discount = 0m; // TODO: Calcular desde cupones si existen
        var taxes = 0m; // Por ahora 0
        var total = subtotal - discount + taxes;

        // Crear factura
        var invoice = new Invoice
        {
            Id = Guid.NewGuid(),
            InvoiceNumber = invoiceNumber,
            BookingId = booking.Id,
            UserId = booking.UserId,
            Currency = "USD", // TODO: Obtener desde booking o configuración
            Subtotal = subtotal,
            Discount = discount,
            Taxes = taxes,
            Total = total,
            Language = language,
            IssuedAt = DateTime.UtcNow,
            Status = "Issued"
        };

        _context.Invoices.Add(invoice);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Factura generada: {InvoiceNumber} para reserva {BookingId}", 
            invoiceNumber, booking.Id);

        // Generar PDF y enviar email automáticamente
        try
        {
            // Cargar User si no está cargado
            if (booking.User == null)
            {
                await _context.Entry(booking)
                    .Reference(b => b.User)
                    .LoadAsync();
            }

            var pdfBytes = await GenerateAndSavePdfAsync(invoice, booking);
            
            // Enviar email con PDF adjunto
            try
            {
                await _emailNotificationService.SendInvoiceAsync(
                    toEmail: booking.User?.Email ?? throw new InvalidOperationException("User email is required"),
                    invoiceNumber: invoice.InvoiceNumber,
                    pdfBytes: pdfBytes,
                    fileName: $"{invoice.InvoiceNumber}.pdf",
                    language: language,
                    userId: booking.UserId,
                    bookingId: booking.Id
                );
            }
            catch (Exception ex)
            {
                // No fallar si el email falla (se puede reenviar después)
                _logger.LogError(ex, "Error al enviar email de factura {InvoiceNumber}", invoiceNumber);
            }
        }
        catch (Exception ex)
        {
            // No fallar la creación de factura si el PDF falla (se puede regenerar después)
            _logger.LogError(ex, "Error al generar PDF para factura {InvoiceNumber}", invoiceNumber);
        }

        return invoice;
    }

    public async Task<List<Invoice>> GetMyInvoicesAsync(Guid userId)
    {
        return await _context.Invoices
            .Include(i => i.Booking)
                .ThenInclude(b => b.Tour)
            .Where(i => i.UserId == userId)
            .OrderByDescending(i => i.IssuedAt)
            .ToListAsync();
    }

    public async Task<Invoice?> GetByIdAsync(Guid id, Guid userId)
    {
        return await _context.Invoices
            .Include(i => i.Booking)
                .ThenInclude(b => b.Tour)
            .Include(i => i.Booking)
                .ThenInclude(b => b.User)
            .Include(i => i.Booking)
                .ThenInclude(b => b.Participants)
            .Include(i => i.User)
            .FirstOrDefaultAsync(i => i.Id == id && i.UserId == userId);
    }

    private async Task<byte[]> GenerateAndSavePdfAsync(Invoice invoice, Booking booking)
    {
        // Cargar relaciones necesarias
        await _context.Entry(booking)
            .Reference(b => b.Tour)
            .LoadAsync();
        await _context.Entry(booking)
            .Reference(b => b.User)
            .LoadAsync();
        if (booking.TourDateId.HasValue)
        {
            await _context.Entry(booking)
                .Reference(b => b.TourDate)
                .LoadAsync();
        }

        // Construir ViewModel
        var viewModel = new InvoiceViewModel
        {
            InvoiceNumber = invoice.InvoiceNumber,
            IssuedAt = invoice.IssuedAt,
            CustomerName = $"{booking.User.FirstName} {booking.User.LastName}",
            CustomerEmail = booking.User.Email,
            CustomerPhone = booking.User.Phone,
            TourName = booking.Tour.Name,
            TourDate = booking.TourDate?.TourDateTime,
            TourLocation = booking.Tour.Location,
            Participants = booking.NumberOfParticipants,
            Subtotal = invoice.Subtotal,
            Discount = invoice.Discount,
            Taxes = invoice.Taxes,
            Total = invoice.Total,
            Currency = invoice.Currency,
            Language = invoice.Language
        };

        // Generar PDF
        var pdfBytes = _pdfService.Generate(viewModel);

        // Guardar PDF en wwwroot/invoices/{year}/
        var year = invoice.IssuedAt.Year;
        var invoicesDirectory = Path.Combine(_environment.ContentRootPath, "wwwroot", "invoices", year.ToString());
        if (!Directory.Exists(invoicesDirectory))
        {
            Directory.CreateDirectory(invoicesDirectory);
        }

        var fileName = $"{invoice.InvoiceNumber}.pdf";
        var filePath = Path.Combine(invoicesDirectory, fileName);
        await File.WriteAllBytesAsync(filePath, pdfBytes);

        // Actualizar URL en la factura (ruta relativa para servir desde wwwroot)
        invoice.PdfUrl = $"/invoices/{year}/{fileName}";
        invoice.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        _logger.LogInformation("PDF guardado para factura {InvoiceNumber} en {FilePath}", 
            invoice.InvoiceNumber, filePath);

        return pdfBytes;
    }
}
