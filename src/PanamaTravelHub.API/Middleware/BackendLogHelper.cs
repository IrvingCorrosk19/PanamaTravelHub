using System.Collections.Generic;
using System.Text.Json;
using Microsoft.Extensions.Logging;

namespace PanamaTravelHub.API.Middleware;

/// <summary>
/// Helper para logs estructurados en el backend (similar al logger del frontend).
/// Formato: nivel, mensaje, timestamp y datos extra para correlacionar con el front.
/// </summary>
public static class BackendLogHelper
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = false,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    };

    /// <summary>Log estructurado tipo REQUEST IN (como en frontend logRequest).</summary>
    public static void LogRequest(ILogger logger, string method, string path, string? queryString, string correlationId, bool isAdmin, IReadOnlyDictionary<string, object>? extra = null)
    {
        var data = new Dictionary<string, object?>
        {
            ["method"] = method,
            ["path"] = path,
            ["queryString"] = queryString ?? "",
            ["correlationId"] = correlationId,
            ["isAdmin"] = isAdmin
        };
        if (extra != null)
            foreach (var kv in extra)
                data[kv.Key] = kv.Value;

        if (isAdmin)
            logger.LogDebug("=== REQUEST IN === [{Method}] {Path}{Query} | CorrelationId: {CorrelationId} | Data: {Data}",
                method, path, queryString ?? "", correlationId, JsonSerializer.Serialize(data, JsonOptions));
        else
            logger.LogInformation("=== REQUEST IN === [{Method}] {Path}{Query} | CorrelationId: {CorrelationId}",
                method, path, queryString ?? "", correlationId);
    }

    /// <summary>Log estructurado tipo RESPONSE OUT (como en frontend logResponse).</summary>
    public static void LogResponse(ILogger logger, string method, string path, int statusCode, long durationMs, string correlationId, bool isAdmin, string? errorMessage = null)
    {
        if (isAdmin || statusCode >= 400)
        {
            var errorSuffix = string.IsNullOrEmpty(errorMessage) ? "" : " | Error: " + errorMessage;
            logger.Log(
                statusCode >= 500 ? LogLevel.Error : statusCode >= 400 ? LogLevel.Warning : LogLevel.Debug,
                "=== RESPONSE OUT === [{Method}] {Path} | Status: {StatusCode} | Duration: {Duration}ms | CorrelationId: {CorrelationId}{ErrorSuffix}",
                method, path, statusCode, durationMs, correlationId, errorSuffix);
        }
        else
            logger.LogInformation("=== RESPONSE OUT === [{Method}] {Path} | Status: {StatusCode} | Duration: {Duration}ms | CorrelationId: {CorrelationId}",
                method, path, statusCode, durationMs, correlationId);
    }

    /// <summary>Log de error capturado (como en frontend formatError + logHttpError).</summary>
    public static void LogError(ILogger logger, System.Exception exception, string message, string correlationId, string endpoint, string? userId, bool isAdmin, IReadOnlyDictionary<string, object?>? extra = null)
    {
        var data = new Dictionary<string, object?>
        {
            ["timestamp"] = System.DateTime.UtcNow.ToString("o"),
            ["message"] = message,
            ["exceptionType"] = exception.GetType().Name,
            ["exceptionMessage"] = exception.Message,
            ["correlationId"] = correlationId,
            ["endpoint"] = endpoint,
            ["userId"] = userId ?? "(anon)",
            ["isAdminRequest"] = isAdmin,
            ["stackTrace"] = exception.StackTrace
        };
        if (exception.InnerException != null)
        {
            data["innerExceptionType"] = exception.InnerException.GetType().Name;
            data["innerExceptionMessage"] = exception.InnerException.Message;
        }
        if (extra != null)
            foreach (var kv in extra)
                data[kv.Key] = kv.Value;

        logger.LogError(exception,
            "=== ERROR CAPTURADO === {Message} | CorrelationId: {CorrelationId} | Endpoint: {Endpoint} | UserId: {UserId} | IsAdmin: {IsAdmin} | Data: {Data}",
            message, correlationId, endpoint, userId ?? "(anon)", isAdmin, JsonSerializer.Serialize(data, JsonOptions));
    }
}
