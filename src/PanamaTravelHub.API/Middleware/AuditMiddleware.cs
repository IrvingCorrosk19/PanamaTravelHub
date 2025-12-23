using System.Diagnostics;
using System.Security.Claims;
using PanamaTravelHub.Application.Services;

namespace PanamaTravelHub.API.Middleware;

/// <summary>
/// Middleware para registrar automáticamente acciones de auditoría
/// </summary>
public class AuditMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<AuditMiddleware> _logger;
    private readonly IAuditService _auditService;

    // Acciones que deben ser auditadas
    private static readonly HashSet<string> AuditableActions = new()
    {
        "POST", "PUT", "PATCH", "DELETE"
    };

    // Endpoints que no deben ser auditados
    private static readonly HashSet<string> ExcludedPaths = new()
    {
        "/health",
        "/swagger",
        "/api/payments/webhook"
    };

    public AuditMiddleware(
        RequestDelegate next,
        ILogger<AuditMiddleware> logger,
        IAuditService auditService)
    {
        _next = next;
        _logger = logger;
        _auditService = auditService;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Solo auditar métodos que modifican datos
        if (!AuditableActions.Contains(context.Request.Method))
        {
            await _next(context);
            return;
        }

        // Excluir ciertos paths
        var path = context.Request.Path.Value?.ToLower() ?? "";
        if (ExcludedPaths.Any(excluded => path.Contains(excluded)))
        {
            await _next(context);
            return;
        }

        // Obtener información del usuario
        var userId = context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        Guid? userIdGuid = null;
        if (Guid.TryParse(userId, out var parsedUserId))
        {
            userIdGuid = parsedUserId;
        }

        // Obtener correlation ID (si existe)
        var correlationId = context.Request.Headers["X-Correlation-Id"].FirstOrDefault() 
                          ?? context.TraceIdentifier;

        // Obtener información de la solicitud
        var ipAddress = context.Connection.RemoteIpAddress?.ToString() 
                       ?? context.Request.Headers["X-Forwarded-For"].FirstOrDefault()
                       ?? "Unknown";
        var userAgent = context.Request.Headers["User-Agent"].FirstOrDefault() ?? "Unknown";

        // Leer el body de la solicitud (si es necesario)
        string? requestBody = null;
        if (context.Request.ContentLength > 0 && context.Request.ContentLength < 10240) // Solo si es menor a 10KB
        {
            context.Request.EnableBuffering();
            using var reader = new StreamReader(context.Request.Body, leaveOpen: true);
            requestBody = await reader.ReadToEndAsync();
            context.Request.Body.Position = 0;
        }

        // Ejecutar el siguiente middleware
        var stopwatch = Stopwatch.StartNew();
        await _next(context);
        stopwatch.Stop();

        // Registrar auditoría solo si la respuesta fue exitosa (2xx)
        if (context.Response.StatusCode >= 200 && context.Response.StatusCode < 300)
        {
            try
            {
                // Extraer información de la entidad desde la ruta
                var entityType = ExtractEntityType(context.Request.Path);
                var entityId = ExtractEntityId(context.Request.Path, requestBody);

                if (!string.IsNullOrEmpty(entityType))
                {
                    await _auditService.LogActionAsync(
                        entityType: entityType,
                        entityId: entityId,
                        action: context.Request.Method,
                        userId: userIdGuid,
                        beforeState: null, // Se puede mejorar para capturar el estado antes
                        afterState: requestBody != null ? new { RequestBody = requestBody } : null,
                        ipAddress: ipAddress,
                        userAgent: userAgent,
                        correlationId: correlationId
                    );
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al registrar auditoría para {Path}", context.Request.Path);
            }
        }
    }

    private static string ExtractEntityType(PathString path)
    {
        // Extraer el tipo de entidad desde la ruta
        // Ejemplo: /api/tours/123 -> "Tour"
        // Ejemplo: /api/admin/tours -> "Tour"
        var segments = path.Value?.Split('/', StringSplitOptions.RemoveEmptyEntries) ?? Array.Empty<string>();
        
        for (int i = 0; i < segments.Length; i++)
        {
            var segment = segments[i];
            if (segment.Equals("api", StringComparison.OrdinalIgnoreCase) && i + 1 < segments.Length)
            {
                var nextSegment = segments[i + 1];
                
                // Mapear rutas a tipos de entidad
                return nextSegment.ToLower() switch
                {
                    "tours" => "Tour",
                    "bookings" => "Booking",
                    "payments" => "Payment",
                    "users" => "User",
                    "admin" when i + 2 < segments.Length => segments[i + 2].ToLower() switch
                    {
                        "tours" => "Tour",
                        "bookings" => "Booking",
                        "users" => "User",
                        _ => "Unknown"
                    },
                    _ => "Unknown"
                };
            }
        }

        return "Unknown";
    }

    private static Guid ExtractEntityId(PathString path, string? requestBody)
    {
        // Intentar extraer el ID desde la ruta
        var segments = path.Value?.Split('/', StringSplitOptions.RemoveEmptyEntries) ?? Array.Empty<string>();
        
        for (int i = 0; i < segments.Length; i++)
        {
            if (Guid.TryParse(segments[i], out var id))
            {
                return id;
            }
        }

        // Si no se encuentra en la ruta, intentar desde el body (para POST)
        if (!string.IsNullOrEmpty(requestBody))
        {
            try
            {
                using var doc = System.Text.Json.JsonDocument.Parse(requestBody);
                if (doc.RootElement.TryGetProperty("id", out var idElement))
                {
                    if (Guid.TryParse(idElement.GetString(), out var id))
                    {
                        return id;
                    }
                }
            }
            catch
            {
                // Ignorar errores de parsing
            }
        }

        return Guid.Empty;
    }
}

