using FluentValidation;

namespace PanamaTravelHub.Application.Validators;

public class RefreshTokenRequestDto
{
    public string RefreshToken { get; set; } = string.Empty;
}

public class RefreshTokenRequestValidator : AbstractValidator<RefreshTokenRequestDto>
{
    public RefreshTokenRequestValidator()
    {
        RuleFor(x => x.RefreshToken)
            .NotEmpty().WithMessage("El refresh token es requerido")
            .Must(token => Guid.TryParse(token, out _))
            .WithMessage("El refresh token debe tener un formato válido");
    }
}

