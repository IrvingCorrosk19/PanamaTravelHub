using FluentValidation;

namespace PanamaTravelHub.Application.Validators;

public class UpdateTourRequestDto
{
    public string? Name { get; set; }
    public string? Description { get; set; }
    public string? Itinerary { get; set; }
    public string? Includes { get; set; }
    public decimal? Price { get; set; }
    public int? MaxCapacity { get; set; }
    public int? DurationHours { get; set; }
    public string? Location { get; set; }
    public bool? IsActive { get; set; }
    public List<string>? Images { get; set; }
}

public class UpdateTourRequestValidator : AbstractValidator<UpdateTourRequestDto>
{
    public UpdateTourRequestValidator()
    {
        RuleFor(x => x.Name)
            .MaximumLength(200).WithMessage("El nombre no puede exceder 200 caracteres")
            .When(x => !string.IsNullOrEmpty(x.Name));

        RuleFor(x => x.Description)
            .MinimumLength(50).WithMessage("La descripción debe tener al menos 50 caracteres")
            .MaximumLength(2000).WithMessage("La descripción no puede exceder 2000 caracteres")
            .When(x => !string.IsNullOrEmpty(x.Description));

        RuleFor(x => x.Itinerary)
            .MaximumLength(5000).WithMessage("El itinerario no puede exceder 5000 caracteres")
            .When(x => !string.IsNullOrEmpty(x.Itinerary));

        RuleFor(x => x.Includes)
            .MaximumLength(2000).WithMessage("El campo 'Qué Incluye' no puede exceder 2000 caracteres")
            .When(x => !string.IsNullOrEmpty(x.Includes));

        RuleFor(x => x.Price)
            .GreaterThan(0).WithMessage("El precio debe ser mayor a 0")
            .LessThanOrEqualTo(10000).WithMessage("El precio no puede exceder $10,000")
            .When(x => x.Price.HasValue);

        RuleFor(x => x.MaxCapacity)
            .GreaterThan(0).WithMessage("La capacidad máxima debe ser mayor a 0")
            .LessThanOrEqualTo(100).WithMessage("La capacidad máxima no puede exceder 100 personas")
            .When(x => x.MaxCapacity.HasValue);

        RuleFor(x => x.DurationHours)
            .GreaterThan(0).WithMessage("La duración debe ser mayor a 0 horas")
            .LessThanOrEqualTo(48).WithMessage("La duración no puede exceder 48 horas")
            .When(x => x.DurationHours.HasValue);

        RuleFor(x => x.Location)
            .MaximumLength(200).WithMessage("La ubicación no puede exceder 200 caracteres")
            .When(x => !string.IsNullOrEmpty(x.Location));

        RuleFor(x => x.Images)
            .Must(images => images == null || images.Count <= 5)
            .WithMessage("No se pueden agregar más de 5 imágenes")
            .Must(images => images == null || images.All(url => Uri.TryCreate(url, UriKind.Absolute, out _)))
            .WithMessage("Todas las URLs de imágenes deben ser válidas")
            .When(x => x.Images != null && x.Images.Any());
    }
}



