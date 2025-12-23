using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using PanamaTravelHub.Application.Exceptions;
using FluentValidationException = FluentValidation.ValidationException;

namespace PanamaTravelHub.API.Filters;

/// <summary>
/// Filtro para capturar errores de validación de FluentValidation
/// </summary>
public class ValidationFilter : IAsyncActionFilter
{
    private readonly ILogger<ValidationFilter> _logger;

    public ValidationFilter(ILogger<ValidationFilter> logger)
    {
        _logger = logger;
    }

    public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    {
        _logger.LogInformation("=== VALIDATION FILTER ===");
        _logger.LogInformation("Path: {Path}, Method: {Method}", context.HttpContext.Request.Path, context.HttpContext.Request.Method);
        
        // Verificar si hay errores de modelo
        if (!context.ModelState.IsValid)
        {
            _logger.LogWarning("ModelState inválido. Errores: {Errors}", 
                string.Join(", ", context.ModelState.SelectMany(x => x.Value?.Errors.Select(e => e.ErrorMessage) ?? Enumerable.Empty<string>())));
        }

        // Verificar argumentos de acción
        foreach (var argument in context.ActionArguments)
        {
            _logger.LogInformation("Argumento: {Key}, Valor: {Value}, Es null: {IsNull}", 
                argument.Key, 
                argument.Value?.GetType().Name ?? "NULL", 
                argument.Value == null);
        }

        try
        {
            var executedContext = await next();
            
            if (executedContext.Exception != null)
            {
                _logger.LogError(executedContext.Exception, "Excepción capturada en ValidationFilter");
            }
        }
        catch (FluentValidationException ex)
        {
            _logger.LogError(ex, "FluentValidation.ValidationException capturada en ValidationFilter");
            throw;
        }
        catch (PanamaTravelHub.Application.Exceptions.ValidationException ex)
        {
            _logger.LogError(ex, "Application.ValidationException capturada en ValidationFilter");
            throw;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Excepción no esperada en ValidationFilter: {Type}", ex.GetType().Name);
            throw;
        }
        
        _logger.LogInformation("=== FIN VALIDATION FILTER ===");
    }
}

