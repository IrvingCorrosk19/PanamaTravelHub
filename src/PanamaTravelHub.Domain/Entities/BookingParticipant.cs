namespace PanamaTravelHub.Domain.Entities;

public class BookingParticipant : BaseEntity
{
    public Guid BookingId { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? Email { get; set; }
    public string? Phone { get; set; }
    public DateTime? DateOfBirth { get; set; }
    public string? SpecialRequirements { get; set; }

    // Navigation properties
    public Booking Booking { get; set; } = null!;
}
