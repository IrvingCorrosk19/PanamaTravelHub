using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class MediaFileConfiguration : IEntityTypeConfiguration<MediaFile>
{
    public void Configure(EntityTypeBuilder<MediaFile> builder)
    {
        builder.ToTable("media_files");

        builder.HasKey(m => m.Id);
        builder.Property(m => m.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(m => m.FileName)
            .HasColumnName("file_name")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(m => m.FilePath)
            .HasColumnName("file_path")
            .HasMaxLength(1000)
            .IsRequired();

        builder.Property(m => m.FileUrl)
            .HasColumnName("file_url")
            .HasMaxLength(1000)
            .IsRequired();

        builder.Property(m => m.MimeType)
            .HasColumnName("mime_type")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(m => m.FileSize)
            .HasColumnName("file_size")
            .IsRequired();

        builder.Property(m => m.AltText)
            .HasColumnName("alt_text")
            .HasMaxLength(500);

        builder.Property(m => m.Description)
            .HasColumnName("description")
            .HasMaxLength(1000);

        builder.Property(m => m.Category)
            .HasColumnName("category")
            .HasMaxLength(100);

        builder.Property(m => m.IsImage)
            .HasColumnName("is_image")
            .HasDefaultValue(false)
            .IsRequired();

        builder.Property(m => m.Width)
            .HasColumnName("width");

        builder.Property(m => m.Height)
            .HasColumnName("height");

        builder.Property(m => m.UploadedBy)
            .HasColumnName("uploaded_by");

        builder.Property(m => m.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        builder.Property(m => m.UpdatedAt)
            .HasColumnName("updated_at");

        // Relaciones
        builder.HasOne(m => m.Uploader)
            .WithMany()
            .HasForeignKey(m => m.UploadedBy)
            .OnDelete(DeleteBehavior.SetNull);

        // Índices
        builder.HasIndex(m => m.Category)
            .HasDatabaseName("idx_media_files_category");

        builder.HasIndex(m => m.IsImage)
            .HasDatabaseName("idx_media_files_is_image");

        builder.HasIndex(m => m.UploadedBy)
            .HasDatabaseName("idx_media_files_uploaded_by");

        builder.HasIndex(m => m.CreatedAt)
            .HasDatabaseName("idx_media_files_created_at");
    }
}

