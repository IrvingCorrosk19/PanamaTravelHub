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

            case UnauthorizedAccessException:
                response.StatusCode = (int)HttpStatusCode.Unauthorized;
                problemDetails.Status = (int)HttpStatusCode.Unauthorized;
                problemDetails.Title = "No autorizado";
                problemDetails.Detail = "No tienes permisos para realizar esta acción";
                _logger.LogWarning(exception, "Acceso no autorizado: {TraceId}", traceId);
                break;

            default:
                // Error no manejado
                _logger.LogError(exception, 
                    "Error no manejado: {Message} - {TraceId} - {StackTrace}", 
                    exception.Message, 
                    traceId,
                    _environment.IsDevelopment() ? exception.StackTrace : "Oculto en producción");
                
                if (_environment.IsDevelopment())
                {
                    problemDetails.Extensions["exception"] = new
                    {
                        Type = exception.GetType().Name,
                        Message = exception.Message,
                        StackTrace = exception.StackTrace,
                        InnerExceptionMessage = exception.InnerException?.Message
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

