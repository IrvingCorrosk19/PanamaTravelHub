using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using PanamaTravelHub.Application.Exceptions;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Domain.Enums;
using PanamaTravelHub.Infrastructure.Data;
using PanamaTravelHub.Infrastructure.Repositories;

namespace PanamaTravelHub.Infrastructure.Services;

public class BookingService : IBookingService
{
    private readonly ApplicationDbContext _context;
    private readonly IRepository<Tour> _tourRepository;
    private readonly IRepository<Booking> _bookingRepository;
    private readonly ILogger<BookingService> _logger;

    public BookingService(
        ApplicationDbContext context,
        IRepository<Tour> tourRepository,
        IRepository<Booking> bookingRepository,
        ILogger<BookingService> logger)
    {
        _context = context;
        _tourRepository = tourRepository;
        _bookingRepository = bookingRepository;
        _logger = logger;
    }

    public async Task<Booking> CreateBookingAsync(
        Guid userId,
        Guid tourId,
        Guid? tourDateId,
        int numberOfParticipants,
        List<BookingParticipantInfo> participants,
        CancellationToken cancellationToken = default)
    {
               // Obtener tour
               var tour = await _tourRepository.GetByIdAsync(tourId, cancellationToken);
               if (tour == null)
                   throw new NotFoundException("Tour", tourId);

               if (!tour.IsActive)
                   throw new BusinessException("El tour no está activo", "TOUR_INACTIVE");

               // Verificar cupos disponibles
               var hasSpots = await ReserveSpotsAsync(tourId, tourDateId, numberOfParticipants, cancellationToken);
               if (!hasSpots)
               {
                   throw new BusinessException("No hay suficientes cupos disponibles para este tour", "INSUFFICIENT_SPOTS");
               }

        try
        {
            // Calcular total
            var totalAmount = tour.Price * numberOfParticipants;

            // Crear reserva
            var booking = new Booking
            {
                UserId = userId,
                TourId = tourId,
                TourDateId = tourDateId,
                NumberOfParticipants = numberOfParticipants,
                TotalAmount = totalAmount,
                Status = BookingStatus.Pending,
                ExpiresAt = DateTime.SpecifyKind(DateTime.UtcNow.AddHours(24), DateTimeKind.Utc) // Expira en 24 horas
            };

            await _bookingRepository.AddAsync(booking, cancellationToken);

            // Agregar participantes
            foreach (var participantInfo in participants)
            {
                var participant = new BookingParticipant
                {
                    BookingId = booking.Id,
                    FirstName = participantInfo.FirstName,
                    LastName = participantInfo.LastName,
                    Email = participantInfo.Email,
                    Phone = participantInfo.Phone,
                    DateOfBirth = participantInfo.DateOfBirth
                };
                _context.BookingParticipants.Add(participant);
            }

            await _context.SaveChangesAsync(cancellationToken);

            // Cargar relaciones
            await _context.Entry(booking)
                .Reference(b => b.Tour)
                .LoadAsync(cancellationToken);

            await _context.Entry(booking)
                .Reference(b => b.User)
                .LoadAsync(cancellationToken);

            _logger.LogInformation("Reserva creada exitosamente: {BookingId}", booking.Id);

            return booking;
        }
        catch
        {
            // Si falla, liberar cupos
            await ReleaseSpotsAsync(tourId, tourDateId, numberOfParticipants, cancellationToken);
            throw;
        }
    }

    public async Task<bool> ReserveSpotsAsync(
        Guid tourId,
        Guid? tourDateId,
        int participants,
        CancellationToken cancellationToken = default)
    {
        try
        {
            // Usar función SQL para reservar cupos de forma transaccional
            // Ejecutar función PostgreSQL que retorna boolean
            var result = await _context.Database
                .SqlQueryRaw<int>(
                    "SELECT CASE WHEN reserve_tour_spots({0}::uuid, {1}::uuid, {2}::integer) THEN 1 ELSE 0 END",
                    tourId,
                    tourDateId ?? (object)DBNull.Value,
                    participants)
                .FirstOrDefaultAsync(cancellationToken);

            return result == 1;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al reservar cupos para tour {TourId}", tourId);
            return false;
        }
    }

    public async Task ReleaseSpotsAsync(
        Guid tourId,
        Guid? tourDateId,
        int participants,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await _context.Database
                .ExecuteSqlRawAsync(
                    "SELECT release_tour_spots({0}::uuid, {1}::uuid, {2}::integer)",
                    tourId,
                    tourDateId ?? (object)DBNull.Value,
                    participants);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al liberar cupos para tour {TourId}", tourId);
        }
    }

    public async Task<Booking?> GetBookingByIdAsync(Guid bookingId, CancellationToken cancellationToken = default)
    {
        return await _context.Bookings
            .Include(b => b.Tour)
            .Include(b => b.User)
            .Include(b => b.TourDate)
            .Include(b => b.Participants)
            .Include(b => b.Payments)
            .FirstOrDefaultAsync(b => b.Id == bookingId, cancellationToken);
    }

    public async Task<IEnumerable<Booking>> GetUserBookingsAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        return await _context.Bookings
            .Include(b => b.Tour)
            .Include(b => b.TourDate)
            .Where(b => b.UserId == userId)
            .OrderByDescending(b => b.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<IEnumerable<Booking>> GetAllBookingsAsync(CancellationToken cancellationToken = default)
    {
        return await _context.Bookings
            .Include(b => b.Tour)
            .Include(b => b.User)
            .Include(b => b.TourDate)
            .OrderByDescending(b => b.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<bool> CancelBookingAsync(Guid bookingId, CancellationToken cancellationToken = default)
    {
        var booking = await GetBookingByIdAsync(bookingId, cancellationToken);
        if (booking == null)
            return false;

        if (booking.Status == BookingStatus.Cancelled || booking.Status == BookingStatus.Completed)
            return false;

        // Liberar cupos
        await ReleaseSpotsAsync(booking.TourId, booking.TourDateId, booking.NumberOfParticipants, cancellationToken);

        booking.Status = BookingStatus.Cancelled;
        await _bookingRepository.UpdateAsync(booking, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);

        return true;
    }

    public async Task<bool> ConfirmBookingAsync(Guid bookingId, CancellationToken cancellationToken = default)
    {
        var booking = await GetBookingByIdAsync(bookingId, cancellationToken);
        if (booking == null)
            return false;

        if (booking.Status != BookingStatus.Pending)
            return false;

        booking.Status = BookingStatus.Confirmed;
        booking.ExpiresAt = null; // Ya no expira
        await _bookingRepository.UpdateAsync(booking, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);

        return true;
    }
}

