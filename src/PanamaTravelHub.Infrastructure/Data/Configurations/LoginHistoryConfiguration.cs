using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class LoginHistoryConfiguration : IEntityTypeConfiguration<LoginHistory>
{
    public void Configure(EntityTypeBuilder<LoginHistory> builder)
    {
        builder.ToTable("login_history");

        builder.HasKey(lh => lh.Id);
        builder.Property(lh => lh.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(lh => lh.UserId)
            .HasColumnName("user_id")
            .IsRequired();

        builder.Property(lh => lh.IpAddress)
            .HasColumnName("ip_address")
            .HasMaxLength(45) // IPv6 compatible
            .IsRequired();

        builder.Property(lh => lh.UserAgent)
            .HasColumnName("user_agent")
            .HasMaxLength(500);

        builder.Property(lh => lh.IsSuccessful)
            .HasColumnName("is_successful")
            .IsRequired();

        builder.Property(lh => lh.FailureReason)
            .HasColumnName("failure_reason")
            .HasMaxLength(200);

        builder.Property(lh => lh.Location)
            .HasColumnName("location")
            .HasMaxLength(200);

        builder.Property(lh => lh.CreatedAt)
            .HasColumnName("created_at")
            .IsRequired()
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        builder.Property(lh => lh.UpdatedAt)
            .HasColumnName("updated_at");

        // Relationships
        builder.HasOne(lh => lh.User)
            .WithMany(u => u.LoginHistories)
            .HasForeignKey(lh => lh.UserId)
            .OnDelete(DeleteBehavior.Cascade)
            .IsRequired();

        // Indexes
        builder.HasIndex(lh => lh.UserId);
        builder.HasIndex(lh => lh.IpAddress);
        builder.HasIndex(lh => lh.CreatedAt);
        builder.HasIndex(lh => lh.IsSuccessful);
        builder.HasIndex(lh => new { lh.UserId, lh.CreatedAt });
    }
}
