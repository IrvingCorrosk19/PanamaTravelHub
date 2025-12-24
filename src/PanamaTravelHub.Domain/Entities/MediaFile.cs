namespace PanamaTravelHub.Domain.Entities;

/// <summary>
/// Archivo multimedia en la biblioteca de medios
/// </summary>
public class MediaFile : BaseEntity
{
    public string FileName { get; set; } = string.Empty;
    public string FilePath { get; set; } = string.Empty;
    public string FileUrl { get; set; } = string.Empty;
    public string MimeType { get; set; } = string.Empty;
    public long FileSize { get; set; } // En bytes
    public string? AltText { get; set; }
    public string? Description { get; set; }
    public string? Category { get; set; } // Categoría opcional para organizar
    public bool IsImage { get; set; }
    public int? Width { get; set; } // Para imágenes
    public int? Height { get; set; } // Para imágenes
    public Guid? UploadedBy { get; set; } // Usuario que subió el archivo
    
    // Navigation properties
    public User? Uploader { get; set; }
}

