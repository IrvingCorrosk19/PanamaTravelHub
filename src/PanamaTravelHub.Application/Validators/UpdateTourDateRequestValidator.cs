using FluentValidation;

namespace PanamaTravelHub.Application.Validators;

public class UpdateTourDateRequestDto
{
    public DateTime? TourDateTime { get; set; }
    public int? AvailableSpots { get; set; }
    public bool? IsActive { get; set; }
}

public class UpdateTourDateRequestValidator : AbstractValidator<UpdateTourDateRequestDto>
{
    public UpdateTourDateRequestValidator()
    {
        RuleFor(x => x.TourDateTime)
            .Must(date => !date.HasValue || date.Value > DateTime.UtcNow)
            .WithMessage("La fecha del tour debe ser en el futuro")
            .Must(date => !date.HasValue || date.Value <= DateTime.UtcNow.AddYears(2))
            .WithMessage("La fecha del tour no puede ser más de 2 años en el futuro")
            .When(x => x.TourDateTime.HasValue);

        RuleFor(x => x.AvailableSpots)
            .GreaterThanOrEqualTo(0).WithMessage("Los cupos disponibles no pueden ser negativos")
            .LessThanOrEqualTo(1000).WithMessage("Los cupos disponibles no pueden exceder 1000")
            .When(x => x.AvailableSpots.HasValue);
    }
}

