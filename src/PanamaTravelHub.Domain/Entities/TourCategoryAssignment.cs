namespace PanamaTravelHub.Domain.Entities;

public class TourCategoryAssignment : BaseEntity
{
    public Guid TourId { get; set; }
    public Guid CategoryId { get; set; }

    // Navigation properties
    public Tour Tour { get; set; } = null!;
    public TourCategory Category { get; set; } = null!;
}
