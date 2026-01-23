using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class UserFavoriteConfiguration : IEntityTypeConfiguration<UserFavorite>
{
    public void Configure(EntityTypeBuilder<UserFavorite> builder)
    {
        builder.ToTable("user_favorites");

        builder.HasKey(uf => uf.Id);
        builder.Property(uf => uf.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(uf => uf.UserId)
            .HasColumnName("user_id")
            .IsRequired();

        builder.Property(uf => uf.TourId)
            .HasColumnName("tour_id")
            .IsRequired();

        builder.Property(uf => uf.CreatedAt)
            .HasColumnName("created_at")
            .IsRequired()
            .HasDefaultValueSql("CURRENT_TIMESTAMP");

        builder.Property(uf => uf.UpdatedAt)
            .HasColumnName("updated_at");

        // Relationships
        builder.HasOne(uf => uf.User)
            .WithMany()
            .HasForeignKey(uf => uf.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(uf => uf.Tour)
            .WithMany()
            .HasForeignKey(uf => uf.TourId)
            .OnDelete(DeleteBehavior.Cascade);

        // Unique constraint: un usuario solo puede tener un tour una vez en favoritos
        builder.HasIndex(uf => new { uf.UserId, uf.TourId }).IsUnique();
    }
}
