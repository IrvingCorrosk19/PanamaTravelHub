using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class InvoiceConfiguration : IEntityTypeConfiguration<Invoice>
{
    public void Configure(EntityTypeBuilder<Invoice> builder)
    {
        builder.ToTable("invoices");

        builder.HasKey(i => i.Id);
        builder.Property(i => i.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(i => i.InvoiceNumber)
            .HasColumnName("invoice_number")
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(i => i.BookingId)
            .HasColumnName("booking_id")
            .IsRequired();

        builder.Property(i => i.UserId)
            .HasColumnName("user_id")
            .IsRequired();

        builder.Property(i => i.Currency)
            .HasColumnName("currency")
            .HasMaxLength(3)
            .HasDefaultValue("USD")
            .IsRequired();

        builder.Property(i => i.Subtotal)
            .HasColumnName("subtotal")
            .HasColumnType("decimal(10,2)")
            .IsRequired();

        builder.Property(i => i.Discount)
            .HasColumnName("discount")
            .HasColumnType("decimal(10,2)")
            .HasDefaultValue(0)
            .IsRequired();

        builder.Property(i => i.Taxes)
            .HasColumnName("taxes")
            .HasColumnType("decimal(10,2)")
            .HasDefaultValue(0)
            .IsRequired();

        builder.Property(i => i.Total)
            .HasColumnName("total")
            .HasColumnType("decimal(10,2)")
            .IsRequired();

        builder.Property(i => i.Language)
            .HasColumnName("language")
            .HasMaxLength(2)
            .HasDefaultValue("ES")
            .IsRequired();

        builder.Property(i => i.IssuedAt)
            .HasColumnName("issued_at")
            .HasConversion(
                v => DateTime.SpecifyKind(v, DateTimeKind.Utc),
                v => DateTime.SpecifyKind(v, DateTimeKind.Utc))
            .IsRequired();

        builder.Property(i => i.PdfUrl)
            .HasColumnName("pdf_url")
            .HasMaxLength(500);

        builder.Property(i => i.Status)
            .HasColumnName("status")
            .HasMaxLength(20)
            .HasDefaultValue("Issued")
            .IsRequired();

        builder.Property(i => i.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .HasConversion(v => DateTime.SpecifyKind(v, DateTimeKind.Utc), v => DateTime.SpecifyKind(v, DateTimeKind.Utc))
            .IsRequired();

        builder.Property(i => i.UpdatedAt)
            .HasColumnName("updated_at")
            .HasConversion(
                v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : (DateTime?)null,
                v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : (DateTime?)null);

        // Índices
        builder.HasIndex(i => i.InvoiceNumber)
            .IsUnique();

        builder.HasIndex(i => i.BookingId);
        builder.HasIndex(i => i.UserId);
        builder.HasIndex(i => i.IssuedAt);

        // Relaciones
        builder.HasOne(i => i.Booking)
            .WithMany()
            .HasForeignKey(i => i.BookingId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(i => i.User)
            .WithMany()
            .HasForeignKey(i => i.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        // Constraints
        builder.HasCheckConstraint("chk_invoice_total_positive", "total >= 0");
        builder.HasCheckConstraint("chk_invoice_language", "language IN ('ES', 'EN')");
        builder.HasCheckConstraint("chk_invoice_status", "status IN ('Issued', 'Void')");
    }
}
