using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Domain.Enums;
using PanamaTravelHub.Infrastructure.Data;
using System.Text.Json;

namespace PanamaTravelHub.Infrastructure.Services;

/// <summary>
/// Servicio para enviar notificaciones SMS usando Twilio
/// </summary>
public class SmsNotificationService : ISmsNotificationService
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<SmsNotificationService> _logger;
    private readonly IConfiguration _configuration;
    private readonly string? _twilioAccountSid;
    private readonly string? _twilioAuthToken;
    private readonly string? _twilioFromNumber;
    private readonly bool _twilioEnabled;

    public SmsNotificationService(
        ApplicationDbContext context,
        ILogger<SmsNotificationService> logger,
        IConfiguration configuration)
    {
        _context = context;
        _logger = logger;
        _configuration = configuration;

        // Obtener configuración de Twilio
        _twilioAccountSid = _configuration["Twilio:AccountSid"];
        _twilioAuthToken = _configuration["Twilio:AuthToken"];
        _twilioFromNumber = _configuration["Twilio:FromNumber"];
        var enabledStr = _configuration["Twilio:Enabled"];
        _twilioEnabled = !string.IsNullOrWhiteSpace(enabledStr) && bool.TryParse(enabledStr, out var enabled) && enabled;

        // Validar configuración
        if (_twilioEnabled)
        {
            if (string.IsNullOrWhiteSpace(_twilioAccountSid) || 
                string.IsNullOrWhiteSpace(_twilioAuthToken) || 
                string.IsNullOrWhiteSpace(_twilioFromNumber))
            {
                _logger.LogWarning("Twilio está habilitado pero falta configuración. SMS no funcionará.");
                _twilioEnabled = false;
            }
        }
    }

    public async Task<bool> SendSmsAsync(
        string phoneNumber,
        string message,
        SmsNotificationType type,
        Guid? userId = null,
        Guid? bookingId = null,
        CancellationToken cancellationToken = default)
    {
        try
        {
            // Normalizar número de teléfono a formato E.164
            var normalizedPhone = NormalizePhoneNumber(phoneNumber);
            if (string.IsNullOrWhiteSpace(normalizedPhone))
            {
                _logger.LogWarning("Número de teléfono inválido: {PhoneNumber}", phoneNumber);
                return false;
            }

            // Crear registro de notificación
            var notification = new SmsNotification
            {
                ToPhoneNumber = normalizedPhone,
                Message = message,
                Type = type,
                Status = SmsNotificationStatus.Pending,
                UserId = userId,
                BookingId = bookingId
            };

            _context.SmsNotifications.Add(notification);
            await _context.SaveChangesAsync(cancellationToken);

            // Si Twilio no está habilitado, solo guardamos el registro
            if (!_twilioEnabled)
            {
                _logger.LogInformation("Twilio deshabilitado. SMS guardado pero no enviado: {SmsId}", notification.Id);
                notification.Status = SmsNotificationStatus.Failed;
                notification.ErrorMessage = "Twilio no está configurado o habilitado";
                await _context.SaveChangesAsync(cancellationToken);
                return false;
            }

            // Enviar SMS usando Twilio
            var success = await SendSmsWithTwilioAsync(normalizedPhone, message, notification, cancellationToken);

            return success;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al enviar SMS: {PhoneNumber}, Tipo: {Type}", phoneNumber, type);
            return false;
        }
    }

    public async Task<SmsNotification> QueueSmsAsync(
        string phoneNumber,
        string message,
        SmsNotificationType type,
        DateTime scheduledFor,
        Guid? userId = null,
        Guid? bookingId = null,
        CancellationToken cancellationToken = default)
    {
        var normalizedPhone = NormalizePhoneNumber(phoneNumber);
        if (string.IsNullOrWhiteSpace(normalizedPhone))
        {
            throw new ArgumentException("Número de teléfono inválido", nameof(phoneNumber));
        }

        var notification = new SmsNotification
        {
            ToPhoneNumber = normalizedPhone,
            Message = message,
            Type = type,
            Status = SmsNotificationStatus.Pending,
            UserId = userId,
            BookingId = bookingId,
            ScheduledFor = scheduledFor
        };

        _context.SmsNotifications.Add(notification);
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("SMS agendado: {SmsId}, Tipo: {Type}, Para: {PhoneNumber}, Fecha: {ScheduledFor}",
            notification.Id, type, normalizedPhone, scheduledFor);

        return notification;
    }

    public async Task<bool> SendTemplatedSmsAsync(
        string phoneNumber,
        string templateName,
        object templateData,
        SmsNotificationType type,
        Guid? userId = null,
        Guid? bookingId = null,
        CancellationToken cancellationToken = default)
    {
        try
        {
            var message = RenderSmsTemplate(templateName, templateData);
            return await SendSmsAsync(phoneNumber, message, type, userId, bookingId, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al enviar SMS con plantilla {TemplateName}", templateName);
            return false;
        }
    }

    public async Task ProcessPendingSmsAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            var now = DateTime.UtcNow;
            var pendingSms = await _context.SmsNotifications
                .Where(sn => sn.Status == SmsNotificationStatus.Pending &&
                            (sn.ScheduledFor == null || sn.ScheduledFor <= now))
                .OrderBy(sn => sn.CreatedAt)
                .Take(50) // Procesar 50 a la vez para no sobrecargar
                .ToListAsync(cancellationToken);

            foreach (var sms in pendingSms)
            {
                try
                {
                    if (_twilioEnabled)
                    {
                        await SendSmsWithTwilioAsync(sms.ToPhoneNumber, sms.Message, sms, cancellationToken);
                    }
                    else
                    {
                        sms.Status = SmsNotificationStatus.Failed;
                        sms.ErrorMessage = "Twilio no está configurado o habilitado";
                        await _context.SaveChangesAsync(cancellationToken);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error al procesar SMS {SmsId}", sms.Id);
                    sms.Status = SmsNotificationStatus.Failed;
                    sms.ErrorMessage = ex.Message;
                    await _context.SaveChangesAsync(cancellationToken);
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al procesar SMS pendientes");
        }
    }

    public async Task RetryFailedSmsAsync(int maxRetries = 3, CancellationToken cancellationToken = default)
    {
        try
        {
            var failedSms = await _context.SmsNotifications
                .Where(sn => sn.Status == SmsNotificationStatus.Failed &&
                            sn.RetryCount < maxRetries)
                .OrderBy(sn => sn.CreatedAt)
                .Take(50)
                .ToListAsync(cancellationToken);

            foreach (var sms in failedSms)
            {
                try
                {
                    sms.Status = SmsNotificationStatus.Retrying;
                    sms.RetryCount++;
                    await _context.SaveChangesAsync(cancellationToken);

                    if (_twilioEnabled)
                    {
                        await SendSmsWithTwilioAsync(sms.ToPhoneNumber, sms.Message, sms, cancellationToken);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error al reintentar SMS {SmsId}", sms.Id);
                    sms.Status = SmsNotificationStatus.Failed;
                    sms.ErrorMessage = ex.Message;
                    await _context.SaveChangesAsync(cancellationToken);
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al reintentar SMS fallidos");
        }
    }

    private async Task<bool> SendSmsWithTwilioAsync(
        string phoneNumber,
        string message,
        SmsNotification smsNotification,
        CancellationToken cancellationToken)
    {
        try
        {
            // Modo simulado para desarrollo (cuando Twilio no está configurado)
            var useSimulatorStr = _configuration["Twilio:UseSimulator"];
            var useSimulator = string.IsNullOrWhiteSpace(useSimulatorStr) || (bool.TryParse(useSimulatorStr, out var sim) && sim);
            
            if (useSimulator || !_twilioEnabled)
            {
                _logger.LogInformation("📱 [SIMULADOR] SMS enviado a {PhoneNumber}: {Message}", phoneNumber, message);
                
                smsNotification.Status = SmsNotificationStatus.Sent;
                smsNotification.SentAt = DateTime.UtcNow;
                smsNotification.ProviderMessageId = $"SIM-{Guid.NewGuid()}";
                smsNotification.ProviderResponse = JsonSerializer.Serialize(new { 
                    simulated = true,
                    timestamp = DateTime.UtcNow
                });
                await _context.SaveChangesAsync(cancellationToken);
                
                return true;
            }

            // TODO: Integración real con Twilio
            // Para usar Twilio real, instala el paquete: dotnet add package Twilio
            // Luego descomenta y configura:
            /*
            TwilioClient.Init(_twilioAccountSid, _twilioAuthToken);
            
            var messageResource = MessageResource.Create(
                body: message,
                from: new PhoneNumber(_twilioFromNumber),
                to: new PhoneNumber(phoneNumber)
            );

            smsNotification.Status = SmsNotificationStatus.Sent;
            smsNotification.SentAt = DateTime.UtcNow;
            smsNotification.ProviderMessageId = messageResource.Sid;
            smsNotification.ProviderResponse = JsonSerializer.Serialize(messageResource);
            await _context.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("✅ SMS enviado exitosamente con Twilio: {SmsId}, ProviderId: {ProviderId}, Para: {PhoneNumber}",
                smsNotification.Id, messageResource.Sid, phoneNumber);
            
            return true;
            */

            // Por ahora, si está habilitado pero no implementado, marcar como fallido
            smsNotification.Status = SmsNotificationStatus.Failed;
            smsNotification.ErrorMessage = "Twilio está habilitado pero la integración real no está implementada. Usa modo simulador.";
            await _context.SaveChangesAsync(cancellationToken);
            return false;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al enviar SMS: {PhoneNumber}", phoneNumber);
            
            smsNotification.Status = SmsNotificationStatus.Failed;
            smsNotification.ErrorMessage = ex.Message;
            smsNotification.RetryCount++;
            await _context.SaveChangesAsync(cancellationToken);

            return false;
        }
    }

    private string? NormalizePhoneNumber(string phoneNumber)
    {
        if (string.IsNullOrWhiteSpace(phoneNumber))
            return null;

        // Remover espacios, guiones, paréntesis
        var cleaned = phoneNumber.Replace(" ", "")
                                 .Replace("-", "")
                                 .Replace("(", "")
                                 .Replace(")", "")
                                 .Trim();

        // Si no empieza con +, intentar agregar código de país por defecto
        if (!cleaned.StartsWith("+"))
        {
            // Asumir Panamá (+507) si no tiene código de país
            cleaned = "+507" + cleaned;
        }

        // Validar formato E.164 básico
        if (cleaned.Length < 10 || !cleaned.StartsWith("+"))
        {
            return null;
        }

        return cleaned;
    }

    private string RenderSmsTemplate(string templateName, object templateData)
    {
        // Plantillas simples de SMS
        return templateName switch
        {
            "booking-confirmation" => RenderBookingConfirmationSms(templateData),
            "booking-reminder" => RenderBookingReminderSms(templateData),
            "payment-confirmation" => RenderPaymentConfirmationSms(templateData),
            "booking-cancellation" => RenderBookingCancellationSms(templateData),
            _ => throw new ArgumentException($"Plantilla desconocida: {templateName}", nameof(templateName))
        };
    }

    private string RenderBookingConfirmationSms(object data)
    {
        // Usar reflexión para obtener propiedades
        var bookingId = GetPropertyValue(data, "BookingId")?.ToString() ?? "N/A";
        var tourName = GetPropertyValue(data, "TourName")?.ToString() ?? "tu tour";
        var tourDate = GetPropertyValue(data, "TourDate");
        var dateStr = tourDate is DateTime dt ? dt.ToString("dd/MM/yyyy HH:mm") : "por confirmar";

        return $"✅ Reserva confirmada! Tour: {tourName}, Fecha: {dateStr}. ID: {bookingId}. Gracias por confiar en nosotros!";
    }

    private string RenderBookingReminderSms(object data)
    {
        var tourName = GetPropertyValue(data, "TourName")?.ToString() ?? "tu tour";
        var tourDate = GetPropertyValue(data, "TourDate");
        var dateStr = tourDate is DateTime dt ? dt.ToString("dd/MM/yyyy HH:mm") : "próximamente";

        return $"⏰ Recordatorio: Tu tour '{tourName}' es el {dateStr}. ¡Nos vemos pronto!";
    }

    private string RenderPaymentConfirmationSms(object data)
    {
        var amount = GetPropertyValue(data, "Amount");
        var amountStr = amount is decimal d ? $"${d:F2}" : "el monto";

        return $"💳 Pago confirmado: {amountStr}. Tu reserva está confirmada. Gracias!";
    }

    private string RenderBookingCancellationSms(object data)
    {
        var tourName = GetPropertyValue(data, "TourName")?.ToString() ?? "tu tour";

        return $"❌ Reserva cancelada: {tourName}. Si tienes preguntas, contáctanos.";
    }

    private object? GetPropertyValue(object obj, string propertyName)
    {
        return obj?.GetType().GetProperty(propertyName)?.GetValue(obj);
    }
}

