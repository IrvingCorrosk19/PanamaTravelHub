using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Domain.Enums;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class PaymentConfiguration : IEntityTypeConfiguration<Payment>
{
    public void Configure(EntityTypeBuilder<Payment> builder)
    {
        builder.ToTable("payments");

        builder.HasKey(p => p.Id);
        builder.Property(p => p.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(p => p.BookingId)
            .HasColumnName("booking_id")
            .IsRequired();

        builder.Property(p => p.Provider)
            .HasColumnName("provider")
            .HasConversion<int>()
            .IsRequired();

        builder.Property(p => p.Status)
            .HasColumnName("status")
            .HasConversion<int>()
            .HasDefaultValue(PaymentStatus.Initiated)
            .IsRequired();

        builder.Property(p => p.Amount)
            .HasColumnName("amount")
            .HasColumnType("decimal(10,2)")
            .IsRequired();

        builder.Property(p => p.ProviderTransactionId)
            .HasColumnName("provider_transaction_id")
            .HasMaxLength(255);

        builder.Property(p => p.ProviderPaymentIntentId)
            .HasColumnName("provider_payment_intent_id")
            .HasMaxLength(255);

        builder.Property(p => p.Currency)
            .HasColumnName("currency")
            .HasMaxLength(3)
            .HasDefaultValue("USD")
            .IsRequired();

        builder.Property(p => p.AuthorizedAt)
            .HasColumnName("authorized_at");

        builder.Property(p => p.CapturedAt)
            .HasColumnName("captured_at");

        builder.Property(p => p.RefundedAt)
            .HasColumnName("refunded_at");

        builder.Property(p => p.FailureReason)
            .HasColumnName("failure_reason");

        builder.Property(p => p.Metadata)
            .HasColumnName("metadata")
            .HasColumnType("jsonb");

        builder.Property(p => p.IsPartial)
            .HasColumnName("is_partial")
            .HasDefaultValue(false)
            .IsRequired();

        builder.Property(p => p.InstallmentNumber)
            .HasColumnName("installment_number");

        builder.Property(p => p.TotalInstallments)
            .HasColumnName("total_installments");

        builder.Property(p => p.ParentPaymentId)
            .HasColumnName("parent_payment_id");

        // Relaciones
        builder.HasOne(p => p.ParentPayment)
            .WithMany(p => p.ChildPayments)
            .HasForeignKey(p => p.ParentPaymentId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.Property(p => p.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        builder.Property(p => p.UpdatedAt)
            .HasColumnName("updated_at");

        // Índices
        builder.HasIndex(p => p.BookingId)
            .HasDatabaseName("idx_payments_booking_id");

        builder.HasIndex(p => p.Provider)
            .HasDatabaseName("idx_payments_provider");

        builder.HasIndex(p => p.Status)
            .HasDatabaseName("idx_payments_status");

        builder.HasIndex(p => p.ProviderTransactionId)
            .HasDatabaseName("idx_payments_provider_transaction_id");

        builder.HasIndex(p => p.CreatedAt)
            .HasDatabaseName("idx_payments_created_at");
    }
}
