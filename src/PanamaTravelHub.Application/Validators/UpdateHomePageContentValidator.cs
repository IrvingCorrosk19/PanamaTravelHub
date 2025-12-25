using FluentValidation;
using PanamaTravelHub.Application.DTOs;

namespace PanamaTravelHub.Application.Validators;

public class UpdateHomePageContentValidator : AbstractValidator<UpdateHomePageContentDto>
{
    public UpdateHomePageContentValidator()
    {
        // Validar longitudes máximas para todos los campos opcionales
        RuleFor(x => x.HeroTitle)
            .MaximumLength(200)
            .WithMessage("El título del hero no puede exceder 200 caracteres")
            .When(x => !string.IsNullOrEmpty(x.HeroTitle));

        RuleFor(x => x.HeroSubtitle)
            .MaximumLength(500)
            .WithMessage("El subtítulo del hero no puede exceder 500 caracteres")
            .When(x => !string.IsNullOrEmpty(x.HeroSubtitle));

        RuleFor(x => x.HeroSearchPlaceholder)
            .MaximumLength(100)
            .WithMessage("El placeholder de búsqueda no puede exceder 100 caracteres")
            .When(x => !string.IsNullOrEmpty(x.HeroSearchPlaceholder));

        RuleFor(x => x.HeroSearchButton)
            .MaximumLength(50)
            .WithMessage("El texto del botón de búsqueda no puede exceder 50 caracteres")
            .When(x => !string.IsNullOrEmpty(x.HeroSearchButton));

        RuleFor(x => x.ToursSectionTitle)
            .MaximumLength(200)
            .WithMessage("El título de la sección de tours no puede exceder 200 caracteres")
            .When(x => !string.IsNullOrEmpty(x.ToursSectionTitle));

        RuleFor(x => x.ToursSectionSubtitle)
            .MaximumLength(500)
            .WithMessage("El subtítulo de la sección de tours no puede exceder 500 caracteres")
            .When(x => !string.IsNullOrEmpty(x.ToursSectionSubtitle));

        RuleFor(x => x.FooterBrandText)
            .MaximumLength(100)
            .WithMessage("El texto de marca del footer no puede exceder 100 caracteres")
            .When(x => !string.IsNullOrEmpty(x.FooterBrandText));

        RuleFor(x => x.FooterDescription)
            .MaximumLength(500)
            .WithMessage("La descripción del footer no puede exceder 500 caracteres")
            .When(x => !string.IsNullOrEmpty(x.FooterDescription));

        RuleFor(x => x.FooterCopyright)
            .MaximumLength(200)
            .WithMessage("El copyright del footer no puede exceder 200 caracteres")
            .When(x => !string.IsNullOrEmpty(x.FooterCopyright));

        RuleFor(x => x.NavBrandText)
            .MaximumLength(100)
            .WithMessage("El texto de marca de navegación no puede exceder 100 caracteres")
            .When(x => !string.IsNullOrEmpty(x.NavBrandText));

        RuleFor(x => x.NavToursLink)
            .MaximumLength(50)
            .WithMessage("El texto del enlace de tours no puede exceder 50 caracteres")
            .When(x => !string.IsNullOrEmpty(x.NavToursLink));

        RuleFor(x => x.NavBookingsLink)
            .MaximumLength(50)
            .WithMessage("El texto del enlace de reservas no puede exceder 50 caracteres")
            .When(x => !string.IsNullOrEmpty(x.NavBookingsLink));

        RuleFor(x => x.NavLoginLink)
            .MaximumLength(50)
            .WithMessage("El texto del enlace de login no puede exceder 50 caracteres")
            .When(x => !string.IsNullOrEmpty(x.NavLoginLink));

        RuleFor(x => x.NavLogoutButton)
            .MaximumLength(50)
            .WithMessage("El texto del botón de logout no puede exceder 50 caracteres")
            .When(x => !string.IsNullOrEmpty(x.NavLogoutButton));

        RuleFor(x => x.LoadingToursText)
            .MaximumLength(100)
            .WithMessage("El texto de carga de tours no puede exceder 100 caracteres")
            .When(x => !string.IsNullOrEmpty(x.LoadingToursText));

        RuleFor(x => x.ErrorLoadingToursText)
            .MaximumLength(200)
            .WithMessage("El texto de error al cargar tours no puede exceder 200 caracteres")
            .When(x => !string.IsNullOrEmpty(x.ErrorLoadingToursText));

        RuleFor(x => x.NoToursFoundText)
            .MaximumLength(200)
            .WithMessage("El texto de no hay tours no puede exceder 200 caracteres")
            .When(x => !string.IsNullOrEmpty(x.NoToursFoundText));

        RuleFor(x => x.PageTitle)
            .MaximumLength(100)
            .WithMessage("El título de la página no puede exceder 100 caracteres")
            .When(x => !string.IsNullOrEmpty(x.PageTitle));

        RuleFor(x => x.MetaDescription)
            .MaximumLength(300)
            .WithMessage("La meta descripción no puede exceder 300 caracteres")
            .When(x => !string.IsNullOrEmpty(x.MetaDescription));

        RuleFor(x => x.LogoUrl)
            .MaximumLength(500)
            .WithMessage("La URL del logo no puede exceder 500 caracteres")
            .When(x => !string.IsNullOrEmpty(x.LogoUrl));

        RuleFor(x => x.FaviconUrl)
            .MaximumLength(500)
            .WithMessage("La URL del favicon no puede exceder 500 caracteres")
            .When(x => !string.IsNullOrEmpty(x.FaviconUrl));

        RuleFor(x => x.LogoUrlSocial)
            .MaximumLength(500)
            .WithMessage("La URL del logo para redes sociales no puede exceder 500 caracteres")
            .When(x => !string.IsNullOrEmpty(x.LogoUrlSocial));
    }
}

