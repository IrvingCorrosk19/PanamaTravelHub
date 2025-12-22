using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Domain.Enums;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class EmailNotificationConfiguration : IEntityTypeConfiguration<EmailNotification>
{
    public void Configure(EntityTypeBuilder<EmailNotification> builder)
    {
        builder.ToTable("email_notifications");

        builder.HasKey(en => en.Id);
        builder.Property(en => en.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(en => en.UserId)
            .HasColumnName("user_id");

        builder.Property(en => en.BookingId)
            .HasColumnName("booking_id");

        builder.Property(en => en.Type)
            .HasColumnName("type")
            .HasConversion<int>()
            .IsRequired();

        builder.Property(en => en.Status)
            .HasColumnName("status")
            .HasConversion<int>()
            .HasDefaultValue(EmailNotificationStatus.Pending)
            .IsRequired();

        builder.Property(en => en.ToEmail)
            .HasColumnName("to_email")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(en => en.Subject)
            .HasColumnName("subject")
            .HasMaxLength(500)
            .IsRequired();

        builder.Property(en => en.Body)
            .HasColumnName("body")
            .IsRequired();

        builder.Property(en => en.SentAt)
            .HasColumnName("sent_at");

        builder.Property(en => en.RetryCount)
            .HasColumnName("retry_count")
            .HasDefaultValue(0)
            .IsRequired();

        builder.Property(en => en.ErrorMessage)
            .HasColumnName("error_message");

        builder.Property(en => en.ScheduledFor)
            .HasColumnName("scheduled_for");

        builder.Property(en => en.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        builder.Property(en => en.UpdatedAt)
            .HasColumnName("updated_at");

        // Índices
        builder.HasIndex(en => en.Status)
            .HasDatabaseName("idx_email_notifications_status");

        builder.HasIndex(en => en.Type)
            .HasDatabaseName("idx_email_notifications_type");

        builder.HasIndex(en => en.ScheduledFor)
            .HasDatabaseName("idx_email_notifications_scheduled_for");
    }
}
