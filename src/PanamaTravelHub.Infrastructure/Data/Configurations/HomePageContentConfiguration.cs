using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Infrastructure.Data.Configurations;

public class HomePageContentConfiguration : IEntityTypeConfiguration<HomePageContent>
{
    public void Configure(EntityTypeBuilder<HomePageContent> builder)
    {
        builder.ToTable("home_page_content");

        builder.HasKey(h => h.Id);
        builder.Property(h => h.Id)
            .HasColumnName("id")
            .HasDefaultValueSql("uuid_generate_v4()");

        // Hero Section
        builder.Property(h => h.HeroTitle)
            .HasColumnName("hero_title")
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(h => h.HeroSubtitle)
            .HasColumnName("hero_subtitle")
            .HasMaxLength(500)
            .IsRequired();

        builder.Property(h => h.HeroSearchPlaceholder)
            .HasColumnName("hero_search_placeholder")
            .HasMaxLength(100)
            .IsRequired();

        // Tours Section
        builder.Property(h => h.ToursSectionTitle)
            .HasColumnName("tours_section_title")
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(h => h.ToursSectionSubtitle)
            .HasColumnName("tours_section_subtitle")
            .HasMaxLength(300)
            .IsRequired();

        // Footer
        builder.Property(h => h.FooterBrandText)
            .HasColumnName("footer_brand_text")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(h => h.FooterDescription)
            .HasColumnName("footer_description")
            .HasMaxLength(500)
            .IsRequired();

        builder.Property(h => h.FooterCopyright)
            .HasColumnName("footer_copyright")
            .HasMaxLength(200)
            .IsRequired();

        // Navigation
        builder.Property(h => h.NavBrandText)
            .HasColumnName("nav_brand_text")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(h => h.NavToursLink)
            .HasColumnName("nav_tours_link")
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(h => h.NavBookingsLink)
            .HasColumnName("nav_bookings_link")
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(h => h.NavLoginLink)
            .HasColumnName("nav_login_link")
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(h => h.NavLogoutButton)
            .HasColumnName("nav_logout_button")
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(h => h.HeroSearchButton)
            .HasColumnName("hero_search_button")
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(h => h.LoadingToursText)
            .HasColumnName("loading_tours_text")
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(h => h.ErrorLoadingToursText)
            .HasColumnName("error_loading_tours_text")
            .HasMaxLength(300)
            .IsRequired();

        builder.Property(h => h.NoToursFoundText)
            .HasColumnName("no_tours_found_text")
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(h => h.PageTitle)
            .HasColumnName("page_title")
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(h => h.MetaDescription)
            .HasColumnName("meta_description")
            .HasMaxLength(500)
            .IsRequired();

        // Logo & Branding
        builder.Property(h => h.LogoUrl)
            .HasColumnName("logo_url")
            .HasMaxLength(500);

        builder.Property(h => h.FaviconUrl)
            .HasColumnName("favicon_url")
            .HasMaxLength(500);

        builder.Property(h => h.LogoUrlSocial)
            .HasColumnName("logo_url_social")
            .HasMaxLength(500);

        builder.Property(h => h.HeroImageUrl)
            .HasColumnName("hero_image_url")
            .HasMaxLength(500);

        builder.Property(h => h.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .IsRequired();

        builder.Property(h => h.UpdatedAt)
            .HasColumnName("updated_at");
    }
}

