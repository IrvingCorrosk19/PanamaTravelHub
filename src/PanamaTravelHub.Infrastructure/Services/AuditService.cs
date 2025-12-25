using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Infrastructure.Data;

namespace PanamaTravelHub.Infrastructure.Services;

/// <summary>
/// Servicio para registrar acciones de auditoría
/// </summary>
public class AuditService : IAuditService
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<AuditService> _logger;

    public AuditService(
        ApplicationDbContext context,
        ILogger<AuditService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task LogActionAsync(
        string entityType,
        Guid entityId,
        string action,
        Guid? userId = null,
        object? beforeState = null,
        object? afterState = null,
        string? ipAddress = null,
        string? userAgent = null,
        Guid? correlationId = null)
    {
        try
        {
            var auditLog = new AuditLog
            {
                UserId = userId,
                EntityType = entityType,
                EntityId = entityId,
                Action = action,
                IpAddress = ipAddress,
                UserAgent = userAgent,
                CorrelationId = correlationId
            };

            // Serializar estados a JSON
            if (beforeState != null)
            {
                auditLog.BeforeState = JsonSerializer.Serialize(beforeState, new JsonSerializerOptions
                {
                    WriteIndented = false,
                    DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull
                });
            }

            if (afterState != null)
            {
                auditLog.AfterState = JsonSerializer.Serialize(afterState, new JsonSerializerOptions
                {
                    WriteIndented = false,
                    DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull
                });
            }

            _context.AuditLogs.Add(auditLog);
            await _context.SaveChangesAsync();
        }
        catch (Exception ex)
        {
            // No fallar la operación principal si falla la auditoría
            _logger.LogError(ex, "Error al registrar auditoría: {EntityType} {EntityId} {Action}", 
                entityType, entityId, action);
        }
    }
}

