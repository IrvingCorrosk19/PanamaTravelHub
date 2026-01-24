namespace PanamaTravelHub.Domain.Entities;

public class Tour : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? Itinerary { get; set; }
    public string? Includes { get; set; }
    public decimal Price { get; set; }
    public int MaxCapacity { get; set; }
    public int DurationHours { get; set; }
    public string? Location { get; set; }
    public DateTime? TourDate { get; set; } // Fecha principal del tour
    public bool IsActive { get; set; } = true;
    public int AvailableSpots { get; set; }
    
    // CMS Blocks - Editable desde admin
    public string? HeroTitle { get; set; }
    public string? HeroSubtitle { get; set; }
    public string? HeroCtaText { get; set; } = "Ver fechas disponibles";
    public string? SocialProofText { get; set; }
    public bool HasCertifiedGuide { get; set; } = true;
    public bool HasFlexibleCancellation { get; set; } = true;
    public string? AvailableLanguages { get; set; } // JSON array
    public string? HighlightsDuration { get; set; }
    public string? HighlightsGroupType { get; set; }
    public string? HighlightsPhysicalLevel { get; set; }
    public string? HighlightsMeetingPoint { get; set; }
    public string? StoryContent { get; set; } // WYSIWYG content
    public string? IncludesList { get; set; } // JSON array o texto
    public string? ExcludesList { get; set; } // JSON array o texto
    public string? MapCoordinates { get; set; } // "lat,lng"
    public string? MapReferenceText { get; set; }
    public string? FinalCtaText { get; set; } = "¿Listo para vivir esta experiencia?";
    public string? FinalCtaButtonText { get; set; } = "Ver fechas disponibles";
    public string? BlockOrder { get; set; } // JSON array
    public string? BlockEnabled { get; set; } // JSON object

    // Navigation properties
    public ICollection<TourImage> TourImages { get; set; } = new List<TourImage>();
    public ICollection<TourDate> TourDates { get; set; } = new List<TourDate>();
    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
    public ICollection<TourReview> Reviews { get; set; } = new List<TourReview>();
    public ICollection<TourCategoryAssignment> TourCategoryAssignments { get; set; } = new List<TourCategoryAssignment>();
    public ICollection<TourTagAssignment> TourTagAssignments { get; set; } = new List<TourTagAssignment>();
}
