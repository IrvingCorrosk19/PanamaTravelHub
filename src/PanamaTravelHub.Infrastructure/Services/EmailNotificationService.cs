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
    private readonly ILogger<EmailNotificationService> _logger;

    public EmailNotificationService(
        ApplicationDbContext context,
        IEmailTemplateService templateService,
        ILogger<EmailNotificationService> logger)
    {
        _context = context;
        _templateService = templateService;
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
}

