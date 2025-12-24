using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class RefreshTokenConfiguration : IEntityTypeConfiguration<RefreshToken>
{
    public void Configure(EntityTypeBuilder<RefreshToken> builder)
    {
        builder.ToTable("refresh_tokens");

        builder.HasKey(rt => rt.Id);
        builder.Property(rt => rt.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(rt => rt.UserId)
            .HasColumnName("user_id")
            .IsRequired();

        builder.Property(rt => rt.Token)
            .HasColumnName("token")
            .HasMaxLength(500)
            .IsRequired();

        builder.Property(rt => rt.ExpiresAt)
            .HasColumnName("expires_at")
            .IsRequired()
            .HasConversion(
                v => DateTime.SpecifyKind(v, DateTimeKind.Utc),
                v => DateTime.SpecifyKind(v, DateTimeKind.Utc));

        builder.Property(rt => rt.IsRevoked)
            .HasColumnName("is_revoked")
            .HasDefaultValue(false)
            .IsRequired();

        builder.Property(rt => rt.RevokedAt)
            .HasColumnName("revoked_at")
            .HasConversion(
                v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : (DateTime?)null,
                v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : (DateTime?)null);

        builder.Property(rt => rt.ReplacedByToken)
            .HasColumnName("replaced_by_token")
            .HasMaxLength(500);

        builder.Property(rt => rt.IpAddress)
            .HasColumnName("ip_address")
            .HasMaxLength(45); // IPv6 max length

        builder.Property(rt => rt.UserAgent)
            .HasColumnName("user_agent")
            .HasMaxLength(500);

        builder.Property(rt => rt.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        builder.Property(rt => rt.UpdatedAt)
            .HasColumnName("updated_at");

        // Índices
        builder.HasIndex(rt => rt.UserId)
            .HasDatabaseName("idx_refresh_tokens_user_id");

        builder.HasIndex(rt => rt.Token)
            .HasDatabaseName("idx_refresh_tokens_token")
            .IsUnique();

        builder.HasIndex(rt => new { rt.UserId, rt.IsRevoked, rt.ExpiresAt })
            .HasDatabaseName("idx_refresh_tokens_user_active");

        // Relaciones - Configuración explícita para evitar ambigüedad
        builder.HasOne(rt => rt.User)
            .WithMany(u => u.RefreshTokens)
            .HasForeignKey(rt => rt.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

