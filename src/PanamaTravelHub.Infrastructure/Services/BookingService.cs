using System.Runtime.CompilerServices;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using PanamaTravelHub.Application.Exceptions;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Domain.Enums;
using PanamaTravelHub.Infrastructure.Data;
using PanamaTravelHub.Infrastructure.Repositories;

namespace PanamaTravelHub.Infrastructure.Services;

// Clase simple para mapear el resultado de la función SQL
// IMPORTANTE: El alias en SQL debe ser en minúscula porque PostgreSQL es case-sensitive
internal class SqlResult
{
    public int result { get; set; } // minúscula para coincidir con PostgreSQL
}

public class BookingService : IBookingService
{
    private readonly ApplicationDbContext _context;
    private readonly IRepository<Tour> _tourRepository;
    private readonly IRepository<Booking> _bookingRepository;
    private readonly ILogger<BookingService> _logger;
    private readonly IEmailNotificationService _emailNotificationService;
    private readonly ISmsNotificationService _smsNotificationService;

    public BookingService(
        ApplicationDbContext context,
        IRepository<Tour> tourRepository,
        IRepository<Booking> bookingRepository,
        ILogger<BookingService> logger,
        IEmailNotificationService emailNotificationService,
        ISmsNotificationService smsNotificationService)
    {
        _context = context;
        _tourRepository = tourRepository;
        _bookingRepository = bookingRepository;
        _logger = logger;
        _emailNotificationService = emailNotificationService;
        _smsNotificationService = smsNotificationService;
    }

