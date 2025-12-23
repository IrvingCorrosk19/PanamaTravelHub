using FluentValidation.Results;

namespace PanamaTravelHub.Application.Exceptions;

/// <summary>
/// Excepción para errores de validación
/// </summary>
public class ValidationException : Exception
{
    public IDictionary<string, string[]> Errors { get; }

    public ValidationException() : base("Uno o más errores de validación han ocurrido")
    {
        Errors = new Dictionary<string, string[]>();
    }

    public ValidationException(IEnumerable<ValidationFailure> failures) : this()
    {
        Errors = failures
            .GroupBy(e => e.PropertyName, e => e.ErrorMessage)
            .ToDictionary(failureGroup => failureGroup.Key, failureGroup => failureGroup.ToArray());
    }

    public ValidationException(string propertyName, string errorMessage) : this()
    {
        Errors.Add(propertyName, new[] { errorMessage });
    }
}



