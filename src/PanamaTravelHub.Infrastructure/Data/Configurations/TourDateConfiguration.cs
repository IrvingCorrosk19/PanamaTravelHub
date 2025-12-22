using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class TourDateConfiguration : IEntityTypeConfiguration<TourDate>
{
    public void Configure(EntityTypeBuilder<TourDate> builder)
    {
        builder.ToTable("tour_dates");

        builder.HasKey(td => td.Id);
        builder.Property(td => td.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(td => td.TourId)
            .HasColumnName("tour_id")
            .IsRequired();

        builder.Property(td => td.TourDateTime)
            .HasColumnName("tour_date_time")
            .IsRequired();

        builder.Property(td => td.AvailableSpots)
            .HasColumnName("available_spots")
            .HasDefaultValue(0)
            .IsRequired();

        builder.Property(td => td.IsActive)
            .HasColumnName("is_active")
            .HasDefaultValue(true)
            .IsRequired();

        builder.Property(td => td.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        builder.Property(td => td.UpdatedAt)
            .HasColumnName("updated_at");

        // Índices
        builder.HasIndex(td => td.TourId)
            .HasDatabaseName("idx_tour_dates_tour_id");

        builder.HasIndex(td => td.TourDateTime)
            .HasDatabaseName("idx_tour_dates_tour_date_time");

        // Relaciones
        builder.HasMany(td => td.Bookings)
            .WithOne(b => b.TourDate)
            .HasForeignKey(b => b.TourDateId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