    public async Task<Booking> CreateBookingAsync(
        Guid userId,
        Guid tourId,
        Guid? tourDateId,
        int numberOfParticipants,
        List<BookingParticipantInfo> participants,
        Guid? countryId = null,
        CancellationToken cancellationToken = default)
    {
               // Obtener tour
               var tour = await _tourRepository.GetByIdAsync(tourId, cancellationToken);
               if (tour == null)
                   throw new NotFoundException("Tour", tourId);

               if (!tour.IsActive)
                   throw new BusinessException("El tour no está activo", "TOUR_INACTIVE");

               // Si hay tourDateId, validar que la fecha existe y tiene cupos
               if (tourDateId.HasValue)
               {
                   var tourDate = await _context.TourDates
                       .FirstOrDefaultAsync(td => td.Id == tourDateId.Value && td.TourId == tourId, cancellationToken);
                   
                   if (tourDate == null)
                   {
                       throw new NotFoundException("Fecha de tour", tourDateId.Value);
                   }
                   
                   if (!tourDate.IsActive)
                   {
                       throw new BusinessException("La fecha seleccionada no está activa", "TOUR_DATE_INACTIVE");
                   }
                   
                   if (tourDate.TourDateTime <= DateTime.UtcNow)
                   {
                       throw new BusinessException("La fecha seleccionada ya pasó", "TOUR_DATE_PAST");
                   }
                   
                   if (tourDate.AvailableSpots < numberOfParticipants)
                   {
                       throw new BusinessException(
                           $"Solo hay {tourDate.AvailableSpots} cupo(s) disponible(s) para esta fecha", 
                           "INSUFFICIENT_SPOTS");
                   }
               }

               // Verificar cupos disponibles
               _logger.LogInformation(
                   "Verificando cupos para tour {TourId}, tourDateId: {TourDateId}, participantes: {Participants}",
                   tourId, tourDateId?.ToString() ?? "null", numberOfParticipants);
               
               // Log de cupos actuales antes de reservar
               if (tourDateId.HasValue)
               {
                   var tourDate = await _context.TourDates
                       .FirstOrDefaultAsync(td => td.Id == tourDateId.Value, cancellationToken);
                   if (tourDate != null)
                   {
                       _logger.LogInformation(
                           "TourDate {TourDateId} tiene {AvailableSpots} cupos disponibles",
                           tourDateId.Value, tourDate.AvailableSpots);
                   }
               }
               else
               {
                   _logger.LogInformation(
                       "Tour {TourId} tiene {AvailableSpots} cupos disponibles (sin fecha específica)",
                       tourId, tour.AvailableSpots);
               }
               
               var hasSpots = await ReserveSpotsAsync(tourId, tourDateId, numberOfParticipants, cancellationToken);
               _logger.LogInformation(
                   "Resultado de ReserveSpotsAsync: {HasSpots} para tour {TourId}",
                   hasSpots, tourId);
               
               if (!hasSpots)
               {
                   throw new BusinessException("No hay suficientes cupos disponibles para este tour", "INSUFFICIENT_SPOTS");
               }

        try
        {
            // Calcular total
            var totalAmount = tour.Price * numberOfParticipants;

            // Validar que el país existe si se proporciona
            if (countryId.HasValue)
            {
                var country = await _context.Countries
                    .FirstOrDefaultAsync(c => c.Id == countryId.Value && c.IsActive, cancellationToken);
                if (country == null)
                {
                    throw new NotFoundException("País", countryId.Value);
                }
            }

            // Crear reserva
            var booking = new Booking
            {
                UserId = userId,
                TourId = tourId,
                TourDateId = tourDateId,
                NumberOfParticipants = numberOfParticipants,
                TotalAmount = totalAmount,
                Status = BookingStatus.Pending,
                CountryId = countryId,
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

            if (booking.TourDateId.HasValue)
            {
                await _context.Entry(booking)
                    .Reference(b => b.TourDate)
                    .LoadAsync(cancellationToken);
            }

            _logger.LogInformation("Reserva creada exitosamente: {BookingId}", booking.Id);

            // Enviar email de confirmación de reserva
            try
            {
                var tourDateStr = booking.TourDate?.TourDateTime.ToString("dd/MM/yyyy HH:mm") ?? "Por confirmar";
                var customerName = $"{booking.User.FirstName} {booking.User.LastName}";
                
                await _emailNotificationService.QueueTemplatedEmailAsync(
                    toEmail: booking.User.Email,
                    subject: $"Confirmación de Reserva - {booking.Tour.Name}",
                    templateName: "booking-confirmation",
                    templateData: new
                    {
                        CustomerName = customerName,
                        TourName = booking.Tour.Name,
                        TourDate = tourDateStr,
                        NumberOfParticipants = booking.NumberOfParticipants,
                        TotalAmount = booking.TotalAmount.ToString("C"),
                        BookingId = booking.Id.ToString(),
                        Year = DateTime.UtcNow.Year
                    },
                    type: EmailNotificationType.BookingConfirmation,
                    userId: booking.UserId,
                    bookingId: booking.Id
                );

                // Programar email de recordatorio 24 horas antes del tour
                if (booking.TourDate?.TourDateTime != null)
                {
                    var reminderTime = booking.TourDate.TourDateTime.AddHours(-24);
                    if (reminderTime > DateTime.UtcNow)
                    {
                        await _emailNotificationService.QueueTemplatedEmailAsync(
                            toEmail: booking.User.Email,
                            subject: $"Recordatorio: Tu tour {booking.Tour.Name} es mañana",
                            templateName: "booking-reminder",
                            templateData: new
                            {
                                CustomerName = customerName,
                                TourName = booking.Tour.Name,
                                TourDate = booking.TourDate.TourDateTime.ToString("dd/MM/yyyy HH:mm"),
                                Location = booking.Tour.Location ?? "Se confirmará por email",
                                NumberOfParticipants = booking.NumberOfParticipants,
                                Year = DateTime.UtcNow.Year
                            },
                            type: EmailNotificationType.BookingReminder,
                            userId: booking.UserId,
                            bookingId: booking.Id,
                            scheduledFor: reminderTime
                        );
                    }
                }
            }
            catch (Exception ex)
            {
                // No fallar la creación de la reserva si el email falla
                _logger.LogError(ex, "Error al enviar email de confirmación para reserva {BookingId}", booking.Id);
            }

            // Enviar SMS de confirmación de reserva
            try
            {
                // Intentar obtener teléfono del usuario primero
                var phoneNumber = booking.User.Phone;
                
                // Si el usuario no tiene teléfono, intentar obtener de los participantes
                if (string.IsNullOrWhiteSpace(phoneNumber))
                {
                    var firstParticipantWithPhone = booking.Participants
                        .FirstOrDefault(p => !string.IsNullOrWhiteSpace(p.Phone));
                    phoneNumber = firstParticipantWithPhone?.Phone;
                }

                if (!string.IsNullOrWhiteSpace(phoneNumber))
                {
                    var tourDateStr = booking.TourDate?.TourDateTime.ToString("dd/MM/yyyy HH:mm") ?? "Por confirmar";
                    await _smsNotificationService.SendTemplatedSmsAsync(
                        phoneNumber: phoneNumber,
                        templateName: "booking-confirmation",
                        templateData: new
                        {
                            BookingId = booking.Id.ToString(),
                            TourName = booking.Tour.Name,
                            TourDate = tourDateStr
                        },
                        type: SmsNotificationType.BookingConfirmation,
                        userId: booking.UserId,
                        bookingId: booking.Id,
                        cancellationToken: cancellationToken
                    );
                }
                else
                {
                    _logger.LogWarning("No se pudo enviar SMS de confirmación para reserva {BookingId}: no hay número de teléfono", booking.Id);
                }
            }
            catch (Exception ex)
            {
                // No fallar la creación de la reserva si el SMS falla
                _logger.LogError(ex, "Error al enviar SMS de confirmación para reserva {BookingId}", booking.Id);
            }

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
            _logger.LogInformation(
                "ReserveSpotsAsync: tourId={TourId}, tourDateId={TourDateId}, participants={Participants}",
                tourId, tourDateId?.ToString() ?? "NULL", participants);
            
            // Usar función SQL para reservar cupos de forma transaccional
            // Usar FromSqlRaw con una clase simple para mapear el resultado
            int result;
            
            if (tourDateId.HasValue)
            {
                // Usar alias en minúscula porque PostgreSQL es case-sensitive
                var sql = "SELECT CASE WHEN reserve_tour_spots({0}::uuid, {1}::uuid, {2}::integer) THEN 1 ELSE 0 END AS result";
                _logger.LogInformation("Ejecutando SQL con tourDateId: {Sql}",
                    sql);
                
                var sqlResult = await _context.Database
                    .SqlQueryRaw<SqlResult>(
                        sql,
                        tourId,
                        tourDateId.Value,
                        participants)
                    .FirstOrDefaultAsync(cancellationToken);
                
                result = sqlResult?.result ?? 0;
            }
            else
            {
                // Cuando tourDateId es NULL, usar NULL explícitamente en SQL
                // Usar alias en minúscula porque PostgreSQL es case-sensitive
                var sql = "SELECT CASE WHEN reserve_tour_spots({0}::uuid, NULL::uuid, {1}::integer) THEN 1 ELSE 0 END AS result";
                _logger.LogInformation("Ejecutando SQL sin tourDateId (NULL): {Sql} con tourId={TourId}, participants={Participants}",
                    sql, tourId, participants);
                
                // Verificar cupos ANTES de ejecutar la función
                var tourBefore = await _context.Tours
                    .AsNoTracking()
                    .FirstOrDefaultAsync(t => t.Id == tourId, cancellationToken);
                if (tourBefore != null)
                {
                    _logger.LogInformation(
                        "Cupos disponibles ANTES de ReserveSpotsAsync: {AvailableSpots}",
                        tourBefore.AvailableSpots);
                }
                
                var sqlResult = await _context.Database
                    .SqlQueryRaw<SqlResult>(
                        sql,
                        tourId,
                        participants)
                    .FirstOrDefaultAsync(cancellationToken);
                
                _logger.LogInformation(
                    "SqlResult obtenido: {SqlResult}, result property: {Result}",
                    sqlResult != null ? "not null" : "null",
                    sqlResult?.result ?? -1);
                
                result = sqlResult?.result ?? 0;
                
                // Verificar cupos DESPUÉS de ejecutar la función
                var tourAfter = await _context.Tours
                    .AsNoTracking()
                    .FirstOrDefaultAsync(t => t.Id == tourId, cancellationToken);
                if (tourAfter != null)
                {
                    _logger.LogInformation(
                        "Cupos disponibles DESPUÉS de ReserveSpotsAsync: {AvailableSpots} (cambió: {Changed})",
                        tourAfter.AvailableSpots,
                        tourBefore != null ? (tourBefore.AvailableSpots != tourAfter.AvailableSpots) : false);
                }
            }

            _logger.LogInformation(
                "ReserveSpotsAsync resultado: {Result} (1=éxito, 0=fallo) para tour {TourId}",
                result, tourId);

            return result == 1;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al reservar cupos para tour {TourId}, tourDateId: {TourDateId}, participants: {Participants}",
                tourId, tourDateId?.ToString() ?? "NULL", participants);
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
        // Cargar bookings con todas las relaciones necesarias
        // Usar consulta normal en lugar de split query para evitar problemas con relaciones opcionales
        return await _context.Bookings
            .Include(b => b.Tour)
            .Include(b => b.User)
            .Include(b => b.TourDate)
            .Include(b => b.Country)
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

        // Enviar email de cancelación
        try
        {
            await _context.Entry(booking)
                .Reference(b => b.User)
                .LoadAsync(cancellationToken);
            await _context.Entry(booking)
                .Reference(b => b.Tour)
                .LoadAsync(cancellationToken);
            if (booking.TourDateId.HasValue)
            {
                await _context.Entry(booking)
                    .Reference(b => b.TourDate)
                    .LoadAsync(cancellationToken);
            }

            var customerName = $"{booking.User.FirstName} {booking.User.LastName}";
            var tourDateStr = booking.TourDate?.TourDateTime.ToString("dd/MM/yyyy HH:mm") ?? "N/A";
            
            await _emailNotificationService.QueueTemplatedEmailAsync(
                toEmail: booking.User.Email,
                subject: $"Cancelación de Reserva - {booking.Tour.Name}",
                templateName: "booking-cancellation",
                templateData: new
                {
                    CustomerName = customerName,
                    TourName = booking.Tour.Name,
                    TourDate = tourDateStr,
                    BookingId = booking.Id.ToString(),
                    CancellationDate = DateTime.UtcNow.ToString("dd/MM/yyyy HH:mm"),
                    Year = DateTime.UtcNow.Year
                },
                type: EmailNotificationType.BookingCancellation,
                userId: booking.UserId,
                bookingId: booking.Id
            );

            // Enviar SMS de cancelación
            var phoneNumber = booking.User.Phone;
            if (string.IsNullOrWhiteSpace(phoneNumber))
            {
                var firstParticipantWithPhone = booking.Participants
                    .FirstOrDefault(p => !string.IsNullOrWhiteSpace(p.Phone));
                phoneNumber = firstParticipantWithPhone?.Phone;
            }

            if (!string.IsNullOrWhiteSpace(phoneNumber))
            {
                await _smsNotificationService.SendTemplatedSmsAsync(
                    phoneNumber: phoneNumber,
                    templateName: "booking-cancellation",
                    templateData: new
                    {
                        TourName = booking.Tour.Name
                    },
                    type: SmsNotificationType.BookingCancellation,
                    userId: booking.UserId,
                    bookingId: booking.Id,
                    cancellationToken: cancellationToken
                );
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al enviar notificaciones de cancelación para reserva {BookingId}", bookingId);
        }

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

        // Re-enviar email de confirmación cuando se confirma la reserva
        try
        {
            await _context.Entry(booking)
                .Reference(b => b.User)
                .LoadAsync(cancellationToken);
            await _context.Entry(booking)
                .Reference(b => b.Tour)
                .LoadAsync(cancellationToken);
            if (booking.TourDateId.HasValue)
            {
                await _context.Entry(booking)
                    .Reference(b => b.TourDate)
                    .LoadAsync(cancellationToken);
            }

            var tourDateStr = booking.TourDate?.TourDateTime.ToString("dd/MM/yyyy HH:mm") ?? "Por confirmar";
            var customerName = $"{booking.User.FirstName} {booking.User.LastName}";
            
            await _emailNotificationService.QueueTemplatedEmailAsync(
                toEmail: booking.User.Email,
                subject: $"Reserva Confirmada - {booking.Tour.Name}",
                templateName: "booking-confirmation",
                templateData: new
                {
                    CustomerName = customerName,
                    TourName = booking.Tour.Name,
                    TourDate = tourDateStr,
                    NumberOfParticipants = booking.NumberOfParticipants,
                    TotalAmount = booking.TotalAmount.ToString("C"),
                    BookingId = booking.Id.ToString(),
                    Year = DateTime.UtcNow.Year
                },
                type: EmailNotificationType.BookingConfirmation,
                userId: booking.UserId,
                bookingId: booking.Id
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al enviar email de confirmación para reserva {BookingId}", bookingId);
        }

        return true;
    }
}

