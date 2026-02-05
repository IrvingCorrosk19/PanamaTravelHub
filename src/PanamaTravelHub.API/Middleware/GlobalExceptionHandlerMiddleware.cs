using System.Collections.Generic;
using System.Net;
using System.Security.Claims;
using System.Text.Json;
using PanamaTravelHub.Application.Exceptions;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Npgsql;

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

        var correlationId = httpContext.TraceIdentifier;
        var problemDetails = new ProblemDetails
        {
            Instance = httpContext.Request.Path,
            Status = (int)HttpStatusCode.InternalServerError,
            Title = "Ha ocurrido un error al procesar su solicitud",
            Detail = _environment.IsDevelopment() ? exception.Message : "Ha ocurrido un error interno del servidor"
        };
        problemDetails.Extensions["correlationId"] = correlationId;

        var endpoint = $"{httpContext.Request.Method} {httpContext.Request.Path}";
        var userId = httpContext.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? httpContext.User?.FindFirst("sub")?.Value;
        var path = httpContext.Request.Path.Value ?? "";
        var isAdminRequest = path.TrimStart('/').StartsWith("admin", StringComparison.OrdinalIgnoreCase)
                            || path.TrimStart('/').StartsWith("api/admin", StringComparison.OrdinalIgnoreCase);

        // Siempre registrar error capturado en formato estructurado (como el frontend) para poder resolver problemas
        BackendLogHelper.LogError(_logger, exception, "ExceptionHandler", correlationId, endpoint, userId, isAdminRequest,
            new Dictionary<string, object?> { ["problemDetailsTitle"] = problemDetails.Title, ["problemDetailsDetail"] = problemDetails.Detail });

        switch (exception)
        {
            case ValidationException validationException:
                response.StatusCode = (int)HttpStatusCode.BadRequest;
                problemDetails.Status = (int)HttpStatusCode.BadRequest;
                problemDetails.Title = "Error de validación";
                problemDetails.Detail = "Uno o más errores de validación han ocurrido";
                problemDetails.Extensions["errors"] = validationException.Errors;
                _logger.LogWarning("Error de validación | CorrelationId: {CorrelationId} | Endpoint: {Endpoint} | UserId: {UserId} | Mensaje: {Message}",
                    correlationId, endpoint, userId ?? "(anon)", "Uno o más errores de validación");
                break;

            case NotFoundException notFoundException:
                response.StatusCode = (int)HttpStatusCode.NotFound;
                problemDetails.Status = (int)HttpStatusCode.NotFound;
                problemDetails.Title = "Recurso no encontrado";
                problemDetails.Detail = notFoundException.Message;
                problemDetails.Extensions["errorCode"] = notFoundException.ErrorCode;
                _logger.LogInformation("Recurso no encontrado | CorrelationId: {CorrelationId} | Endpoint: {Endpoint} | UserId: {UserId} | Mensaje: {Message}",
                    correlationId, endpoint, userId ?? "(anon)", notFoundException.Message);
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
                _logger.LogWarning("Error de negocio | CorrelationId: {CorrelationId} | Endpoint: {Endpoint} | UserId: {UserId} | Mensaje: {Message}",
                    correlationId, endpoint, userId ?? "(anon)", businessException.Message);
                break;

            case UnauthorizedAccessException unauthorizedException:
                response.StatusCode = (int)HttpStatusCode.Unauthorized;
                problemDetails.Status = (int)HttpStatusCode.Unauthorized;
                problemDetails.Title = "No autorizado";
                problemDetails.Detail = unauthorizedException.Message ?? "No tienes permisos para realizar esta acción";
                _logger.LogWarning("Acceso no autorizado | CorrelationId: {CorrelationId} | Endpoint: {Endpoint} | UserId: {UserId} | Mensaje: {Message}",
                    correlationId, endpoint, userId ?? "(anon)", unauthorizedException.Message ?? "No autorizado");
                break;

            case DbUpdateException dbUpdateException:
                // Manejar errores de base de datos
                response.StatusCode = (int)HttpStatusCode.BadRequest;
                problemDetails.Status = (int)HttpStatusCode.BadRequest;
                problemDetails.Title = "Error en la base de datos";
                
                // Detectar violaciones de constraints específicas
                if (dbUpdateException.InnerException is PostgresException pgException)
                {
                    switch (pgException.SqlState)
                    {
                        case "23505": // Unique violation
                            problemDetails.Detail = "Ya existe un registro con estos datos. Por favor verifica la información.";
                            problemDetails.Extensions["errorCode"] = "UNIQUE_CONSTRAINT_VIOLATION";
                            problemDetails.Extensions["constraint"] = pgException.ConstraintName;
                            break;
                        case "23503": // Foreign key violation
                            problemDetails.Detail = "No se puede realizar esta operación porque hay referencias relacionadas.";
                            problemDetails.Extensions["errorCode"] = "FOREIGN_KEY_VIOLATION";
                            break;
                        case "23502": // Not null violation
                            problemDetails.Detail = "Faltan campos requeridos en la base de datos.";
                            problemDetails.Extensions["errorCode"] = "NOT_NULL_VIOLATION";
                            break;
                        case "23514": // Check constraint violation
                            problemDetails.Detail = "Los datos proporcionados no cumplen con las restricciones de validación.";
                            problemDetails.Extensions["errorCode"] = "CHECK_CONSTRAINT_VIOLATION";
                            break;
                        default:
                            problemDetails.Detail = _environment.IsDevelopment() 
                                ? $"Error de base de datos: {pgException.Message}" 
                                : "Error al guardar los datos. Por favor intenta de nuevo.";
                            problemDetails.Extensions["errorCode"] = "DATABASE_ERROR";
                            problemDetails.Extensions["sqlState"] = pgException.SqlState;
                            break;
                    }
                }
                else
                {
                    problemDetails.Detail = _environment.IsDevelopment() 
                        ? dbUpdateException.Message 
                        : "Error al guardar los datos. Por favor intenta de nuevo.";
                    problemDetails.Extensions["errorCode"] = "DATABASE_ERROR";
                }
                
                _logger.LogError("Error de base de datos | CorrelationId: {CorrelationId} | Endpoint: {Endpoint} | UserId: {UserId} | Mensaje: {Message} | Inner: {InnerMessage}",
                    correlationId, endpoint, userId ?? "(anon)", dbUpdateException.Message, dbUpdateException.InnerException?.Message ?? "");
                break;

            case ArgumentNullException argumentNullException:
                response.StatusCode = (int)HttpStatusCode.BadRequest;
                problemDetails.Status = (int)HttpStatusCode.BadRequest;
                problemDetails.Title = "Parámetro requerido faltante";
                problemDetails.Detail = $"El parámetro '{argumentNullException.ParamName}' es requerido.";
                problemDetails.Extensions["errorCode"] = "ARGUMENT_NULL";
                problemDetails.Extensions["paramName"] = argumentNullException.ParamName;
                _logger.LogWarning("Argumento nulo | CorrelationId: {CorrelationId} | Endpoint: {Endpoint} | UserId: {UserId} | ParamName: {ParamName}",
                    correlationId, endpoint, userId ?? "(anon)", argumentNullException.ParamName);
                break;

            case ArgumentException argumentException:
                response.StatusCode = (int)HttpStatusCode.BadRequest;
                problemDetails.Status = (int)HttpStatusCode.BadRequest;
                problemDetails.Title = "Argumento inválido";
                problemDetails.Detail = argumentException.Message;
                problemDetails.Extensions["errorCode"] = "INVALID_ARGUMENT";
                if (!string.IsNullOrEmpty(argumentException.ParamName))
                {
                    problemDetails.Extensions["paramName"] = argumentException.ParamName;
                }
                _logger.LogWarning("Argumento inválido | CorrelationId: {CorrelationId} | Endpoint: {Endpoint} | UserId: {UserId} | Mensaje: {Message}",
                    correlationId, endpoint, userId ?? "(anon)", argumentException.Message);
                break;

            case InvalidOperationException invalidOperationException:
                response.StatusCode = (int)HttpStatusCode.BadRequest;
                problemDetails.Status = (int)HttpStatusCode.BadRequest;
                problemDetails.Title = "Operación inválida";
                problemDetails.Detail = _environment.IsDevelopment() 
                    ? invalidOperationException.Message 
                    : "No se puede realizar esta operación en el estado actual.";
                problemDetails.Extensions["errorCode"] = "INVALID_OPERATION";
                _logger.LogWarning("Operación inválida | CorrelationId: {CorrelationId} | Endpoint: {Endpoint} | UserId: {UserId} | Mensaje: {Message}",
                    correlationId, endpoint, userId ?? "(anon)", invalidOperationException.Message);
                break;

            case TimeoutException timeoutException:
                response.StatusCode = (int)HttpStatusCode.RequestTimeout;
                problemDetails.Status = (int)HttpStatusCode.RequestTimeout;
                problemDetails.Title = "Tiempo de espera agotado";
                problemDetails.Detail = "La operación tardó demasiado tiempo. Por favor intenta de nuevo.";
                problemDetails.Extensions["errorCode"] = "TIMEOUT";
                _logger.LogWarning("Timeout | CorrelationId: {CorrelationId} | Endpoint: {Endpoint} | UserId: {UserId}",
                    correlationId, endpoint, userId ?? "(anon)");
                break;

            default:
                // Error no manejado: log completo en servidor (nunca tokens/PII)
                _logger.LogError(exception,
                    "Error no manejado | CorrelationId: {CorrelationId} | Endpoint: {Endpoint} | UserId: {UserId} | Tipo: {ExceptionType} | Mensaje: {Message}",
                    correlationId, endpoint, userId ?? "(anon)", exception.GetType().Name, exception.Message);
                if (_environment.IsDevelopment())
                {
                    _logger.LogError("StackTrace: {StackTrace}", exception.StackTrace);
                    if (exception.InnerException != null)
                        _logger.LogError("InnerException: {InnerMessage}", exception.InnerException.Message);
                }

                // Producción: solo mensaje genérico + correlationId (sin stack trace ni detalles técnicos en respuesta)
                if (_environment.IsProduction())
                {
                    problemDetails.Detail = "Ha ocurrido un error interno del servidor.";
                    problemDetails.Title = "Ha ocurrido un error al procesar su solicitud";
                }
                else
                {
                    problemDetails.Detail = exception.Message;
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

