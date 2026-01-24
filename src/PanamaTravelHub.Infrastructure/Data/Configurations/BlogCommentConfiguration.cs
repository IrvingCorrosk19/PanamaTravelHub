using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Domain.Enums;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class BlogCommentConfiguration : IEntityTypeConfiguration<BlogComment>
{
    public void Configure(EntityTypeBuilder<BlogComment> builder)
    {
        builder.ToTable("blog_comments");

        builder.HasKey(bc => bc.Id);

        // Propiedades básicas
        builder.Property(bc => bc.BlogPostId)
            .IsRequired();

        builder.Property(bc => bc.UserId)
            .IsRequired(false);

        builder.Property(bc => bc.ParentCommentId)
            .IsRequired(false);

        builder.Property(bc => bc.AuthorName)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(bc => bc.AuthorEmail)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(bc => bc.AuthorWebsite)
            .HasMaxLength(500);

        builder.Property(bc => bc.Content)
            .IsRequired()
            .HasMaxLength(5000);

        builder.Property(bc => bc.Status)
            .IsRequired()
            .HasConversion<int>();

        builder.Property(bc => bc.AdminNotes)
            .HasMaxLength(1000);

        builder.Property(bc => bc.UserIp)
            .HasMaxLength(50);

        builder.Property(bc => bc.UserAgent)
            .HasMaxLength(500);

        builder.Property(bc => bc.Likes)
            .HasDefaultValue(0);

        builder.Property(bc => bc.Dislikes)
            .HasDefaultValue(0);

        // Relaciones
        builder.HasOne(bc => bc.BlogPost)
            .WithMany()
            .HasForeignKey(bc => bc.BlogPostId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(bc => bc.User)
            .WithMany()
            .HasForeignKey(bc => bc.UserId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(bc => bc.ParentComment)
            .WithMany(bc => bc.Replies)
            .HasForeignKey(bc => bc.ParentCommentId)
            .OnDelete(DeleteBehavior.Cascade);

        // Índices
        builder.HasIndex(bc => bc.BlogPostId);
        builder.HasIndex(bc => bc.UserId);
        builder.HasIndex(bc => bc.ParentCommentId);
        builder.HasIndex(bc => bc.Status);
        builder.HasIndex(bc => bc.CreatedAt);

        // Índice compuesto para consultas comunes
        builder.HasIndex(bc => new { bc.BlogPostId, bc.Status, bc.CreatedAt });

        // Constraints
        builder.HasCheckConstraint("CK_BlogComment_Likes_NonNegative", "likes >= 0");
        builder.HasCheckConstraint("CK_BlogComment_Dislikes_NonNegative", "dislikes >= 0");
    }
}
