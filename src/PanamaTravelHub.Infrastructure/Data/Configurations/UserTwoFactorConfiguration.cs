using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class UserTwoFactorConfiguration : IEntityTypeConfiguration<UserTwoFactor>
{
    public void Configure(EntityTypeBuilder<UserTwoFactor> builder)
    {
        builder.ToTable("user_two_factor");

        builder.HasKey(ut => ut.Id);
        builder.Property(ut => ut.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(ut => ut.UserId)
            .HasColumnName("user_id")
            .IsRequired();

        builder.Property(ut => ut.SecretKey)
            .HasColumnName("secret_key")
            .HasMaxLength(100);

        builder.Property(ut => ut.IsEnabled)
            .HasColumnName("is_enabled")
            .HasDefaultValue(false)
            .IsRequired();

        builder.Property(ut => ut.BackupCodes)
            .HasColumnName("backup_codes")
            .HasMaxLength(2000); // JSON array

        builder.Property(ut => ut.PhoneNumber)
            .HasColumnName("phone_number")
            .HasMaxLength(20);

        builder.Property(ut => ut.IsSmsEnabled)
            .HasColumnName("is_sms_enabled")
            .HasDefaultValue(false)
            .IsRequired();

        builder.Property(ut => ut.EnabledAt)
            .HasColumnName("enabled_at");

        builder.Property(ut => ut.LastUsedAt)
            .HasColumnName("last_used_at");

        builder.Property(ut => ut.CreatedAt)
            .HasColumnName("created_at")
            .IsRequired()
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        builder.Property(ut => ut.UpdatedAt)
            .HasColumnName("updated_at");

        // Relationships
        builder.HasOne(ut => ut.User)
            .WithOne()
            .HasForeignKey<UserTwoFactor>(ut => ut.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        // Indexes
        builder.HasIndex(ut => ut.UserId).IsUnique();
        builder.HasIndex(ut => ut.IsEnabled);
    }
}
