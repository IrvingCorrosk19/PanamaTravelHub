using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class TourTagAssignmentConfiguration : IEntityTypeConfiguration<TourTagAssignment>
{
    public void Configure(EntityTypeBuilder<TourTagAssignment> builder)
    {
        builder.ToTable("tour_tag_assignments");

        builder.HasKey(a => a.Id);
        builder.Property(a => a.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(a => a.TourId)
            .HasColumnName("tour_id")
            .IsRequired();

        builder.Property(a => a.TagId)
            .HasColumnName("tag_id")
            .IsRequired();

        builder.Property(a => a.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        // Relaciones
        builder.HasOne(a => a.Tour)
            .WithMany(t => t.TourTagAssignments)
            .HasForeignKey(a => a.TourId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(a => a.Tag)
            .WithMany(t => t.TourTagAssignments)
            .HasForeignKey(a => a.TagId)
            .OnDelete(DeleteBehavior.Cascade);

        // Índice único
        builder.HasIndex(a => new { a.TourId, a.TagId })
            .IsUnique()
            .HasDatabaseName("uq_tour_tag");

        // Índices
        builder.HasIndex(a => a.TourId)
            .HasDatabaseName("idx_tour_tag_assignments_tour");

        builder.HasIndex(a => a.TagId)
            .HasDatabaseName("idx_tour_tag_assignments_tag");
    }
}
