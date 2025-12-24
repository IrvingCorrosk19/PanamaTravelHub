using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class PageConfiguration : IEntityTypeConfiguration<Page>
{
    public void Configure(EntityTypeBuilder<Page> builder)
    {
        builder.ToTable("pages");

        builder.HasKey(p => p.Id);
        builder.Property(p => p.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(p => p.Title)
            .HasColumnName("title")
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(p => p.Slug)
            .HasColumnName("slug")
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(p => p.Content)
            .HasColumnName("content")
            .HasColumnType("text")
            .IsRequired();

        builder.Property(p => p.Excerpt)
            .HasColumnName("excerpt")
            .HasMaxLength(500);

        builder.Property(p => p.MetaTitle)
            .HasColumnName("meta_title")
            .HasMaxLength(200);

        builder.Property(p => p.MetaDescription)
            .HasColumnName("meta_description")
            .HasMaxLength(500);

        builder.Property(p => p.MetaKeywords)
            .HasColumnName("meta_keywords")
            .HasMaxLength(500);

        builder.Property(p => p.IsPublished)
            .HasColumnName("is_published")
            .HasDefaultValue(false)
            .IsRequired();

        builder.Property(p => p.PublishedAt)
            .HasColumnName("published_at");

        builder.Property(p => p.Template)
            .HasColumnName("template")
            .HasMaxLength(100);

        builder.Property(p => p.DisplayOrder)
            .HasColumnName("display_order")
            .HasDefaultValue(0)
            .IsRequired();

        builder.Property(p => p.CreatedBy)
            .HasColumnName("created_by");

        builder.Property(p => p.UpdatedBy)
            .HasColumnName("updated_by");

        builder.Property(p => p.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        builder.Property(p => p.UpdatedAt)
            .HasColumnName("updated_at");

        // Relaciones
        builder.HasOne(p => p.Creator)
            .WithMany()
            .HasForeignKey(p => p.CreatedBy)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(p => p.Updater)
            .WithMany()
            .HasForeignKey(p => p.UpdatedBy)
            .OnDelete(DeleteBehavior.SetNull);

        // Índices
        builder.HasIndex(p => p.Slug)
            .IsUnique()
            .HasDatabaseName("idx_pages_slug_unique");

        builder.HasIndex(p => p.IsPublished)
            .HasDatabaseName("idx_pages_is_published");

        builder.HasIndex(p => new { p.IsPublished, p.DisplayOrder })
            .HasDatabaseName("idx_pages_published_order");

        builder.HasIndex(p => p.CreatedAt)
            .HasDatabaseName("idx_pages_created_at");
    }
}

