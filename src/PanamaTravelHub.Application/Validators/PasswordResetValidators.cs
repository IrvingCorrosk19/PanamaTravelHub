using FluentValidation;

namespace PanamaTravelHub.Application.Validators;

/// <summary>
/// DTO para solicitar recuperación de contraseña
/// </summary>
public class ForgotPasswordRequestDto
{
    public string Email { get; set; } = string.Empty;
}

public class ForgotPasswordRequestValidator : AbstractValidator<ForgotPasswordRequestDto>
{
    public ForgotPasswordRequestValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("El email es requerido")
            .EmailAddress().WithMessage("El email no tiene un formato válido")
            .MaximumLength(255).WithMessage("El email no puede exceder 255 caracteres");
    }
}

/// <summary>
/// DTO para resetear contraseña con token
/// </summary>
public class ResetPasswordRequestDto
{
    public string Token { get; set; } = string.Empty;
    public string NewPassword { get; set; } = string.Empty;
    public string ConfirmPassword { get; set; } = string.Empty;
}

public class ResetPasswordRequestValidator : AbstractValidator<ResetPasswordRequestDto>
{
    public ResetPasswordRequestValidator()
    {
        RuleFor(x => x.Token)
            .NotEmpty().WithMessage("El token es requerido");

        RuleFor(x => x.NewPassword)
            .NotEmpty().WithMessage("La nueva contraseña es requerida")
            .MinimumLength(8).WithMessage("La contraseña debe tener al menos 8 caracteres")
            .MaximumLength(100).WithMessage("La contraseña no puede exceder 100 caracteres")
            .Matches(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)").WithMessage("La contraseña debe contener al menos una letra minúscula, una mayúscula y un número")
            .When(x => !string.IsNullOrEmpty(x.NewPassword));

        RuleFor(x => x.ConfirmPassword)
            .NotEmpty().WithMessage("Debes confirmar tu contraseña")
            .Equal(x => x.NewPassword).WithMessage("Las contraseñas no coinciden");
    }
}
