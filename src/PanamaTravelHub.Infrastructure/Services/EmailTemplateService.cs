using System.Text;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using PanamaTravelHub.Application.Services;

namespace PanamaTravelHub.Infrastructure.Services;

/// <summary>
/// Servicio para renderizar plantillas de email
/// </summary>
public class EmailTemplateService : IEmailTemplateService
{
    private readonly ILogger<EmailTemplateService> _logger;
    private readonly string _templatesPath;

    public EmailTemplateService(ILogger<EmailTemplateService> logger, IHostEnvironment? environment = null)
    {
        _logger = logger;
        // En desarrollo, buscar en wwwroot/templates/email
        // En producción, usar el mismo path
        _templatesPath = Path.Combine(
            environment?.ContentRootPath ?? AppContext.BaseDirectory,
            "wwwroot", "templates", "email");
    }

    public async Task<string> RenderTemplateAsync(string templateName, object data)
    {
        try
        {
            var templatePath = Path.Combine(_templatesPath, $"{templateName}.html");
            
            if (!File.Exists(templatePath))
            {
                _logger.LogWarning("Plantilla no encontrada: {TemplatePath}", templatePath);
                return GetDefaultTemplate(templateName, data);
            }

            var template = await File.ReadAllTextAsync(templatePath, Encoding.UTF8);
            
            // Reemplazo simple de placeholders {{PropertyName}}
            var rendered = template;
            var properties = data.GetType().GetProperties();
            
            foreach (var prop in properties)
            {
                var value = prop.GetValue(data)?.ToString() ?? string.Empty;
                rendered = rendered.Replace($"{{{{{prop.Name}}}}}", value);
            }

            return rendered;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al renderizar plantilla {TemplateName}", templateName);
            return GetDefaultTemplate(templateName, data);
        }
    }

    private string GetDefaultTemplate(string templateName, object data)
    {
        // Template HTML básico como fallback
        return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset=""utf-8"">
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background-color: #2563eb; color: white; padding: 20px; text-align: center; }}
        .content {{ padding: 20px; background-color: #f9fafb; }}
        .footer {{ text-align: center; padding: 20px; color: #6b7280; font-size: 12px; }}
    </style>
</head>
<body>
    <div class=""container"">
        <div class=""header"">
            <h1>Panama Travel Hub</h1>
        </div>
        <div class=""content"">
            <p>Plantilla {templateName} no disponible. Contenido del email:</p>
            <pre>{System.Text.Json.JsonSerializer.Serialize(data, new System.Text.Json.JsonSerializerOptions { WriteIndented = true })}</pre>
        </div>
        <div class=""footer"">
            <p>&copy; {DateTime.UtcNow.Year} Panama Travel Hub. Todos los derechos reservados.</p>
        </div>
    </div>
</body>
</html>";
    }
}

