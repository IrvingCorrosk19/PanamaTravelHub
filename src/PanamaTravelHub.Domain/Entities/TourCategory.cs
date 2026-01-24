namespace PanamaTravelHub.Domain.Entities;

public class TourCategory : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int DisplayOrder { get; set; } = 0;
    public bool IsActive { get; set; } = true;

    // Navigation properties
    public ICollection<TourCategoryAssignment> TourCategoryAssignments { get; set; } = new List<TourCategoryAssignment>();
}
