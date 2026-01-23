namespace PanamaTravelHub.Domain.Entities;

public class UserFavorite : BaseEntity
{
    public Guid UserId { get; set; }
    public Guid TourId { get; set; }
    
    // Navigation properties
    public User User { get; set; } = null!;
    public Tour Tour { get; set; } = null!;
}
