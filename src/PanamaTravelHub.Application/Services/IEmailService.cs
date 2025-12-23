namespace PanamaTravelHub.Application.Services;

/// <summary>
/// Interfaz para el servicio de envío de emails
/// </summary>
public interface IEmailService
{
    /// <summary>
    /// Envía un email
    /// </summary>
    /// <param name="toEmail">Email del destinatario</param>
    /// <param name="subject">Asunto del email</param>
    /// <param name="body">Cuerpo del email (HTML)</param>
    /// <param name="isHtml">Indica si el cuerpo es HTML</param>
    /// <returns>True si el envío fue exitoso</returns>
    Task<bool> SendEmailAsync(string toEmail, string subject, string body, bool isHtml = true);

    /// <summary>
    /// Envía un email con plantilla
    /// </summary>
    /// <param name="toEmail">Email del destinatario</param>
    /// <param name="subject">Asunto del email</param>
    /// <param name="templateName">Nombre de la plantilla</param>
    /// <param name="templateData">Datos para rellenar la plantilla</param>
    /// <returns>True si el envío fue exitoso</returns>
    Task<bool> SendTemplatedEmailAsync(string toEmail, string subject, string templateName, object templateData);
}

