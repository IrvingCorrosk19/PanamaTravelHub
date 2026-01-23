using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class WaitlistConfiguration : IEntityTypeConfiguration<Waitlist>
{
    public void Configure(EntityTypeBuilder<Waitlist> builder)
    {
        builder.ToTable("waitlist");

        builder.HasKey(w => w.Id);
        builder.Property(w => w.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(w => w.TourId)
            .HasColumnName("tour_id")
            .IsRequired();

        builder.Property(w => w.TourDateId)
            .HasColumnName("tour_date_id");

        builder.Property(w => w.UserId)
            .HasColumnName("user_id")
            .IsRequired();

        builder.Property(w => w.NumberOfParticipants)
            .HasColumnName("number_of_participants")
            .IsRequired();

        builder.Property(w => w.IsNotified)
            .HasColumnName("is_notified")
            .HasDefaultValue(false)
            .IsRequired();

        builder.Property(w => w.NotifiedAt)
            .HasColumnName("notified_at");

        builder.Property(w => w.IsActive)
            .HasColumnName("is_active")
            .HasDefaultValue(true)
            .IsRequired();

        builder.Property(w => w.Priority)
            .HasColumnName("priority")
            .IsRequired();

        builder.Property(w => w.CreatedAt)
            .HasColumnName("created_at")
            .IsRequired()
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        builder.Property(w => w.UpdatedAt)
            .HasColumnName("updated_at");

        // Relationships
        builder.HasOne(w => w.Tour)
            .WithMany()
            .HasForeignKey(w => w.TourId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(w => w.TourDate)
            .WithMany()
            .HasForeignKey(w => w.TourDateId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(w => w.User)
            .WithMany()
            .HasForeignKey(w => w.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        // Constraints
        builder.HasCheckConstraint("chk_participants_positive", "number_of_participants > 0");
        builder.HasCheckConstraint("chk_priority_positive", "priority >= 0");

        // Indexes
        builder.HasIndex(w => w.TourId);
        builder.HasIndex(w => w.TourDateId);
        builder.HasIndex(w => w.UserId);
        builder.HasIndex(w => w.IsActive);
        builder.HasIndex(w => w.IsNotified);
        builder.HasIndex(w => new { w.TourId, w.TourDateId, w.IsActive, w.Priority });
    }
}
