namespace PanamaTravelHub.Domain.Entities;

/// <summary>
/// Página dinámica del CMS
/// </summary>
public class Page : BaseEntity
{
    public string Title { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty; // URL amigable
    public string Content { get; set; } = string.Empty; // Contenido HTML
    public string? Excerpt { get; set; } // Resumen corto
    public string? MetaTitle { get; set; } // SEO
    public string? MetaDescription { get; set; } // SEO
    public string? MetaKeywords { get; set; } // SEO
    public bool IsPublished { get; set; } // Publicado o borrador
    public DateTime? PublishedAt { get; set; } // Fecha de publicación
    public string? Template { get; set; } // Template a usar (opcional)
    public int DisplayOrder { get; set; } // Orden de visualización
    public Guid? CreatedBy { get; set; } // Usuario que creó la página
    public Guid? UpdatedBy { get; set; } // Usuario que actualizó la página
    
    // Navigation properties
    public User? Creator { get; set; }
    public User? Updater { get; set; }
}

