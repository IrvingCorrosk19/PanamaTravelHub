using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class TourConfiguration : IEntityTypeConfiguration<Tour>
{
    public void Configure(EntityTypeBuilder<Tour> builder)
    {
        builder.ToTable("tours");

        builder.HasKey(t => t.Id);
        builder.Property(t => t.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(t => t.Name)
            .HasColumnName("name")
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(t => t.Description)
            .HasColumnName("description")
            .IsRequired();

        builder.Property(t => t.Itinerary)
            .HasColumnName("itinerary");

        builder.Property(t => t.Price)
            .HasColumnName("price")
            .HasColumnType("decimal(10,2)")
            .IsRequired();

        builder.Property(t => t.MaxCapacity)
            .HasColumnName("max_capacity")
            .IsRequired();

        builder.Property(t => t.DurationHours)
            .HasColumnName("duration_hours")
            .IsRequired();

        builder.Property(t => t.Location)
            .HasColumnName("location")
            .HasMaxLength(200);

        builder.Property(t => t.IsActive)
            .HasColumnName("is_active")
            .HasDefaultValue(true)
            .IsRequired();

        builder.Property(t => t.AvailableSpots)
            .HasColumnName("available_spots")
            .HasDefaultValue(0)
            .IsRequired();

        builder.Property(t => t.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        builder.Property(t => t.UpdatedAt)
            .HasColumnName("updated_at");

        // Índices
        builder.HasIndex(t => t.IsActive)
            .HasDatabaseName("idx_tours_is_active");

        builder.HasIndex(t => t.Name)
            .HasDatabaseName("idx_tours_name");

        // Relaciones
        builder.HasMany(t => t.TourImages)
            .WithOne(ti => ti.Tour)
            .HasForeignKey(ti => ti.TourId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(t => t.TourDates)
            .WithOne(td => td.Tour)
            .HasForeignKey(td => td.TourId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(t => t.Bookings)
            .WithOne(b => b.Tour)
            .HasForeignKey(b => b.TourId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
