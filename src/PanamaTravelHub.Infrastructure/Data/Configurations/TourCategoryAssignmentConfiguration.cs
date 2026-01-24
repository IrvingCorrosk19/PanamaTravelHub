using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class TourCategoryAssignmentConfiguration : IEntityTypeConfiguration<TourCategoryAssignment>
{
    public void Configure(EntityTypeBuilder<TourCategoryAssignment> builder)
    {
        builder.ToTable("tour_category_assignments");

        builder.HasKey(a => a.Id);
        builder.Property(a => a.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(a => a.TourId)
            .HasColumnName("tour_id")
            .IsRequired();

        builder.Property(a => a.CategoryId)
            .HasColumnName("category_id")
            .IsRequired();

        builder.Property(a => a.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        // Relaciones
        builder.HasOne(a => a.Tour)
            .WithMany(t => t.TourCategoryAssignments)
            .HasForeignKey(a => a.TourId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(a => a.Category)
            .WithMany(c => c.TourCategoryAssignments)
            .HasForeignKey(a => a.CategoryId)
            .OnDelete(DeleteBehavior.Cascade);

        // Índice único
        builder.HasIndex(a => new { a.TourId, a.CategoryId })
            .IsUnique()
            .HasDatabaseName("uq_tour_category");

        // Índices
        builder.HasIndex(a => a.TourId)
            .HasDatabaseName("idx_tour_category_assignments_tour");

        builder.HasIndex(a => a.CategoryId)
            .HasDatabaseName("idx_tour_category_assignments_category");
    }
}
