namespace PanamaTravelHub.Domain.Entities;

public class TourTagAssignment : BaseEntity
{
    public Guid TourId { get; set; }
    public Guid TagId { get; set; }

    // Navigation properties
    public Tour Tour { get; set; } = null!;
    public TourTag Tag { get; set; } = null!;
}
