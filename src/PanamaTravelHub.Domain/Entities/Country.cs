namespace PanamaTravelHub.Domain.Entities;

/// <summary>
/// Entidad para países - permite seleccionar país en reservas
/// </summary>
public class Country : BaseEntity
{
    public string Code { get; set; } = string.Empty; // ISO 3166-1 alpha-2 (ej: CR, PA, US)
    public string Name { get; set; } = string.Empty; // Nombre del país
    public bool IsActive { get; set; } = true; // País activo para selección
    public int DisplayOrder { get; set; } = 0; // Orden de visualización

    // Navigation properties
    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
}

