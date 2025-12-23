using FluentValidation;
using PanamaTravelHub.Application.DTOs;

namespace PanamaTravelHub.Application.Validators;

public class ConfirmPaymentRequestValidator : AbstractValidator<ConfirmPaymentRequestDto>
{
    public ConfirmPaymentRequestValidator()
    {
        RuleFor(x => x.PaymentIntentId)
            .NotEmpty()
            .WithMessage("El PaymentIntentId es requerido")
            .MaximumLength(255)
            .WithMessage("El PaymentIntentId no puede exceder 255 caracteres");
    }
}

