using System.Net;
using System.Net.Mail;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using PanamaTravelHub.Application.Services;

namespace PanamaTravelHub.Infrastructure.Services;

/// <summary>
/// Implementación del servicio de email usando SMTP
/// </summary>
public class EmailService : IEmailService
{
    private readonly ILogger<EmailService> _logger;
    private readonly IConfiguration _configuration;
    private readonly IEmailTemplateService _templateService;

    public EmailService(
        ILogger<EmailService> logger,
        IConfiguration configuration,
        IEmailTemplateService templateService)
    {
        _logger = logger;
        _configuration = configuration;
        _templateService = templateService;
    }

    public async Task<bool> SendEmailAsync(string toEmail, string subject, string body, bool isHtml = true)
    {
        try
        {
            var smtpHost = _configuration["Email:Smtp:Host"];
            var smtpPort = int.TryParse(_configuration["Email:Smtp:Port"], out var port) ? port : 587;
            var smtpUsername = _configuration["Email:Smtp:Username"];
            var smtpPassword = _configuration["Email:Smtp:Password"];
            var fromEmail = _configuration["Email:From:Address"] ?? "noreply@panamatravelhub.com";
            var fromName = _configuration["Email:From:Name"] ?? "Panama Travel Hub";
            var enableSsl = bool.TryParse(_configuration["Email:Smtp:EnableSsl"], out var ssl) ? ssl : true;

            if (string.IsNullOrEmpty(smtpHost))
            {
                _logger.LogWarning("SMTP no configurado. Email no enviado a {ToEmail}", toEmail);
                return false;
            }

            using var client = new SmtpClient(smtpHost, smtpPort)
            {
                EnableSsl = enableSsl,
                Credentials = !string.IsNullOrEmpty(smtpUsername) && !string.IsNullOrEmpty(smtpPassword)
                    ? new NetworkCredential(smtpUsername, smtpPassword)
                    : null,
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
            var smtpHost = _configuration["Email:Smtp:Host"];
            var smtpPort = int.TryParse(_configuration["Email:Smtp:Port"], out var port) ? port : 587;
            var smtpUsername = _configuration["Email:Smtp:Username"];
            var smtpPassword = _configuration["Email:Smtp:Password"];
            var fromEmail = _configuration["Email:From:Address"] ?? "noreply@panamatravelhub.com";
            var fromName = _configuration["Email:From:Name"] ?? "Panama Travel Hub";
            var enableSsl = bool.TryParse(_configuration["Email:Smtp:EnableSsl"], out var ssl) ? ssl : true;

            if (string.IsNullOrEmpty(smtpHost))
            {
                _logger.LogWarning("SMTP no configurado. Email no enviado a {ToEmail}", toEmail);
                return false;
            }

            using var client = new SmtpClient(smtpHost, smtpPort)
            {
                EnableSsl = enableSsl,
                Credentials = !string.IsNullOrEmpty(smtpUsername) && !string.IsNullOrEmpty(smtpPassword)
                    ? new NetworkCredential(smtpUsername, smtpPassword)
                    : null,
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

