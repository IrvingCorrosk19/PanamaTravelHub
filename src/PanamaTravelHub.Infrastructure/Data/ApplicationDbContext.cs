using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.DataProtection.EntityFrameworkCore;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data;

public class ApplicationDbContext : DbContext, IDataProtectionKeyContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    // DbSets
    public DbSet<User> Users { get; set; }
    public DbSet<Role> Roles { get; set; }
    public DbSet<UserRole> UserRoles { get; set; }
    public DbSet<Tour> Tours { get; set; }
    public DbSet<TourImage> TourImages { get; set; }
    public DbSet<TourDate> TourDates { get; set; }
    public DbSet<Booking> Bookings { get; set; }
    public DbSet<BookingParticipant> BookingParticipants { get; set; }
    public DbSet<Payment> Payments { get; set; }
    public DbSet<EmailNotification> EmailNotifications { get; set; }
    public DbSet<AuditLog> AuditLogs { get; set; }
    public DbSet<HomePageContent> HomePageContent { get; set; }
    public DbSet<RefreshToken> RefreshTokens { get; set; }
    public DbSet<PasswordResetToken> PasswordResetTokens { get; set; }
    public DbSet<MediaFile> MediaFiles { get; set; }
    public DbSet<Page> Pages { get; set; }
    public DbSet<Country> Countries { get; set; }
    public DbSet<SmsNotification> SmsNotifications { get; set; }
    public DbSet<TourReview> TourReviews { get; set; }
    public DbSet<Coupon> Coupons { get; set; }
    public DbSet<CouponUsage> CouponUsages { get; set; }
    public DbSet<Waitlist> Waitlist { get; set; }
    public DbSet<UserFavorite> UserFavorites { get; set; }
    public DbSet<UserTwoFactor> UserTwoFactors { get; set; }
    public DbSet<LoginHistory> LoginHistories { get; set; }
    public DbSet<BlogComment> BlogComments { get; set; }
    public DbSet<TourCategory> TourCategories { get; set; }
    public DbSet<TourTag> TourTags { get; set; }
    public DbSet<TourCategoryAssignment> TourCategoryAssignments { get; set; }
    public DbSet<TourTagAssignment> TourTagAssignments { get; set; }
    public DbSet<AnalyticsEvent> AnalyticsEvents { get; set; }
    public DbSet<Invoice> Invoices { get; set; }
    public DbSet<InvoiceSequence> InvoiceSequences { get; set; }
    
    // Data Protection Keys (para persistencia en PostgreSQL)
    public DbSet<DataProtectionKey> DataProtectionKeys { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Aplicar todas las configuraciones
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
    }
}
