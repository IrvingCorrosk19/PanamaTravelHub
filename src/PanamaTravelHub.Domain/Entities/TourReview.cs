namespace PanamaTravelHub.Domain.Entities;

public class TourReview : BaseEntity
{
    public Guid TourId { get; set; }
    public Guid UserId { get; set; }
    public Guid? BookingId { get; set; } // Opcional: relacionar con reserva específica
    
    public int Rating { get; set; } // 1-5 estrellas
    public string? Title { get; set; }
    public string? Comment { get; set; }
    
    public bool IsApproved { get; set; } = false; // Moderación
    public bool IsVerified { get; set; } = false; // Verificado si tiene booking
    
    // Navigation properties
    public Tour Tour { get; set; } = null!;
    public User User { get; set; } = null!;
    public Booking? Booking { get; set; }
}
