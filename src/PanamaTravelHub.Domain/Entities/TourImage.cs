namespace PanamaTravelHub.Domain.Entities;

public class TourImage : BaseEntity
{
    public Guid TourId { get; set; }
    public string ImageUrl { get; set; } = string.Empty;
    public string? AltText { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsPrimary { get; set; }

    // Navigation properties
    public Tour Tour { get; set; } = null!;
}
