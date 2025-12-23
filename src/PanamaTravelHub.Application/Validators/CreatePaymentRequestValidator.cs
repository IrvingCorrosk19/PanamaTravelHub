using FluentValidation;
using PanamaTravelHub.Application.DTOs;

namespace PanamaTravelHub.Application.Validators;

public class CreatePaymentRequestValidator : AbstractValidator<CreatePaymentRequestDto>
{
    public CreatePaymentRequestValidator()
    {
        RuleFor(x => x.BookingId)
            .NotEmpty()
            .WithMessage("El ID de la reserva es requerido");

        RuleFor(x => x.Currency)
            .MaximumLength(3)
            .WithMessage("El código de moneda debe tener máximo 3 caracteres")
            .Matches("^[A-Z]{3}$")
            .WithMessage("El código de moneda debe ser un código ISO 4217 válido (ej: USD, EUR)")
            .When(x => !string.IsNullOrEmpty(x.Currency));
    }
}

