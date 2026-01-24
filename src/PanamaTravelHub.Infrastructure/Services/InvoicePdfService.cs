using Microsoft.Extensions.Logging;
using PanamaTravelHub.Application.DTOs;
using QuestPDF.Fluent;

namespace PanamaTravelHub.Infrastructure.Services;

public class InvoicePdfService
{
    private readonly ILogger<InvoicePdfService> _logger;

    public InvoicePdfService(ILogger<InvoicePdfService> logger)
    {
        _logger = logger;
    }

    public byte[] Generate(InvoiceViewModel vm)
    {
        try
        {
            var document = new InvoicePdfDocument(vm);
            var pdfBytes = document.GeneratePdf();
            _logger.LogInformation("PDF generado exitosamente para factura {InvoiceNumber}", vm.InvoiceNumber);
            return pdfBytes;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al generar PDF para factura {InvoiceNumber}", vm.InvoiceNumber);
            throw;
        }
    }
}
