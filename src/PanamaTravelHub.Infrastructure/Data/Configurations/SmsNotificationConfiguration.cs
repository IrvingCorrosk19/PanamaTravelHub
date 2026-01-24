using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Domain.Enums;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class SmsNotificationConfiguration : IEntityTypeConfiguration<SmsNotification>
{
    public void Configure(EntityTypeBuilder<SmsNotification> builder)
    {
        builder.ToTable("sms_notifications");

        builder.HasKey(sn => sn.Id);
        builder.Property(sn => sn.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(sn => sn.UserId)
            .HasColumnName("user_id");

        builder.Property(sn => sn.BookingId)
            .HasColumnName("booking_id");

        builder.Property(sn => sn.Type)
            .HasColumnName("type")
            .HasConversion<int>()
            .IsRequired();

        builder.Property(sn => sn.Status)
            .HasColumnName("status")
            .HasConversion<int>()
            .HasDefaultValue(SmsNotificationStatus.Pending)
            .HasSentinel(SmsNotificationStatus.Pending)
            .IsRequired();

        builder.Property(sn => sn.ToPhoneNumber)
            .HasColumnName("to_phone_number")
            .HasMaxLength(20)
            .IsRequired();

        builder.Property(sn => sn.Message)
            .HasColumnName("message")
            .HasMaxLength(1600) // SMS limit is 1600 chars for concatenated messages
            .IsRequired();

        builder.Property(sn => sn.SentAt)
            .HasColumnName("sent_at");

        builder.Property(sn => sn.RetryCount)
            .HasColumnName("retry_count")
            .HasDefaultValue(0)
            .IsRequired();

        builder.Property(sn => sn.ErrorMessage)
            .HasColumnName("error_message")
            .HasMaxLength(1000);

        builder.Property(sn => sn.ScheduledFor)
            .HasColumnName("scheduled_for");

        builder.Property(sn => sn.ProviderMessageId)
            .HasColumnName("provider_message_id")
            .HasMaxLength(100);

        builder.Property(sn => sn.ProviderResponse)
            .HasColumnName("provider_response");

        builder.Property(sn => sn.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        builder.Property(sn => sn.UpdatedAt)
            .HasColumnName("updated_at");

        // Índices
        builder.HasIndex(sn => sn.UserId)
            .HasDatabaseName("idx_sms_notifications_user_id");

        builder.HasIndex(sn => sn.BookingId)
            .HasDatabaseName("idx_sms_notifications_booking_id");

        builder.HasIndex(sn => sn.Status)
            .HasDatabaseName("idx_sms_notifications_status");

        builder.HasIndex(sn => new { sn.Status, sn.ScheduledFor })
            .HasDatabaseName("idx_sms_notifications_status_scheduled");

        builder.HasIndex(sn => sn.ProviderMessageId)
            .HasDatabaseName("idx_sms_notifications_provider_id");

        // Relaciones
        builder.HasOne(sn => sn.User)
            .WithMany()
            .HasForeignKey(sn => sn.UserId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(sn => sn.Booking)
            .WithMany()
            .HasForeignKey(sn => sn.BookingId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}

