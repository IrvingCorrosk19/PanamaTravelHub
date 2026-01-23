namespace PanamaTravelHub.Domain.Entities;

public class Waitlist : BaseEntity
{
    public Guid TourId { get; set; }
    public Guid? TourDateId { get; set; } // Si es null, aplica a cualquier fecha del tour
    public Guid UserId { get; set; }
    public int NumberOfParticipants { get; set; } // Número de participantes que desea reservar
    
    public bool IsNotified { get; set; } = false; // Si ya se notificó al usuario
    public DateTime? NotifiedAt { get; set; } // Fecha de notificación
    public bool IsActive { get; set; } = true; // Si está activa en la lista de espera
    
    // Prioridad (menor número = mayor prioridad, basado en fecha de registro)
    public int Priority { get; set; }
    
    // Navigation properties
    public Tour Tour { get; set; } = null!;
    public TourDate? TourDate { get; set; }
    public User User { get; set; } = null!;
}
