using PanamaTravelHub.Domain.Enums;

namespace PanamaTravelHub.Domain.Entities;

public class Booking : BaseEntity
{
    public Guid UserId { get; set; }
    public Guid TourId { get; set; }
    public Guid? TourDateId { get; set; }
    public BookingStatus Status { get; set; } = BookingStatus.Pending;
    public int NumberOfParticipants { get; set; }
    public decimal TotalAmount { get; set; }
    public DateTime? ExpiresAt { get; set; }
    public string? Notes { get; set; }
    public Guid? CountryId { get; set; } // País desde el cual se realiza la reserva
    public bool AllowPartialPayments { get; set; } = false;
    public int PaymentPlanType { get; set; } = 0; // 0=Full, 1=Installments, 2=Partial

    // Navigation properties
    public User User { get; set; } = null!;
    public Tour Tour { get; set; } = null!;
    public TourDate? TourDate { get; set; }
    public Country? Country { get; set; }
    public ICollection<BookingParticipant> Participants { get; set; } = new List<BookingParticipant>();
    public ICollection<Payment> Payments { get; set; } = new List<Payment>();
}
