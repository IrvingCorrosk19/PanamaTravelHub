using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Domain.Enums;
using PanamaTravelHub.Infrastructure.Data;

namespace PanamaTravelHub.Infrastructure.Services;

/// <summary>
/// BackgroundService para procesar la cola de emails
/// </summary>
public class EmailQueueService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<EmailQueueService> _logger;
    private readonly int _maxRetries;
    private readonly TimeSpan _processingInterval;
    private readonly TimeSpan _retryDelayBase;

    public EmailQueueService(
        IServiceProvider serviceProvider,
        ILogger<EmailQueueService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
        _maxRetries = 3; // Máximo 3 reintentos
        _processingInterval = TimeSpan.FromSeconds(30); // Procesar cada 30 segundos
        _retryDelayBase = TimeSpan.FromMinutes(5); // Delay base de 5 minutos
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("EmailQueueService iniciado");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessEmailQueueAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en EmailQueueService");
            }

            await Task.Delay(_processingInterval, stoppingToken);
        }

        _logger.LogInformation("EmailQueueService detenido");
    }

    private async Task ProcessEmailQueueAsync(CancellationToken cancellationToken)
    {
        using var scope = _serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var emailService = scope.ServiceProvider.GetRequiredService<IEmailService>();

        // Obtener emails pendientes o en retry que estén listos para enviar
        var now = DateTime.UtcNow;
        var pendingEmails = await context.EmailNotifications
            .Where(e => e.Status == EmailNotificationStatus.Pending || 
                       e.Status == EmailNotificationStatus.Retrying)
            .Where(e => e.ScheduledFor == null || e.ScheduledFor <= now)
            .Where(e => e.RetryCount < _maxRetries)
            .OrderBy(e => e.CreatedAt)
            .Take(10) // Procesar máximo 10 emails por ciclo
            .ToListAsync(cancellationToken);

        if (!pendingEmails.Any())
        {
            return;
        }

        _logger.LogInformation("Procesando {Count} emails pendientes", pendingEmails.Count);

        foreach (var emailNotification in pendingEmails)
        {
            try
            {
                // Actualizar estado a Retrying si es necesario
                if (emailNotification.Status == EmailNotificationStatus.Pending)
                {
                    emailNotification.Status = EmailNotificationStatus.Retrying;
                    emailNotification.UpdatedAt = DateTime.UtcNow;
                    await context.SaveChangesAsync(cancellationToken);
                }

                // Intentar enviar el email
                var success = await emailService.SendEmailAsync(
                    emailNotification.ToEmail,
                    emailNotification.Subject,
                    emailNotification.Body,
                    isHtml: true);

                if (success)
                {
                    // Email enviado exitosamente
                    emailNotification.Status = EmailNotificationStatus.Sent;
                    emailNotification.SentAt = DateTime.UtcNow;
                    emailNotification.ErrorMessage = null;
                    emailNotification.UpdatedAt = DateTime.UtcNow;
                    
                    _logger.LogInformation("Email {EmailId} enviado exitosamente a {ToEmail}", 
                        emailNotification.Id, emailNotification.ToEmail);
                }
                else
                {
                    // Fallo en el envío
                    emailNotification.RetryCount++;
                    emailNotification.ErrorMessage = "Error al enviar email";
                    emailNotification.UpdatedAt = DateTime.UtcNow;

                    if (emailNotification.RetryCount >= _maxRetries)
                    {
                        // Máximo de reintentos alcanzado
                        emailNotification.Status = EmailNotificationStatus.Failed;
                        _logger.LogWarning("Email {EmailId} falló después de {RetryCount} intentos", 
                            emailNotification.Id, emailNotification.RetryCount);
                    }
                    else
                    {
                        // Programar siguiente reintento con backoff exponencial
                        var delay = TimeSpan.FromMinutes(_retryDelayBase.TotalMinutes * Math.Pow(2, emailNotification.RetryCount - 1));
                        emailNotification.ScheduledFor = DateTime.UtcNow.Add(delay);
                        emailNotification.Status = EmailNotificationStatus.Retrying;
                        
                        _logger.LogInformation("Email {EmailId} programado para reintento en {Delay} minutos (intento {RetryCount}/{MaxRetries})", 
                            emailNotification.Id, delay.TotalMinutes, emailNotification.RetryCount, _maxRetries);
                    }
                }

                await context.SaveChangesAsync(cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al procesar email {EmailId}", emailNotification.Id);
                
                emailNotification.RetryCount++;
                emailNotification.ErrorMessage = ex.Message;
                emailNotification.UpdatedAt = DateTime.UtcNow;

                if (emailNotification.RetryCount >= _maxRetries)
                {
                    emailNotification.Status = EmailNotificationStatus.Failed;
                }
                else
                {
                    var delay = TimeSpan.FromMinutes(_retryDelayBase.TotalMinutes * Math.Pow(2, emailNotification.RetryCount - 1));
                    emailNotification.ScheduledFor = DateTime.UtcNow.Add(delay);
                }

                await context.SaveChangesAsync(cancellationToken);
            }
        }
    }
}

