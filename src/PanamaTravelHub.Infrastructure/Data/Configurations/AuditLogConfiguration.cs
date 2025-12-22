using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class AuditLogConfiguration : IEntityTypeConfiguration<AuditLog>
{
    public void Configure(EntityTypeBuilder<AuditLog> builder)
    {
        builder.ToTable("audit_logs");

        builder.HasKey(al => al.Id);
        builder.Property(al => al.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(al => al.UserId)
            .HasColumnName("user_id");

        builder.Property(al => al.EntityType)
            .HasColumnName("entity_type")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(al => al.EntityId)
            .HasColumnName("entity_id")
            .IsRequired();

        builder.Property(al => al.Action)
            .HasColumnName("action")
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(al => al.BeforeState)
            .HasColumnName("before_state")
            .HasColumnType("jsonb");

        builder.Property(al => al.AfterState)
            .HasColumnName("after_state")
            .HasColumnType("jsonb");

        builder.Property(al => al.IpAddress)
            .HasColumnName("ip_address")
            .HasMaxLength(45);

        builder.Property(al => al.UserAgent)
            .HasColumnName("user_agent");

        builder.Property(al => al.CorrelationId)
            .HasColumnName("correlation_id");

        builder.Property(al => al.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        builder.Property(al => al.UpdatedAt)
            .HasColumnName("updated_at");

        // Índices
        builder.HasIndex(al => new { al.EntityType, al.EntityId })
            .HasDatabaseName("idx_audit_logs_entity_type_id");

        builder.HasIndex(al => al.Action)
            .HasDatabaseName("idx_audit_logs_action");

        builder.HasIndex(al => al.CreatedAt)
            .HasDatabaseName("idx_audit_logs_created_at");

        builder.HasIndex(al => al.CorrelationId)
            .HasDatabaseName("idx_audit_logs_correlation_id");
    }
}
