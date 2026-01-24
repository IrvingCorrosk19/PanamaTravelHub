using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class TourConfiguration : IEntityTypeConfiguration<Tour>
{
    public void Configure(EntityTypeBuilder<Tour> builder)
    {
        builder.ToTable("tours");

        builder.HasKey(t => t.Id);
        builder.Property(t => t.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        builder.Property(t => t.Name)
            .HasColumnName("name")
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(t => t.Description)
            .HasColumnName("description")
            .IsRequired();

        builder.Property(t => t.Itinerary)
            .HasColumnName("itinerary");

        builder.Property(t => t.Includes)
            .HasColumnName("includes");

        builder.Property(t => t.Price)
            .HasColumnName("price")
            .HasColumnType("decimal(10,2)")
            .IsRequired();

        builder.Property(t => t.MaxCapacity)
            .HasColumnName("max_capacity")
            .IsRequired();

        builder.Property(t => t.DurationHours)
            .HasColumnName("duration_hours")
            .IsRequired();

        builder.Property(t => t.Location)
            .HasColumnName("location")
            .HasMaxLength(200);

        builder.Property(t => t.TourDate)
            .HasColumnName("tour_date");

        builder.Property(t => t.IsActive)
            .HasColumnName("is_active")
            .HasDefaultValue(true)
            .IsRequired();

        builder.Property(t => t.AvailableSpots)
            .HasColumnName("available_spots")
            .HasDefaultValue(0)
            .IsRequired();

        // CMS Blocks
        builder.Property(t => t.HeroTitle)
            .HasColumnName("hero_title")
            .HasMaxLength(500);
            
        builder.Property(t => t.HeroSubtitle)
            .HasColumnName("hero_subtitle");
            
        builder.Property(t => t.HeroCtaText)
            .HasColumnName("hero_cta_text")
            .HasMaxLength(200)
            .HasDefaultValue("Ver fechas disponibles");
            
        builder.Property(t => t.SocialProofText)
            .HasColumnName("social_proof_text");
            
        builder.Property(t => t.HasCertifiedGuide)
            .HasColumnName("has_certified_guide")
            .HasDefaultValue(true);
            
        builder.Property(t => t.HasFlexibleCancellation)
            .HasColumnName("has_flexible_cancellation")
            .HasDefaultValue(true);
            
        builder.Property(t => t.AvailableLanguages)
            .HasColumnName("available_languages");
            
        builder.Property(t => t.HighlightsDuration)
            .HasColumnName("highlights_duration")
            .HasMaxLength(100);
            
        builder.Property(t => t.HighlightsGroupType)
            .HasColumnName("highlights_group_type")
            .HasMaxLength(100);
            
        builder.Property(t => t.HighlightsPhysicalLevel)
            .HasColumnName("highlights_physical_level")
            .HasMaxLength(100);
            
        builder.Property(t => t.HighlightsMeetingPoint)
            .HasColumnName("highlights_meeting_point");
            
        builder.Property(t => t.StoryContent)
            .HasColumnName("story_content");
            
        builder.Property(t => t.IncludesList)
            .HasColumnName("includes_list");
            
        builder.Property(t => t.ExcludesList)
            .HasColumnName("excludes_list");
            
        builder.Property(t => t.MapCoordinates)
            .HasColumnName("map_coordinates")
            .HasMaxLength(100);
            
        builder.Property(t => t.MapReferenceText)
            .HasColumnName("map_reference_text");
            
        builder.Property(t => t.FinalCtaText)
            .HasColumnName("final_cta_text")
            .HasMaxLength(500)
            .HasDefaultValue("¿Listo para vivir esta experiencia?");
            
        builder.Property(t => t.FinalCtaButtonText)
            .HasColumnName("final_cta_button_text")
            .HasMaxLength(200)
            .HasDefaultValue("Ver fechas disponibles");
            
        builder.Property(t => t.BlockOrder)
            .HasColumnName("block_order");
            
        builder.Property(t => t.BlockEnabled)
            .HasColumnName("block_enabled");

        builder.Property(t => t.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        builder.Property(t => t.UpdatedAt)
            .HasColumnName("updated_at");

        // Índices
        builder.HasIndex(t => t.IsActive)
            .HasDatabaseName("idx_tours_is_active");

        builder.HasIndex(t => t.Name)
            .HasDatabaseName("idx_tours_name");

        // Relaciones
        builder.HasMany(t => t.TourImages)
            .WithOne(ti => ti.Tour)
            .HasForeignKey(ti => ti.TourId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(t => t.TourDates)
            .WithOne(td => td.Tour)
            .HasForeignKey(td => td.TourId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(t => t.Bookings)
            .WithOne(b => b.Tour)
            .HasForeignKey(b => b.TourId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
