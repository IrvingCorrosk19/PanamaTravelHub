using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Domain.Enums;
using PanamaTravelHub.Infrastructure.Data;

namespace PanamaTravelHub.Infrastructure.Services;

/// <summary>
/// Servicio para crear y gestionar notificaciones de email
/// </summary>
public class EmailNotificationService : IEmailNotificationService
{
    private readonly ApplicationDbContext _context;
    private readonly IEmailTemplateService _templateService;
    private readonly IEmailService _emailService;
    private readonly ILogger<EmailNotificationService> _logger;

    public EmailNotificationService(
        ApplicationDbContext context,
        IEmailTemplateService templateService,
        IEmailService emailService,
        ILogger<EmailNotificationService> logger)
    {
        _context = context;
        _templateService = templateService;
        _emailService = emailService;
        _logger = logger;
    }

    public async Task<Guid> QueueEmailAsync(
        string toEmail,
        string subject,
        string body,
        EmailNotificationType type,
        Guid? userId = null,
        Guid? bookingId = null,
        DateTime? scheduledFor = null)
    {
        var notification = new EmailNotification
        {
            ToEmail = toEmail,
            Subject = subject,
            Body = body,
            Type = type,
            Status = EmailNotificationStatus.Pending,
            UserId = userId,
            BookingId = bookingId,
            ScheduledFor = scheduledFor
        };

        _context.EmailNotifications.Add(notification);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Email agregado a la cola: {EmailId}, Tipo: {Type}, Para: {ToEmail}", 
            notification.Id, type, toEmail);

        return notification.Id;
    }

    public async Task<Guid> QueueTemplatedEmailAsync(
        string toEmail,
        string subject,
        string templateName,
        object templateData,
        EmailNotificationType type,
        Guid? userId = null,
        Guid? bookingId = null,
        DateTime? scheduledFor = null)
    {
        try
        {
            var body = await _templateService.RenderTemplateAsync(templateName, templateData);
            return await QueueEmailAsync(toEmail, subject, body, type, userId, bookingId, scheduledFor);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear email con plantilla {TemplateName}", templateName);
            throw;
        }
    }

    public async Task SendInvoiceAsync(
        string toEmail,
        string invoiceNumber,
        byte[] pdfBytes,
        string fileName,
        string language = "ES",
        Guid? userId = null,
        Guid? bookingId = null)
    {
        try
        {
            // Textos bilingües
            var subject = language == "EN" 
                ? $"Your booking invoice – {invoiceNumber}"
                : $"Factura de tu reserva – {invoiceNumber}";

            var body = language == "EN"
                ? $@"
                    <p>Dear Customer,</p>
                    <p>Your invoice <strong>{invoiceNumber}</strong> is attached to this email.</p>
                    <p>You can also download it from your <a href=""{GetProfileUrl()}"">profile</a>.</p>
                    <p>Thank you for your booking!</p>
                    <p>Best regards,<br>PanamaTravelHub Team</p>
                    <hr>
                    <p style=""font-size: 0.9em; color: #666;"">If you have any questions, please contact our support team.</p>
                "
                : $@"
                    <p>Estimado Cliente,</p>
                    <p>Tu factura <strong>{invoiceNumber}</strong> está adjunta a este correo.</p>
                    <p>También puedes descargarla desde tu <a href=""{GetProfileUrl()}"">perfil</a>.</p>
                    <p>¡Gracias por tu reserva!</p>
                    <p>Saludos cordiales,<br>Equipo PanamaTravelHub</p>
                    <hr>
                    <p style=""font-size: 0.9em; color: #666;"">Si tienes alguna pregunta, por favor contacta a nuestro equipo de soporte.</p>
                ";

            // Enviar email con adjunto directamente (no por cola, porque necesita adjunto en memoria)
            var sent = await _emailService.SendEmailWithAttachmentAsync(
                toEmail,
                subject,
                body,
                pdfBytes,
                fileName,
                "application/pdf"
            );

            if (sent)
            {
                // Registrar en la tabla de notificaciones para auditoría
                await QueueEmailAsync(
                    toEmail,
                    subject,
                    body,
                    EmailNotificationType.PaymentConfirmation, // Usar tipo existente o crear InvoiceSent
                    userId,
                    bookingId
                );
                _logger.LogInformation("Email de factura enviado exitosamente a {ToEmail} para factura {InvoiceNumber}", 
                    toEmail, invoiceNumber);
            }
            else
            {
                _logger.LogWarning("Error al enviar email de factura a {ToEmail} para factura {InvoiceNumber}", 
                    toEmail, invoiceNumber);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al enviar email de factura a {ToEmail} para factura {InvoiceNumber}", 
                toEmail, invoiceNumber);
            throw;
        }
    }

    private string GetProfileUrl()
    {
        // URL relativa - el frontend manejará la URL base
        return "/profile.html";
    }
}

