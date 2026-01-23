using FluentValidation;

namespace PanamaTravelHub.Application.Validators;

public class CreateBookingRequestDto
{
    public Guid? UserId { get; set; }
    public Guid TourId { get; set; }
    public Guid? TourDateId { get; set; }
    public int NumberOfParticipants { get; set; }
    public Guid? CountryId { get; set; } // País desde el cual se realiza la reserva
    public List<ParticipantRequestDto> Participants { get; set; } = new();
    public string? CouponCode { get; set; } // Código de cupón opcional
}

public class ParticipantRequestDto
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? Email { get; set; }
    public string? Phone { get; set; }
    public DateTime? DateOfBirth { get; set; }
}

public class CreateBookingRequestValidator : AbstractValidator<CreateBookingRequestDto>
{
    public CreateBookingRequestValidator()
    {
        RuleFor(x => x.TourId)
            .NotEmpty().WithMessage("El ID del tour es requerido");

        RuleFor(x => x.NumberOfParticipants)
            .GreaterThan(0).WithMessage("El número de participantes debe ser mayor a 0")
            .LessThanOrEqualTo(50).WithMessage("El número de participantes no puede exceder 50");

        RuleFor(x => x.Participants)
            .NotEmpty().WithMessage("Debe proporcionar al menos un participante")
            .Must((request, participants) => participants.Count == request.NumberOfParticipants)
            .WithMessage("El número de participantes debe coincidir con la lista proporcionada");

        RuleForEach(x => x.Participants)
            .SetValidator(new ParticipantRequestValidator());
    }
}

public class ParticipantRequestValidator : AbstractValidator<ParticipantRequestDto>
{
    public ParticipantRequestValidator()
    {
        RuleFor(x => x.FirstName)
            .NotEmpty().WithMessage("El nombre del participante es requerido")
            .MaximumLength(100).WithMessage("El nombre no puede exceder 100 caracteres");

        RuleFor(x => x.LastName)
            .NotEmpty().WithMessage("El apellido del participante es requerido")
            .MaximumLength(100).WithMessage("El apellido no puede exceder 100 caracteres");

        RuleFor(x => x.Email)
            .EmailAddress().WithMessage("El email no tiene un formato válido")
            .When(x => !string.IsNullOrEmpty(x.Email));

        RuleFor(x => x.Phone)
            .MaximumLength(20).WithMessage("El teléfono no puede exceder 20 caracteres")
            .Matches(@"^\+?[\d\s\-\(\)]+$").WithMessage("El teléfono no tiene un formato válido")
            .When(x => !string.IsNullOrEmpty(x.Phone));

        RuleFor(x => x.DateOfBirth)
            .LessThan(DateTime.Today).WithMessage("La fecha de nacimiento debe ser anterior a hoy")
            .GreaterThan(DateTime.Today.AddYears(-120)).WithMessage("La fecha de nacimiento no es válida")
            .When(x => x.DateOfBirth.HasValue);
    }
}



