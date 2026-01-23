using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class CouponConfiguration : IEntityTypeConfiguration<Coupon>
{
    public void Configure(EntityTypeBuilder<Coupon> builder)
    {
        builder.ToTable("coupons");

        builder.HasKey(c => c.Id);
        builder.Property(c => c.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(c => c.Code)
            .HasColumnName("code")
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(c => c.Description)
            .HasColumnName("description")
            .HasMaxLength(500)
            .IsRequired();

        builder.Property(c => c.DiscountType)
            .HasColumnName("discount_type")
            .HasConversion<int>()
            .IsRequired();

        builder.Property(c => c.DiscountValue)
            .HasColumnName("discount_value")
            .HasColumnType("decimal(18,2)")
            .IsRequired();

        builder.Property(c => c.MinimumPurchaseAmount)
            .HasColumnName("minimum_purchase_amount")
            .HasColumnType("decimal(18,2)");

        builder.Property(c => c.MaximumDiscountAmount)
            .HasColumnName("maximum_discount_amount")
            .HasColumnType("decimal(18,2)");

        builder.Property(c => c.ValidFrom)
            .HasColumnName("valid_from");

        builder.Property(c => c.ValidUntil)
            .HasColumnName("valid_until");

        builder.Property(c => c.MaxUses)
            .HasColumnName("max_uses");

        builder.Property(c => c.MaxUsesPerUser)
            .HasColumnName("max_uses_per_user");

        builder.Property(c => c.CurrentUses)
            .HasColumnName("current_uses")
            .HasDefaultValue(0)
            .IsRequired();

        builder.Property(c => c.IsActive)
            .HasColumnName("is_active")
            .HasDefaultValue(true)
            .IsRequired();

        builder.Property(c => c.IsFirstTimeOnly)
            .HasColumnName("is_first_time_only")
            .HasDefaultValue(false)
            .IsRequired();

        builder.Property(c => c.ApplicableTourId)
            .HasColumnName("applicable_tour_id");

        builder.Property(c => c.CreatedAt)
            .HasColumnName("created_at")
            .IsRequired()
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        builder.Property(c => c.UpdatedAt)
            .HasColumnName("updated_at");

        // Relationships
        builder.HasOne(c => c.ApplicableTour)
            .WithMany()
            .HasForeignKey(c => c.ApplicableTourId)
            .OnDelete(DeleteBehavior.SetNull);

        // Constraints
        builder.HasCheckConstraint("chk_discount_value_positive", "discount_value > 0");
        builder.HasCheckConstraint("chk_max_uses_positive", "max_uses IS NULL OR max_uses > 0");
        builder.HasCheckConstraint("chk_max_uses_per_user_positive", "max_uses_per_user IS NULL OR max_uses_per_user > 0");
        builder.HasCheckConstraint("chk_current_uses_non_negative", "current_uses >= 0");
        builder.HasCheckConstraint("chk_percentage_range", "discount_type != 1 OR (discount_value >= 0 AND discount_value <= 100)");

        // Indexes
        builder.HasIndex(c => c.Code).IsUnique();
        builder.HasIndex(c => c.IsActive);
        builder.HasIndex(c => c.ValidFrom);
        builder.HasIndex(c => c.ValidUntil);
    }
}
