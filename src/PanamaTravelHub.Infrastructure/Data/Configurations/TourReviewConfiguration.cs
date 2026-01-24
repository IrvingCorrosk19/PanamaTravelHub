using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class TourReviewConfiguration : IEntityTypeConfiguration<TourReview>
{
    public void Configure(EntityTypeBuilder<TourReview> builder)
    {
        builder.ToTable("tour_reviews");

        builder.HasKey(tr => tr.Id);
        builder.Property(tr => tr.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(tr => tr.TourId)
            .HasColumnName("tour_id")
            .IsRequired();

        builder.Property(tr => tr.UserId)
            .HasColumnName("user_id")
            .IsRequired();

        builder.Property(tr => tr.BookingId)
            .HasColumnName("booking_id");

        builder.Property(tr => tr.Rating)
            .HasColumnName("rating")
            .IsRequired();

        builder.Property(tr => tr.Title)
            .HasColumnName("title")
            .HasMaxLength(200);

        builder.Property(tr => tr.Comment)
            .HasColumnName("comment")
            .HasMaxLength(2000);

        builder.Property(tr => tr.IsApproved)
            .HasColumnName("is_approved")
            .HasDefaultValue(false)
            .IsRequired();

        builder.Property(tr => tr.IsVerified)
            .HasColumnName("is_verified")
            .HasDefaultValue(false)
            .IsRequired();

        builder.Property(tr => tr.CreatedAt)
            .HasColumnName("created_at")
            .IsRequired()
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        builder.Property(tr => tr.UpdatedAt)
            .HasColumnName("updated_at");

        // Relationships
        builder.HasOne(tr => tr.Tour)
            .WithMany(t => t.Reviews)
            .HasForeignKey(tr => tr.TourId)
            .OnDelete(DeleteBehavior.Cascade)
            .IsRequired();

        builder.HasOne(tr => tr.User)
            .WithMany()
            .HasForeignKey(tr => tr.UserId)
            .OnDelete(DeleteBehavior.Cascade)
            .IsRequired();

        builder.HasOne(tr => tr.Booking)
            .WithMany()
            .HasForeignKey(tr => tr.BookingId)
            .OnDelete(DeleteBehavior.SetNull);

        // Constraints
        builder.HasCheckConstraint("chk_rating_range", "rating >= 1 AND rating <= 5");

        // Indexes
        builder.HasIndex(tr => tr.TourId);
        builder.HasIndex(tr => tr.UserId);
        builder.HasIndex(tr => new { tr.TourId, tr.UserId }).IsUnique(); // Un usuario solo puede dejar una reseña por tour
        builder.HasIndex(tr => tr.IsApproved);
        builder.HasIndex(tr => tr.Rating);
    }
}
