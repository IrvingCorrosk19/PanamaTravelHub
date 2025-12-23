using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using PanamaTravelHub.Application.Exceptions;

namespace PanamaTravelHub.API.Filters;

/// <summary>
/// Filtro para validar automáticamente los modelos usando FluentValidation
/// </summary>
public class FluentValidationFilter : IAsyncActionFilter
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<FluentValidationFilter> _logger;

    public FluentValidationFilter(
        IServiceProvider serviceProvider,
        ILogger<FluentValidationFilter> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    {
        // Validar cada argumento de la acción
        foreach (var argument in context.ActionArguments.Values)
        {
            if (argument == null) continue;

            var argumentType = argument.GetType();
            var validatorType = typeof(IValidator<>).MakeGenericType(argumentType);
            var validator = _serviceProvider.GetService(validatorType) as IValidator;

            if (validator != null)
            {
                var validationContext = new ValidationContext<object>(argument);
                var validationResult = await validator.ValidateAsync(validationContext);

                if (!validationResult.IsValid)
                {
                    _logger.LogWarning("Validación fallida para {Type}: {Errors}", 
                        argumentType.Name, 
                        string.Join(", ", validationResult.Errors.Select(e => e.ErrorMessage)));

                    // Convertir errores de FluentValidation a ValidationException
                    // ValidationException tiene un constructor que acepta IEnumerable<ValidationFailure>
                    throw new PanamaTravelHub.Application.Exceptions.ValidationException(validationResult.Errors);
                }
            }
        }

        await next();
    }
}

