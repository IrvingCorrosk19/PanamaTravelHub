namespace PanamaTravelHub.Domain.Entities;

public class Coupon : BaseEntity
{
    public string Code { get; set; } = string.Empty; // Código único del cupón
    public string Description { get; set; } = string.Empty;
    
    // Tipo de descuento
    public CouponType DiscountType { get; set; } // Percentage o FixedAmount
    public decimal DiscountValue { get; set; } // Porcentaje (0-100) o monto fijo
    
    // Límites
    public decimal? MinimumPurchaseAmount { get; set; } // Monto mínimo de compra
    public decimal? MaximumDiscountAmount { get; set; } // Descuento máximo (para porcentajes)
    
    // Fechas
    public DateTime? ValidFrom { get; set; }
    public DateTime? ValidUntil { get; set; }
    
    // Límites de uso
    public int? MaxUses { get; set; } // Número máximo de usos totales
    public int? MaxUsesPerUser { get; set; } // Número máximo de usos por usuario
    public int CurrentUses { get; set; } = 0; // Contador de usos actuales
    
    // Restricciones
    public bool IsActive { get; set; } = true;
    public bool IsFirstTimeOnly { get; set; } = false; // Solo para primera compra
    public Guid? ApplicableTourId { get; set; } // Si es null, aplica a todos los tours
    
    // Navigation properties
    public Tour? ApplicableTour { get; set; }
    public ICollection<CouponUsage> Usages { get; set; } = new List<CouponUsage>();
}

public enum CouponType
{
    Percentage = 1,    // Descuento por porcentaje
    FixedAmount = 2    // Descuento por monto fijo
}
