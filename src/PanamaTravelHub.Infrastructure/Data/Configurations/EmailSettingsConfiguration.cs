using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class EmailSettingsConfiguration : IEntityTypeConfiguration<EmailSettings>
{
    public void Configure(EntityTypeBuilder<EmailSettings> builder)
    {
        builder.ToTable("email_settings");

        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(e => e.SmtpHost)
            .HasColumnName("smtp_host")
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(e => e.SmtpPort)
            .HasColumnName("smtp_port")
            .IsRequired();

        builder.Property(e => e.SmtpUsername)
            .HasColumnName("smtp_username")
            .HasMaxLength(255);

        builder.Property(e => e.SmtpPassword)
            .HasColumnName("smtp_password")
            .HasMaxLength(500);

        builder.Property(e => e.FromAddress)
            .HasColumnName("from_address")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(e => e.FromName)
            .HasColumnName("from_name")
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(e => e.EnableSsl)
            .HasColumnName("enable_ssl")
            .IsRequired();

        builder.Property(e => e.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        builder.Property(e => e.UpdatedAt)
            .HasColumnName("updated_at");
    }
}
