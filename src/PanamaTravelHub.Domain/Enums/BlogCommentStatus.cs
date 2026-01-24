namespace PanamaTravelHub.Domain.Enums;

public enum BlogCommentStatus
{
    Pending = 0,    // Pendiente de moderación
    Approved = 1,    // Aprobado y visible
    Rejected = 2,   // Rechazado (no visible)
    Spam = 3        // Marcado como spam
}
