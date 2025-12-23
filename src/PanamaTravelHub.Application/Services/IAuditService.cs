namespace PanamaTravelHub.Application.Services;

/// <summary>
/// Servicio para registrar acciones de auditoría
/// </summary>
public interface IAuditService
{
    /// <summary>
    /// Registra una acción de auditoría
    /// </summary>
    Task LogActionAsync(
        string entityType,
        Guid entityId,
        string action,
        Guid? userId = null,
        object? beforeState = null,
        object? afterState = null,
        string? ipAddress = null,
        string? userAgent = null,
        string? correlationId = null);
}

