using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class PasswordResetTokenConfiguration : IEntityTypeConfiguration<PasswordResetToken>
{
    public void Configure(EntityTypeBuilder<PasswordResetToken> builder)
    {
        builder.ToTable("password_reset_tokens");

        builder.HasKey(prt => prt.Id);
        builder.Property(prt => prt.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(prt => prt.UserId)
            .HasColumnName("user_id")
            .IsRequired();

        builder.Property(prt => prt.Token)
            .HasColumnName("token")
            .HasMaxLength(500)
            .IsRequired();

        builder.Property(prt => prt.ExpiresAt)
            .HasColumnName("expires_at")
            .IsRequired()
            .HasConversion(
                v => DateTime.SpecifyKind(v, DateTimeKind.Utc),
                v => DateTime.SpecifyKind(v, DateTimeKind.Utc));

        builder.Property(prt => prt.IsUsed)
            .HasColumnName("is_used")
            .HasDefaultValue(false)
            .IsRequired();

        builder.Property(prt => prt.UsedAt)
            .HasColumnName("used_at")
            .HasConversion(
                v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : (DateTime?)null,
                v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : (DateTime?)null);

        builder.Property(prt => prt.IpAddress)
            .HasColumnName("ip_address")
            .HasMaxLength(45); // IPv6 max length

        builder.Property(prt => prt.UserAgent)
            .HasColumnName("user_agent")
            .HasMaxLength(500);

        builder.Property(prt => prt.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        builder.Property(prt => prt.UpdatedAt)
            .HasColumnName("updated_at");

        // Índices
        builder.HasIndex(prt => prt.UserId)
            .HasDatabaseName("idx_password_reset_tokens_user_id");

        builder.HasIndex(prt => prt.Token)
            .HasDatabaseName("idx_password_reset_tokens_token")
            .IsUnique();

        builder.HasIndex(prt => new { prt.Token, prt.IsUsed, prt.ExpiresAt })
            .HasDatabaseName("idx_password_reset_tokens_valid");

        // Relaciones
        builder.HasOne(prt => prt.User)
            .WithMany()
            .HasForeignKey(prt => prt.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
