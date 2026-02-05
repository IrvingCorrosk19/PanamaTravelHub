using System.Diagnostics;

namespace PanamaTravelHub.API.Middleware;

/// <summary>
/// Middleware para registrar todas las requests HTTP.
/// Logs estructurados similares al frontend (logger.js): REQUEST IN / RESPONSE OUT.
/// Rutas /admin y api/admin tienen log más detallado para depurar problemas en admin.html.
/// </summary>
public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    private static readonly HashSet<string> ExcludedPaths = new(StringComparer.OrdinalIgnoreCase)
    {
        "/health",
        "/health/live",
        "/health/ready",
        "/swagger",
        "/favicon.ico"
    };

    private static bool IsAdminPath(string path)
    {
        if (string.IsNullOrEmpty(path)) return false;
        var p = path.TrimStart('/').ToLowerInvariant();
        return p.StartsWith("admin", StringComparison.Ordinal) || p.StartsWith("api/admin", StringComparison.Ordinal);
    }

    public RequestLoggingMiddleware(
        RequestDelegate next,
        ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var path = context.Request.Path.Value ?? "";
        var shouldLog = !ExcludedPaths.Any(excluded => path.Contains(excluded, StringComparison.OrdinalIgnoreCase));
        var isAdmin = IsAdminPath(path);

        var correlationId = context.Request.Headers["X-Correlation-Id"].FirstOrDefault()
                          ?? context.TraceIdentifier;

        var method = context.Request.Method;
        var queryString = context.Request.QueryString.HasValue ? context.Request.QueryString.Value : "";

        if (shouldLog)
        {
            BackendLogHelper.LogRequest(_logger, method, path, queryString, correlationId, isAdmin);
        }

        var stopwatch = Stopwatch.StartNew();
        var statusCode = 0;

        try
        {
            await _next(context);
            statusCode = context.Response.StatusCode;
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            statusCode = context.Response.StatusCode;
            if (statusCode < 400) statusCode = 500;

            if (shouldLog)
            {
                BackendLogHelper.LogResponse(_logger, method, path, statusCode, stopwatch.ElapsedMilliseconds, correlationId, isAdmin, ex.Message);
            }

            _logger.LogError(ex,
                "=== REQUEST ERROR === [{Method}] {Path} | Status: {StatusCode} | Duration: {Duration}ms | CorrelationId: {CorrelationId} | Message: {Message}",
                method, path, statusCode, stopwatch.ElapsedMilliseconds, correlationId, ex.Message);
            throw;
        }

        stopwatch.Stop();
        if (shouldLog)
        {
            BackendLogHelper.LogResponse(_logger, method, path, context.Response.StatusCode, stopwatch.ElapsedMilliseconds, correlationId, isAdmin);
        }
    }
}
