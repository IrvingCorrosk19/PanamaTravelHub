using System.Diagnostics;

namespace PanamaTravelHub.API.Middleware;

/// <summary>
/// Middleware para registrar todas las requests HTTP
/// </summary>
public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    // Endpoints que no deben ser logueados (para evitar spam)
    private static readonly HashSet<string> ExcludedPaths = new()
    {
        "/health",
        "/health/live",
        "/health/ready",
        "/swagger",
        "/favicon.ico"
    };

    public RequestLoggingMiddleware(
        RequestDelegate next,
        ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var path = context.Request.Path.Value?.ToLower() ?? "";
        
        // Excluir ciertos paths del logging detallado
        var shouldLogDetails = !ExcludedPaths.Any(excluded => path.Contains(excluded));

        var correlationId = context.Request.Headers["X-Correlation-Id"].FirstOrDefault() 
                          ?? context.TraceIdentifier;

        var method = context.Request.Method;
        var queryString = context.Request.QueryString.HasValue ? context.Request.QueryString.Value : "";
        var ipAddress = context.Connection.RemoteIpAddress?.ToString() 
                       ?? context.Request.Headers["X-Forwarded-For"].FirstOrDefault()
                       ?? "Unknown";

        if (shouldLogDetails)
        {
            _logger.LogInformation(
                "=== REQUEST IN === [{Method}] {Path}{QueryString} | IP: {IpAddress} | CorrelationId: {CorrelationId}",
                method,
                context.Request.Path,
                queryString,
                ipAddress,
                correlationId);
        }

        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            await _next(context);
            stopwatch.Stop();

            if (shouldLogDetails)
            {
                _logger.LogInformation(
                    "=== RESPONSE OUT === [{Method}] {Path} | Status: {StatusCode} | Duration: {Duration}ms | CorrelationId: {CorrelationId}",
                    method,
                    context.Request.Path,
                    context.Response.StatusCode,
                    stopwatch.ElapsedMilliseconds,
                    correlationId);
            }
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            _logger.LogError(
                ex,
                "=== REQUEST ERROR === [{Method}] {Path} | Status: {StatusCode} | Duration: {Duration}ms | CorrelationId: {CorrelationId}",
                method,
                context.Request.Path,
                context.Response.StatusCode,
                stopwatch.ElapsedMilliseconds,
                correlationId);
            throw;
        }
    }
}
