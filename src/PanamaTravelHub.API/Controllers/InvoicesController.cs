using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PanamaTravelHub.Application.Services;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/invoices")]
[Authorize(Policy = "AdminOrCustomer")]
public class InvoicesController : ControllerBase
{
    private readonly IInvoiceService _invoiceService;
    private readonly ILogger<InvoicesController> _logger;
    private readonly IWebHostEnvironment _environment;

    public InvoicesController(
        IInvoiceService invoiceService,
        ILogger<InvoicesController> logger,
        IWebHostEnvironment environment)
    {
        _invoiceService = invoiceService;
        _logger = logger;
        _environment = environment;
    }

    /// <summary>
    /// Obtiene todas las facturas del usuario actual
    /// </summary>
    [HttpGet("my")]
    public async Task<IActionResult> GetMyInvoices()
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var invoices = await _invoiceService.GetMyInvoicesAsync(userId);
            return Ok(invoices);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener facturas del usuario");
            return StatusCode(500, new { message = "Error al obtener facturas" });
        }
    }

    /// <summary>
    /// Obtiene una factura específica por ID
    /// </summary>
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetInvoice(Guid id)
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var isAdmin = User.IsInRole("Admin");

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var invoice = await _invoiceService.GetByIdAsync(id, userId);
            if (invoice == null)
            {
                return NotFound(new { message = "Factura no encontrada" });
            }

            return Ok(invoice);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener factura {InvoiceId}", id);
            return StatusCode(500, new { message = "Error al obtener factura" });
        }
    }

    /// <summary>
    /// Descarga el PDF de una factura
    /// </summary>
    [HttpGet("{id:guid}/pdf")]
    public async Task<IActionResult> DownloadInvoicePdf(Guid id)
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var invoice = await _invoiceService.GetByIdAsync(id, userId);
            if (invoice == null)
            {
                return NotFound(new { message = "Factura no encontrada" });
            }

            if (string.IsNullOrEmpty(invoice.PdfUrl))
            {
                return NotFound(new { message = "PDF de factura no disponible" });
            }

            // Construir ruta física del archivo
            // PdfUrl está en formato: /invoices/{year}/{invoiceNumber}.pdf
            var relativePath = invoice.PdfUrl.TrimStart('/');
            var webRootPath = _environment.WebRootPath ?? Path.Combine(_environment.ContentRootPath, "wwwroot");
            var filePath = Path.Combine(webRootPath, relativePath);

            if (!System.IO.File.Exists(filePath))
            {
                _logger.LogWarning("Archivo PDF no encontrado: {FilePath} para factura {InvoiceNumber}", 
                    filePath, invoice.InvoiceNumber);
                return NotFound(new { message = "Archivo PDF no encontrado" });
            }

            var pdfBytes = await System.IO.File.ReadAllBytesAsync(filePath);
            return File(pdfBytes, "application/pdf", $"{invoice.InvoiceNumber}.pdf");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al descargar PDF de factura {InvoiceId}", id);
            return StatusCode(500, new { message = "Error al descargar PDF" });
        }
    }
}
