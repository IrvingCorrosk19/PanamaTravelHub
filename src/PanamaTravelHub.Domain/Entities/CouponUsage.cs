namespace PanamaTravelHub.Domain.Entities;

public class CouponUsage : BaseEntity
{
    public Guid CouponId { get; set; }
    public Guid UserId { get; set; }
    public Guid BookingId { get; set; }
    public decimal DiscountAmount { get; set; } // Monto descontado
    public decimal OriginalAmount { get; set; } // Monto original antes del descuento
    public decimal FinalAmount { get; set; } // Monto final después del descuento
    
    // Navigation properties
    public Coupon Coupon { get; set; } = null!;
    public User User { get; set; } = null!;
    public Booking Booking { get; set; } = null!;
}
