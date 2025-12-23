using System.Net;
using System.Text.Json;
using PanamaTravelHub.Application.Exceptions;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;

namespace PanamaTravelHub.API.Middleware;

/// <summary>
/// Middleware global para manejo de excepciones
/// </summary>
public class GlobalExceptionHandlerMiddleware : IExceptionHandler
{
    private readonly ILogger<GlobalExceptionHandlerMiddleware> _logger;
    private readonly IWebHostEnvironment _environment;

    public GlobalExceptionHandlerMiddleware(
        ILogger<GlobalExceptionHandlerMiddleware> logger,
        IWebHostEnvironment environment)
    {
        _logger = logger;
        _environment = environment;
    }

    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        var response = httpContext.Response;
        response.ContentType = "application/json";

        var problemDetails = new ProblemDetails
        {
            Instance = httpContext.Request.Path,
            Status = (int)HttpStatusCode.InternalServerError,
            Title = "Ha ocurrido un error al procesar su solicitud",
            Detail = _environment.IsDevelopment() ? exception.Message : "Ha ocurrido un error interno del servidor"
        };

        // Agregar trace ID para debugging
        var traceId = httpContext.TraceIdentifier;
        problemDetails.Extensions["traceId"] = traceId;

        switch (exception)
        {
            case ValidationException validationException:
                response.StatusCode = (int)HttpStatusCode.BadRequest;
                problemDetails.Status = (int)HttpStatusCode.BadRequest;
                problemDetails.Title = "Error de validación";
                problemDetails.Detail = "Uno o más errores de validación han ocurrido";
                problemDetails.Extensions["errors"] = validationException.Errors;
                _logger.LogWarning(exception, "Error de validación: {TraceId}", traceId);
                break;

            case NotFoundException notFoundException:
                response.StatusCode = (int)HttpStatusCode.NotFound;
                problemDetails.Status = (int)HttpStatusCode.NotFound;
                problemDetails.Title = "Recurso no encontrado";
                problemDetails.Detail = notFoundException.Message;
                problemDetails.Extensions["errorCode"] = notFoundException.ErrorCode;
                _logger.LogInformation(exception, "Recurso no encontrado: {Message} - {TraceId}", notFoundException.Message, traceId);
                break;

            case BusinessException businessException:
                response.StatusCode = (int)HttpStatusCode.BadRequest;
                problemDetails.Status = (int)HttpStatusCode.BadRequest;
                problemDetails.Title = "Error de negocio";
                problemDetails.Detail = businessException.Message;
                if (!string.IsNullOrEmpty(businessException.ErrorCode))
                {
                    problemDetails.Extensions["errorCode"] = businessException.ErrorCode;
                }
                if (businessException.Details != null)
                {
                    problemDetails.Extensions["details"] = businessException.Details;
                }
                _logger.LogWarning(exception, "Error de negocio: {Message} - {TraceId}", businessException.Message, traceId);
                break;

            case UnauthorizedAccessException unauthorizedException:
                response.StatusCode = (int)HttpStatusCode.Unauthorized;
                problemDetails.Status = (int)HttpStatusCode.Unauthorized;
                problemDetails.Title = "No autorizado";
                problemDetails.Detail = unauthorizedException.Message ?? "No tienes permisos para realizar esta acción";
                _logger.LogWarning(exception, "Acceso no autorizado: {Message} - {TraceId}", unauthorizedException.Message, traceId);
                break;

            default:
                // Error no manejado
                _logger.LogError(exception, 
                    "=== ERROR NO MANEJADO ===");
                _logger.LogError("Tipo: {ExceptionType}", exception.GetType().Name);
                _logger.LogError("Mensaje: {Message}", exception.Message);
                _logger.LogError("TraceId: {TraceId}", traceId);
                _logger.LogError("Path: {Path}", httpContext.Request.Path);
                _logger.LogError("Method: {Method}", httpContext.Request.Method);
                
                if (exception.InnerException != null)
                {
                    _logger.LogError("InnerException Tipo: {InnerType}", exception.InnerException.GetType().Name);
                    _logger.LogError("InnerException Mensaje: {InnerMessage}", exception.InnerException.Message);
                    _logger.LogError("InnerException StackTrace: {InnerStackTrace}", exception.InnerException.StackTrace);
                    
                    // Si hay un InnerException anidado, también loguearlo
                    if (exception.InnerException.InnerException != null)
                    {
                        _logger.LogError("InnerException.InnerException Tipo: {Type}", exception.InnerException.InnerException.GetType().Name);
                        _logger.LogError("InnerException.InnerException Mensaje: {Message}", exception.InnerException.InnerException.Message);
                    }
                }
                
                if (_environment.IsDevelopment() || _environment.IsProduction())
                {
                    _logger.LogError("StackTrace: {StackTrace}", exception.StackTrace);
                }
                
                _logger.LogError("=== FIN ERROR NO MANEJADO ===");
                
                // En producción también mostrar detalles del error para debugging
                problemDetails.Detail = _environment.IsProduction() 
                    ? $"Error: {exception.GetType().Name} - {exception.Message}" 
                    : exception.Message;
                
                if (_environment.IsDevelopment() || _environment.IsProduction())
                {
                    problemDetails.Extensions["exception"] = new
                    {
                        Type = exception.GetType().Name,
                        Message = exception.Message,
                        StackTrace = exception.StackTrace,
                        InnerExceptionMessage = exception.InnerException?.Message,
                        InnerExceptionType = exception.InnerException?.GetType().Name,
                        InnerExceptionStackTrace = exception.InnerException?.StackTrace,
                        InnerInnerExceptionMessage = exception.InnerException?.InnerException?.Message,
                        InnerInnerExceptionType = exception.InnerException?.InnerException?.GetType().Name
                    };
                }
                break;
        }

        var jsonOptions = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        };

        var json = JsonSerializer.Serialize(problemDetails, jsonOptions);
        await response.WriteAsync(json, cancellationToken);

        return true;
    }
}

