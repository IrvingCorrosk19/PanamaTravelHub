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

    // Navigation properties
    public ICollection<TourImage> TourImages { get; set; } = new List<TourImage>();
    public ICollection<TourDate> TourDates { get; set; } = new List<TourDate>();
    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
}
