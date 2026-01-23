using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class CouponUsageConfiguration : IEntityTypeConfiguration<CouponUsage>
{
    public void Configure(EntityTypeBuilder<CouponUsage> builder)
    {
        builder.ToTable("coupon_usages");

        builder.HasKey(cu => cu.Id);
        builder.Property(cu => cu.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(cu => cu.CouponId)
            .HasColumnName("coupon_id")
            .IsRequired();

        builder.Property(cu => cu.UserId)
            .HasColumnName("user_id")
            .IsRequired();

        builder.Property(cu => cu.BookingId)
            .HasColumnName("booking_id")
            .IsRequired();

        builder.Property(cu => cu.DiscountAmount)
            .HasColumnName("discount_amount")
            .HasColumnType("decimal(18,2)")
            .IsRequired();

        builder.Property(cu => cu.OriginalAmount)
            .HasColumnName("original_amount")
            .HasColumnType("decimal(18,2)")
            .IsRequired();

        builder.Property(cu => cu.FinalAmount)
            .HasColumnName("final_amount")
            .HasColumnType("decimal(18,2)")
            .IsRequired();

        builder.Property(cu => cu.CreatedAt)
            .HasColumnName("created_at")
            .IsRequired()
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        builder.Property(cu => cu.UpdatedAt)
            .HasColumnName("updated_at");

        // Relationships
        builder.HasOne(cu => cu.Coupon)
            .WithMany(c => c.Usages)
            .HasForeignKey(cu => cu.CouponId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(cu => cu.User)
            .WithMany()
            .HasForeignKey(cu => cu.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(cu => cu.Booking)
            .WithMany()
            .HasForeignKey(cu => cu.BookingId)
            .OnDelete(DeleteBehavior.Cascade);

        // Indexes
        builder.HasIndex(cu => cu.CouponId);
        builder.HasIndex(cu => cu.UserId);
        builder.HasIndex(cu => cu.BookingId);
        builder.HasIndex(cu => new { cu.CouponId, cu.UserId });
    }
}
