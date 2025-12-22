using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class TourImageConfiguration : IEntityTypeConfiguration<TourImage>
{
    public void Configure(EntityTypeBuilder<TourImage> builder)
    {
        builder.ToTable("tour_images");

        builder.HasKey(ti => ti.Id);
        builder.Property(ti => ti.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(ti => ti.TourId)
            .HasColumnName("tour_id")
            .IsRequired();

        builder.Property(ti => ti.ImageUrl)
            .HasColumnName("image_url")
            .HasMaxLength(500)
            .IsRequired();

        builder.Property(ti => ti.AltText)
            .HasColumnName("alt_text")
            .HasMaxLength(200);

        builder.Property(ti => ti.DisplayOrder)
            .HasColumnName("display_order")
            .HasDefaultValue(0)
            .IsRequired();

        builder.Property(ti => ti.IsPrimary)
            .HasColumnName("is_primary")
            .HasDefaultValue(false)
            .IsRequired();

        builder.Property(ti => ti.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        builder.Property(ti => ti.UpdatedAt)
            .HasColumnName("updated_at");

        // Índices
        builder.HasIndex(ti => ti.TourId)
            .HasDatabaseName("idx_tour_images_tour_id");

        builder.HasIndex(ti => new { ti.TourId, ti.DisplayOrder })
            .HasDatabaseName("idx_tour_images_display_order");
    }
}
