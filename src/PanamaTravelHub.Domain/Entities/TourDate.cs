namespace PanamaTravelHub.Domain.Entities;

public class TourDate : BaseEntity
{
    public Guid TourId { get; set; }
    public DateTime TourDateTime { get; set; }
    public int AvailableSpots { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation properties
    public Tour Tour { get; set; } = null!;
    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
}
