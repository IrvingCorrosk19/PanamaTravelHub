using FluentValidation;
using PanamaTravelHub.Application.DTOs;

namespace PanamaTravelHub.Application.Validators;

public class RefundRequestValidator : AbstractValidator<RefundRequestDto>
{
    public RefundRequestValidator()
    {
        RuleFor(x => x.PaymentId)
            .NotEmpty()
            .WithMessage("El ID del pago es requerido");

        RuleFor(x => x.Amount)
            .GreaterThan(0)
            .WithMessage("El monto del reembolso debe ser mayor a cero")
            .When(x => x.Amount.HasValue);
    }
}

