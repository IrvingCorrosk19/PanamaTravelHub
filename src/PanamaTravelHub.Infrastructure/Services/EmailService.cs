using System.Net;
using System.Net.Mail;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Infrastructure.Data;

namespace PanamaTravelHub.Infrastructure.Services;

/// <summary>
/// Implementación del servicio de email usando SMTP.
/// Lee la configuración desde la tabla email_settings (admin) o appsettings como fallback.
/// </summary>
public class EmailService : IEmailService
{
    private readonly ILogger<EmailService> _logger;
    private readonly IConfiguration _configuration;
    private readonly IEmailTemplateService _templateService;
    private readonly ApplicationDbContext _context;

    public EmailService(
        ILogger<EmailService> logger,
        IConfiguration configuration,
        IEmailTemplateService templateService,
        ApplicationDbContext context)
    {
        _logger = logger;
        _configuration = configuration;
        _templateService = templateService;
        _context = context;
    }

    private static bool IsSmtpConfigured(string? host, string? username, string? password)
    {
        if (string.IsNullOrWhiteSpace(host)) return false;
        if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password)) return false;
        var u = username.Trim();
        var p = password.Trim();
        if (u.Equals("YOUR_EMAIL@gmail.com", StringComparison.OrdinalIgnoreCase)) return false;
        if (p.Equals("YOUR_APP_PASSWORD", StringComparison.OrdinalIgnoreCase)) return false;
        return true;
    }

    private async Task<(string Host, int Port, string? Username, string? Password, string FromAddress, string FromName, bool EnableSsl)> GetEmailConfigAsync()
    {
        try
        {
            var db = await _context.EmailSettings.OrderBy(e => e.CreatedAt).FirstOrDefaultAsync();
            if (db != null && IsSmtpConfigured(db.SmtpHost, db.SmtpUsername, db.SmtpPassword))
            {
                return (db.SmtpHost, db.SmtpPort, db.SmtpUsername, db.SmtpPassword,
                    db.FromAddress, db.FromName, db.EnableSsl);
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "No se pudo leer email_settings de BD, usando appsettings");
        }

        var host = _configuration["Email:Smtp:Host"];
        var port = int.TryParse(_configuration["Email:Smtp:Port"], out var p) ? p : 587;
        var username = _configuration["Email:Smtp:Username"];
        var password = _configuration["Email:Smtp:Password"];
        var fromAddress = _configuration["Email:From:Address"] ?? "noreply@panamatravelhub.com";
        var fromName = _configuration["Email:From:Name"] ?? "Panama Travel Hub";
        var enableSsl = bool.TryParse(_configuration["Email:Smtp:EnableSsl"], out var ssl) ? ssl : true;
        return (host ?? "", port, username, password, fromAddress, fromName, enableSsl);
    }

    public async Task<bool> SendEmailAsync(string toEmail, string subject, string body, bool isHtml = true)
    {
        try
        {
            var (smtpHost, smtpPort, smtpUsername, smtpPassword, fromEmail, fromName, enableSsl) = await GetEmailConfigAsync();

            if (!IsSmtpConfigured(smtpHost, smtpUsername, smtpPassword))
            {
                _logger.LogWarning("SMTP no configurado (Host vacio o credenciales faltantes/placeholders). Email no enviado a {ToEmail}. Configure en Admin > Configuración de Email.", toEmail);
                return false;
            }

            using var client = new SmtpClient(smtpHost!, smtpPort)
            {
                EnableSsl = enableSsl,
                Credentials = new NetworkCredential(smtpUsername!.Trim(), smtpPassword!.Trim()),
                Timeout = 30000 // 30 segundos
            };

            using var message = new MailMessage
            {
                From = new MailAddress(fromEmail, fromName),
                Subject = subject,
                Body = body,
                IsBodyHtml = isHtml
            };

            message.To.Add(toEmail);
            await client.SendMailAsync(message);
            
            _logger.LogInformation("Email enviado exitosamente a {ToEmail} con asunto: {Subject}", toEmail, subject);
            return true;
        }
        catch (SmtpException ex)
        {
            _logger.LogError(ex, "Error SMTP al enviar email a {ToEmail}: {Message}", toEmail, ex.Message);
            return false;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error inesperado al enviar email a {ToEmail}: {Message}", toEmail, ex.Message);
            return false;
        }
    }

    public async Task<bool> SendTemplatedEmailAsync(string toEmail, string subject, string templateName, object templateData)
    {
        try
        {
            var body = await _templateService.RenderTemplateAsync(templateName, templateData);
            return await SendEmailAsync(toEmail, subject, body, isHtml: true);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al enviar email con plantilla {TemplateName} a {ToEmail}", templateName, toEmail);
            return false;
        }
    }

    public async Task<bool> SendEmailWithAttachmentAsync(
        string toEmail, 
        string subject, 
        string body, 
        byte[] attachmentBytes, 
        string attachmentFileName, 
        string attachmentContentType = "application/pdf")
    {
        try
        {
            var (smtpHost, smtpPort, smtpUsername, smtpPassword, fromEmail, fromName, enableSsl) = await GetEmailConfigAsync();

            if (!IsSmtpConfigured(smtpHost, smtpUsername, smtpPassword))
            {
                _logger.LogWarning("SMTP no configurado (Host vacio o credenciales faltantes/placeholders). Email no enviado a {ToEmail}. Configure en Admin > Configuración de Email.", toEmail);
                return false;
            }

            using var client = new SmtpClient(smtpHost!, smtpPort)
            {
                EnableSsl = enableSsl,
                Credentials = new NetworkCredential(smtpUsername!.Trim(), smtpPassword!.Trim()),
                Timeout = 30000
            };

            using var message = new MailMessage
            {
                From = new MailAddress(fromEmail, fromName),
                Subject = subject,
                Body = body,
                IsBodyHtml = true
            };

            message.To.Add(toEmail);

            // Agregar adjunto
            using var stream = new MemoryStream(attachmentBytes);
            var attachment = new Attachment(stream, attachmentFileName, attachmentContentType);
            message.Attachments.Add(attachment);

            await client.SendMailAsync(message);
            
            _logger.LogInformation("Email con adjunto enviado exitosamente a {ToEmail} con asunto: {Subject}", toEmail, subject);
            return true;
        }
        catch (SmtpException ex)
        {
            _logger.LogError(ex, "Error SMTP al enviar email con adjunto a {ToEmail}: {Message}", toEmail, ex.Message);
            return false;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error inesperado al enviar email con adjunto a {ToEmail}: {Message}", toEmail, ex.Message);
            return false;
        }
    }
}

