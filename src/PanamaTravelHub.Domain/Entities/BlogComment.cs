using PanamaTravelHub.Domain.Enums;

namespace PanamaTravelHub.Domain.Entities;

public class BlogComment : BaseEntity
{
    public Guid BlogPostId { get; set; } // ID del post de blog (Page con Template="Blog")
    public Guid? UserId { get; set; } // Usuario autenticado (opcional para comentarios anónimos)
    public Guid? ParentCommentId { get; set; } // Para comentarios anidados (respuestas)
    
    // Información del comentarista
    public string AuthorName { get; set; } = string.Empty; // Nombre del autor
    public string AuthorEmail { get; set; } = string.Empty; // Email del autor
    public string? AuthorWebsite { get; set; } // Website opcional
    
    // Contenido
    public string Content { get; set; } = string.Empty; // Contenido del comentario
    
    // Moderación
    public BlogCommentStatus Status { get; set; } = BlogCommentStatus.Pending; // Pending, Approved, Rejected, Spam
    public string? AdminNotes { get; set; } // Notas internas del admin
    
    // Metadata
    public string? UserIp { get; set; } // IP del usuario
    public string? UserAgent { get; set; } // User agent del navegador
    public int Likes { get; set; } = 0; // Contador de likes
    public int Dislikes { get; set; } = 0; // Contador de dislikes
    
    // Navigation properties
    public Page? BlogPost { get; set; }
    public User? User { get; set; }
    public BlogComment? ParentComment { get; set; }
    public ICollection<BlogComment> Replies { get; set; } = new List<BlogComment>();
}
