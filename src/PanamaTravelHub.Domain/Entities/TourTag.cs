namespace PanamaTravelHub.Domain.Entities;

public class TourTag : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;

    // Navigation properties
    public ICollection<TourTagAssignment> TourTagAssignments { get; set; } = new List<TourTagAssignment>();
}
