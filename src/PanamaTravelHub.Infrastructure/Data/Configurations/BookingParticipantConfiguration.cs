using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class BookingParticipantConfiguration : IEntityTypeConfiguration<BookingParticipant>
{
    public void Configure(EntityTypeBuilder<BookingParticipant> builder)
    {
        builder.ToTable("booking_participants");

        builder.HasKey(bp => bp.Id);
        builder.Property(bp => bp.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(bp => bp.BookingId)
            .HasColumnName("booking_id")
            .IsRequired();

        builder.Property(bp => bp.FirstName)
            .HasColumnName("first_name")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(bp => bp.LastName)
            .HasColumnName("last_name")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(bp => bp.Email)
            .HasColumnName("email")
            .HasMaxLength(255);

        builder.Property(bp => bp.Phone)
            .HasColumnName("phone")
            .HasMaxLength(20);

        builder.Property(bp => bp.DateOfBirth)
            .HasColumnName("date_of_birth");

        builder.Property(bp => bp.SpecialRequirements)
            .HasColumnName("special_requirements");

        builder.Property(bp => bp.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        builder.Property(bp => bp.UpdatedAt)
            .HasColumnName("updated_at");

        // Índices
        builder.HasIndex(bp => bp.BookingId)
            .HasDatabaseName("idx_booking_participants_booking_id");
    }
}
