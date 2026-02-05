using FluentValidation;

namespace PanamaTravelHub.Application.Validators;

public class UpdateUserRequestDto
{
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public string? Phone { get; set; }
    public bool? IsActive { get; set; }
    public List<string>? Roles { get; set; }
    /// <summary>Nueva contraseña (opcional). Si se envía, se actualiza.</summary>
    public string? Password { get; set; }
}

public class UpdateUserRequestValidator : AbstractValidator<UpdateUserRequestDto>
{
    public UpdateUserRequestValidator()
    {
        RuleFor(x => x.FirstName)
            .MaximumLength(100).WithMessage("El nombre no puede exceder 100 caracteres")
            .Matches(@"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$").WithMessage("El nombre solo puede contener letras y espacios")
            .When(x => !string.IsNullOrEmpty(x.FirstName));

        RuleFor(x => x.LastName)
            .MaximumLength(100).WithMessage("El apellido no puede exceder 100 caracteres")
            .Matches(@"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$").WithMessage("El apellido solo puede contener letras y espacios")
            .When(x => !string.IsNullOrEmpty(x.LastName));

        RuleFor(x => x.Phone)
            .MaximumLength(20).WithMessage("El teléfono no puede exceder 20 caracteres")
            .Matches(@"^\+?[\d\s\-\(\)]+$").WithMessage("El teléfono no tiene un formato válido")
            .When(x => !string.IsNullOrEmpty(x.Phone));

        RuleFor(x => x.Roles)
            .Must(roles => roles == null || roles.All(r => r == "Admin" || r == "Customer"))
            .WithMessage("Los roles válidos son: Admin, Customer")
            .When(x => x.Roles != null && x.Roles.Any());
    }
}

