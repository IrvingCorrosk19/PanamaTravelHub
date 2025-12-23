using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace PanamaTravelHub.API.Filters;

/// <summary>
/// Filtro simplificado para logging de validaciones
/// La validación real se hace en FluentValidationFilter
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
        // Si hay errores de ModelState (antes de FluentValidation), loguearlos
        if (!context.ModelState.IsValid)
        {
            var errors = context.ModelState
                .SelectMany(x => x.Value?.Errors.Select(e => e.ErrorMessage) ?? Enumerable.Empty<string>())
                .ToList();
            
            if (errors.Any())
            {
                _logger.LogWarning("Errores de ModelState detectados: {Errors}", string.Join(", ", errors));
            }
        }

        await next();
    }
}


