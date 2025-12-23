namespace PanamaTravelHub.Application.Services;

/// <summary>
/// Interfaz para el servicio de plantillas de email
/// </summary>
public interface IEmailTemplateService
{
    /// <summary>
    /// Renderiza una plantilla de email con los datos proporcionados
    /// </summary>
    /// <param name="templateName">Nombre de la plantilla</param>
    /// <param name="data">Datos para rellenar la plantilla</param>
    /// <returns>HTML renderizado</returns>
    Task<string> RenderTemplateAsync(string templateName, object data);
}

