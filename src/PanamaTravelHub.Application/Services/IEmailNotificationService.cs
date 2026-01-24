using PanamaTravelHub.Domain.Enums;

namespace PanamaTravelHub.Application.Services;

/// <summary>
/// Servicio para crear y gestionar notificaciones de email
/// </summary>
public interface IEmailNotificationService
{
    /// <summary>
    /// Crea una notificación de email y la agrega a la cola
    /// </summary>
    Task<Guid> QueueEmailAsync(
        string toEmail,
        string subject,
        string body,
        EmailNotificationType type,
        Guid? userId = null,
        Guid? bookingId = null,
        DateTime? scheduledFor = null);

    /// <summary>
    /// Crea una notificación de email usando una plantilla
    /// </summary>
    Task<Guid> QueueTemplatedEmailAsync(
        string toEmail,
        string subject,
        string templateName,
        object templateData,
        EmailNotificationType type,
        Guid? userId = null,
        Guid? bookingId = null,
        DateTime? scheduledFor = null);

    /// <summary>
    /// Envía email de factura con PDF adjunto
    /// </summary>
    Task SendInvoiceAsync(
        string toEmail,
        string invoiceNumber,
        byte[] pdfBytes,
        string fileName,
        string language = "ES",
        Guid? userId = null,
        Guid? bookingId = null);
}

