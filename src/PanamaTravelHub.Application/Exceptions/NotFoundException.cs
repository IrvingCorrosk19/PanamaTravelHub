namespace PanamaTravelHub.Application.Exceptions;

/// <summary>
/// Excepción para recursos no encontrados
/// </summary>
public class NotFoundException : BusinessException
{
    public NotFoundException(string resourceName, object key) 
        : base($"El recurso '{resourceName}' con el identificador '{key}' no fue encontrado.", "RESOURCE_NOT_FOUND")
    {
    }

    public NotFoundException(string message) 
        : base(message, "RESOURCE_NOT_FOUND")
    {
    }
}



