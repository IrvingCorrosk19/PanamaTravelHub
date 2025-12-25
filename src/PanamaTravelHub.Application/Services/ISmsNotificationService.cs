using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Domain.Enums;

namespace PanamaTravelHub.Application.Services;

public interface ISmsNotificationService
{
    /// <summary>
    /// Envía un SMS inmediatamente
    /// </summary>
    Task<bool> SendSmsAsync(
        string phoneNumber,
        string message,
        SmsNotificationType type,
        Guid? userId = null,
        Guid? bookingId = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Agenda un SMS para ser enviado en el futuro
    /// </summary>
    Task<SmsNotification> QueueSmsAsync(
        string phoneNumber,
        string message,
        SmsNotificationType type,
        DateTime scheduledFor,
        Guid? userId = null,
        Guid? bookingId = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Envía un SMS usando una plantilla predefinida
    /// </summary>
    Task<bool> SendTemplatedSmsAsync(
        string phoneNumber,
        string templateName,
        object templateData,
        SmsNotificationType type,
        Guid? userId = null,
        Guid? bookingId = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Procesa SMS pendientes en la cola
    /// </summary>
    Task ProcessPendingSmsAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// Reintenta enviar SMS fallidos
    /// </summary>
    Task RetryFailedSmsAsync(int maxRetries = 3, CancellationToken cancellationToken = default);
}

