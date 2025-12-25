using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Application.Services;

public interface IBookingService
{
    Task<Booking> CreateBookingAsync(
        Guid userId,
        Guid tourId,
        Guid? tourDateId,
        int numberOfParticipants,
        List<BookingParticipantInfo> participants,
        Guid? countryId = null,
        CancellationToken cancellationToken = default);

    Task<bool> ReserveSpotsAsync(
        Guid tourId,
        Guid? tourDateId,
        int participants,
        CancellationToken cancellationToken = default);

    Task ReleaseSpotsAsync(
        Guid tourId,
        Guid? tourDateId,
        int participants,
        CancellationToken cancellationToken = default);

    Task<Booking?> GetBookingByIdAsync(Guid bookingId, CancellationToken cancellationToken = default);
    Task<IEnumerable<Booking>> GetUserBookingsAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<IEnumerable<Booking>> GetAllBookingsAsync(CancellationToken cancellationToken = default);
    Task<bool> CancelBookingAsync(Guid bookingId, CancellationToken cancellationToken = default);
    Task<bool> ConfirmBookingAsync(Guid bookingId, CancellationToken cancellationToken = default);
}

public class BookingParticipantInfo
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? Email { get; set; }
    public string? Phone { get; set; }
    public DateTime? DateOfBirth { get; set; }
}

