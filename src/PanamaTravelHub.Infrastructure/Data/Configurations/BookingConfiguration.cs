using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Domain.Enums;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class BookingConfiguration : IEntityTypeConfiguration<Booking>
{
    public void Configure(EntityTypeBuilder<Booking> builder)
    {
        builder.ToTable("bookings");

        builder.HasKey(b => b.Id);
        builder.Property(b => b.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(b => b.UserId)
            .HasColumnName("user_id")
            .IsRequired();

        builder.Property(b => b.TourId)
            .HasColumnName("tour_id")
            .IsRequired();

        builder.Property(b => b.TourDateId)
            .HasColumnName("tour_date_id");

        builder.Property(b => b.Status)
            .HasColumnName("status")
            .HasConversion<int>()
            .HasDefaultValue(BookingStatus.Pending)
            .IsRequired();

        builder.Property(b => b.NumberOfParticipants)
            .HasColumnName("number_of_participants")
            .IsRequired();

        builder.Property(b => b.TotalAmount)
            .HasColumnName("total_amount")
            .HasColumnType("decimal(10,2)")
            .IsRequired();

        builder.Property(b => b.ExpiresAt)
            .HasColumnName("expires_at");

        builder.Property(b => b.Notes)
            .HasColumnName("notes");

        builder.Property(b => b.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        builder.Property(b => b.UpdatedAt)
            .HasColumnName("updated_at");

        // Índices
        builder.HasIndex(b => b.UserId)
            .HasDatabaseName("idx_bookings_user_id");

        builder.HasIndex(b => b.TourId)
            .HasDatabaseName("idx_bookings_tour_id");

        builder.HasIndex(b => b.Status)
            .HasDatabaseName("idx_bookings_status");

        builder.HasIndex(b => b.CreatedAt)
            .HasDatabaseName("idx_bookings_created_at");

        builder.HasIndex(b => new { b.UserId, b.Status })
            .HasDatabaseName("idx_bookings_user_status");

        // Relaciones
        builder.HasMany(b => b.Participants)
            .WithOne(bp => bp.Booking)
            .HasForeignKey(bp => bp.BookingId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(b => b.Payments)
            .WithOne(p => p.Booking)
            .HasForeignKey(p => p.BookingId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
