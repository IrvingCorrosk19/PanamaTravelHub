using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Domain.Enums;
using PanamaTravelHub.Infrastructure.Data;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/coupons")]
public class CouponsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<CouponsController> _logger;

    public CouponsController(
        ApplicationDbContext context,
        ILogger<CouponsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Valida y aplica un cupón (público para usuarios autenticados)
    /// </summary>
    [HttpPost("validate")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult<CouponValidationResponseDto>> ValidateCoupon([FromBody] ValidateCouponRequestDto request)
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var coupon = await _context.Coupons
                .FirstOrDefaultAsync(c => c.Code.ToUpper() == request.Code.ToUpper().Trim());

            if (coupon == null)
            {
                return BadRequest(new { message = "Código de cupón no válido" });
            }

            // Validar que el cupón esté activo
            if (!coupon.IsActive)
            {
                return BadRequest(new { message = "Este cupón no está activo" });
            }

            // Validar fechas
            var now = DateTime.UtcNow;
            if (coupon.ValidFrom.HasValue && coupon.ValidFrom.Value > now)
            {
                return BadRequest(new { message = "Este cupón aún no es válido" });
            }

            if (coupon.ValidUntil.HasValue && coupon.ValidUntil.Value < now)
            {
                return BadRequest(new { message = "Este cupón ha expirado" });
            }

            // Validar límite de usos totales
            if (coupon.MaxUses.HasValue && coupon.CurrentUses >= coupon.MaxUses.Value)
            {
                return BadRequest(new { message = "Este cupón ha alcanzado su límite de usos" });
            }

            // Validar límite de usos por usuario
            if (coupon.MaxUsesPerUser.HasValue)
            {
                var userUses = await _context.CouponUsages
                    .CountAsync(cu => cu.CouponId == coupon.Id && cu.UserId == userId);

                if (userUses >= coupon.MaxUsesPerUser.Value)
                {
                    return BadRequest(new { message = "Has alcanzado el límite de usos para este cupón" });
                }
            }

            // Validar monto mínimo de compra
            if (coupon.MinimumPurchaseAmount.HasValue && request.PurchaseAmount < coupon.MinimumPurchaseAmount.Value)
            {
                return BadRequest(new { 
                    message = $"El monto mínimo de compra para este cupón es ${coupon.MinimumPurchaseAmount.Value:F2}" 
                });
            }

            // Validar si es solo para primera compra
            if (coupon.IsFirstTimeOnly)
            {
                var hasPreviousBooking = await _context.Bookings
                    .AnyAsync(b => b.UserId == userId && b.Status == BookingStatus.Confirmed);

                if (hasPreviousBooking)
                {
                    return BadRequest(new { message = "Este cupón es solo para primera compra" });
                }
            }

            // Validar si aplica a un tour específico
            if (coupon.ApplicableTourId.HasValue && request.TourId.HasValue)
            {
                if (coupon.ApplicableTourId.Value != request.TourId.Value)
                {
                    return BadRequest(new { message = "Este cupón no aplica para este tour" });
                }
            }

            // Calcular descuento
            decimal discountAmount = 0;
            if (coupon.DiscountType == CouponType.Percentage)
            {
                discountAmount = request.PurchaseAmount * (coupon.DiscountValue / 100);
                
                // Aplicar descuento máximo si existe
                if (coupon.MaximumDiscountAmount.HasValue && discountAmount > coupon.MaximumDiscountAmount.Value)
                {
                    discountAmount = coupon.MaximumDiscountAmount.Value;
                }
            }
            else if (coupon.DiscountType == CouponType.FixedAmount)
            {
                discountAmount = coupon.DiscountValue;
                
                // No puede exceder el monto de compra
                if (discountAmount > request.PurchaseAmount)
                {
                    discountAmount = request.PurchaseAmount;
                }
            }

            var finalAmount = request.PurchaseAmount - discountAmount;

            return Ok(new CouponValidationResponseDto
            {
                IsValid = true,
                CouponId = coupon.Id,
                CouponCode = coupon.Code,
                DiscountType = coupon.DiscountType.ToString(),
                DiscountAmount = discountAmount,
                OriginalAmount = request.PurchaseAmount,
                FinalAmount = finalAmount,
                Message = "Cupón válido"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al validar cupón {Code}", request.Code);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Obtiene todos los cupones (Admin)
    /// </summary>
    [HttpGet]
    [Authorize(Policy = "AdminOnly")]
    public async Task<ActionResult<IEnumerable<CouponDto>>> GetCoupons(
        [FromQuery] bool? isActive = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50)
    {
        try
        {
            var query = _context.Coupons.AsQueryable();

            if (isActive.HasValue)
            {
                query = query.Where(c => c.IsActive == isActive.Value);
            }

            var totalCount = await query.CountAsync();
            var coupons = await query
                .OrderByDescending(c => c.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(c => new CouponDto
                {
                    Id = c.Id,
                    Code = c.Code,
                    Description = c.Description,
                    DiscountType = c.DiscountType.ToString(),
                    DiscountValue = c.DiscountValue,
                    MinimumPurchaseAmount = c.MinimumPurchaseAmount,
                    MaximumDiscountAmount = c.MaximumDiscountAmount,
                    ValidFrom = c.ValidFrom,
                    ValidUntil = c.ValidUntil,
                    MaxUses = c.MaxUses,
                    MaxUsesPerUser = c.MaxUsesPerUser,
                    CurrentUses = c.CurrentUses,
                    IsActive = c.IsActive,
                    IsFirstTimeOnly = c.IsFirstTimeOnly,
                    ApplicableTourId = c.ApplicableTourId,
                    CreatedAt = c.CreatedAt
                })
                .ToListAsync();

            Response.Headers["X-Total-Count"] = totalCount.ToString();
            Response.Headers["X-Page"] = page.ToString();
            Response.Headers["X-Page-Size"] = pageSize.ToString();

            return Ok(coupons);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener cupones");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Crea un nuevo cupón (Admin)
    /// </summary>
    [HttpPost]
    [Authorize(Policy = "AdminOnly")]
    public async Task<ActionResult<CouponDto>> CreateCoupon([FromBody] CreateCouponRequestDto request)
    {
        try
        {
            // Verificar que el código no exista
            var existingCoupon = await _context.Coupons
                .FirstOrDefaultAsync(c => c.Code.ToUpper() == request.Code.ToUpper().Trim());

            if (existingCoupon != null)
            {
                return BadRequest(new { message = "Ya existe un cupón con este código" });
            }

            var coupon = new Coupon
            {
                Code = request.Code.ToUpper().Trim(),
                Description = request.Description,
                DiscountType = request.DiscountType,
                DiscountValue = request.DiscountValue,
                MinimumPurchaseAmount = request.MinimumPurchaseAmount,
                MaximumDiscountAmount = request.MaximumDiscountAmount,
                ValidFrom = request.ValidFrom.HasValue 
                    ? DateTime.SpecifyKind(request.ValidFrom.Value, DateTimeKind.Utc) 
                    : null,
                ValidUntil = request.ValidUntil.HasValue 
                    ? DateTime.SpecifyKind(request.ValidUntil.Value, DateTimeKind.Utc) 
                    : null,
                MaxUses = request.MaxUses,
                MaxUsesPerUser = request.MaxUsesPerUser,
                IsActive = request.IsActive ?? true,
                IsFirstTimeOnly = request.IsFirstTimeOnly ?? false,
                ApplicableTourId = request.ApplicableTourId
            };

            _context.Coupons.Add(coupon);
            await _context.SaveChangesAsync();

            var result = new CouponDto
            {
                Id = coupon.Id,
                Code = coupon.Code,
                Description = coupon.Description,
                DiscountType = coupon.DiscountType.ToString(),
                DiscountValue = coupon.DiscountValue,
                MinimumPurchaseAmount = coupon.MinimumPurchaseAmount,
                MaximumDiscountAmount = coupon.MaximumDiscountAmount,
                ValidFrom = coupon.ValidFrom,
                ValidUntil = coupon.ValidUntil,
                MaxUses = coupon.MaxUses,
                MaxUsesPerUser = coupon.MaxUsesPerUser,
                CurrentUses = coupon.CurrentUses,
                IsActive = coupon.IsActive,
                IsFirstTimeOnly = coupon.IsFirstTimeOnly,
                ApplicableTourId = coupon.ApplicableTourId,
                CreatedAt = coupon.CreatedAt
            };

            return CreatedAtAction(nameof(GetCoupon), new { id = coupon.Id }, result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear cupón");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Obtiene un cupón por ID (Admin)
    /// </summary>
    [HttpGet("{id}")]
    [Authorize(Policy = "AdminOnly")]
    public async Task<ActionResult<CouponDto>> GetCoupon(Guid id)
    {
        try
        {
            var coupon = await _context.Coupons.FindAsync(id);

            if (coupon == null)
            {
                return NotFound(new { message = "Cupón no encontrado" });
            }

            var result = new CouponDto
            {
                Id = coupon.Id,
                Code = coupon.Code,
                Description = coupon.Description,
                DiscountType = coupon.DiscountType.ToString(),
                DiscountValue = coupon.DiscountValue,
                MinimumPurchaseAmount = coupon.MinimumPurchaseAmount,
                MaximumDiscountAmount = coupon.MaximumDiscountAmount,
                ValidFrom = coupon.ValidFrom,
                ValidUntil = coupon.ValidUntil,
                MaxUses = coupon.MaxUses,
                MaxUsesPerUser = coupon.MaxUsesPerUser,
                CurrentUses = coupon.CurrentUses,
                IsActive = coupon.IsActive,
                IsFirstTimeOnly = coupon.IsFirstTimeOnly,
                ApplicableTourId = coupon.ApplicableTourId,
                CreatedAt = coupon.CreatedAt
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener cupón {Id}", id);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Actualiza un cupón (Admin)
    /// </summary>
    [HttpPut("{id}")]
    [Authorize(Policy = "AdminOnly")]
    public async Task<ActionResult<CouponDto>> UpdateCoupon(Guid id, [FromBody] UpdateCouponRequestDto request)
    {
        try
        {
            var coupon = await _context.Coupons.FindAsync(id);

            if (coupon == null)
            {
                return NotFound(new { message = "Cupón no encontrado" });
            }

            // Verificar código único si cambió
            if (!string.IsNullOrEmpty(request.Code) && request.Code.ToUpper() != coupon.Code.ToUpper())
            {
                var existingCoupon = await _context.Coupons
                    .FirstOrDefaultAsync(c => c.Code.ToUpper() == request.Code.ToUpper().Trim() && c.Id != id);

                if (existingCoupon != null)
                {
                    return BadRequest(new { message = "Ya existe un cupón con este código" });
                }

                coupon.Code = request.Code.ToUpper().Trim();
            }

            if (!string.IsNullOrEmpty(request.Description))
                coupon.Description = request.Description;

            if (request.DiscountType.HasValue)
                coupon.DiscountType = request.DiscountType.Value;

            if (request.DiscountValue.HasValue)
                coupon.DiscountValue = request.DiscountValue.Value;

            if (request.MinimumPurchaseAmount.HasValue)
                coupon.MinimumPurchaseAmount = request.MinimumPurchaseAmount;

            if (request.MaximumDiscountAmount.HasValue)
                coupon.MaximumDiscountAmount = request.MaximumDiscountAmount;

            if (request.ValidFrom.HasValue)
                coupon.ValidFrom = DateTime.SpecifyKind(request.ValidFrom.Value, DateTimeKind.Utc);

            if (request.ValidUntil.HasValue)
                coupon.ValidUntil = DateTime.SpecifyKind(request.ValidUntil.Value, DateTimeKind.Utc);

            if (request.MaxUses.HasValue)
                coupon.MaxUses = request.MaxUses;

            if (request.MaxUsesPerUser.HasValue)
                coupon.MaxUsesPerUser = request.MaxUsesPerUser;

            if (request.IsActive.HasValue)
                coupon.IsActive = request.IsActive.Value;

            if (request.IsFirstTimeOnly.HasValue)
                coupon.IsFirstTimeOnly = request.IsFirstTimeOnly.Value;

            if (request.ApplicableTourId.HasValue)
                coupon.ApplicableTourId = request.ApplicableTourId;

            coupon.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            var result = new CouponDto
            {
                Id = coupon.Id,
                Code = coupon.Code,
                Description = coupon.Description,
                DiscountType = coupon.DiscountType.ToString(),
                DiscountValue = coupon.DiscountValue,
                MinimumPurchaseAmount = coupon.MinimumPurchaseAmount,
                MaximumDiscountAmount = coupon.MaximumDiscountAmount,
                ValidFrom = coupon.ValidFrom,
                ValidUntil = coupon.ValidUntil,
                MaxUses = coupon.MaxUses,
                MaxUsesPerUser = coupon.MaxUsesPerUser,
                CurrentUses = coupon.CurrentUses,
                IsActive = coupon.IsActive,
                IsFirstTimeOnly = coupon.IsFirstTimeOnly,
                ApplicableTourId = coupon.ApplicableTourId,
                CreatedAt = coupon.CreatedAt
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al actualizar cupón {Id}", id);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Elimina un cupón (Admin)
    /// </summary>
    [HttpDelete("{id}")]
    [Authorize(Policy = "AdminOnly")]
    public async Task<ActionResult> DeleteCoupon(Guid id)
    {
        try
        {
            var coupon = await _context.Coupons.FindAsync(id);

            if (coupon == null)
            {
                return NotFound(new { message = "Cupón no encontrado" });
            }

            _context.Coupons.Remove(coupon);
            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al eliminar cupón {Id}", id);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }
}

// DTOs
public class ValidateCouponRequestDto
{
    public string Code { get; set; } = string.Empty;
    public decimal PurchaseAmount { get; set; }
    public Guid? TourId { get; set; }
}

public class CouponValidationResponseDto
{
    public bool IsValid { get; set; }
    public Guid CouponId { get; set; }
    public string CouponCode { get; set; } = string.Empty;
    public string DiscountType { get; set; } = string.Empty;
    public decimal DiscountAmount { get; set; }
    public decimal OriginalAmount { get; set; }
    public decimal FinalAmount { get; set; }
    public string Message { get; set; } = string.Empty;
}

public class CouponDto
{
    public Guid Id { get; set; }
    public string Code { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string DiscountType { get; set; } = string.Empty;
    public decimal DiscountValue { get; set; }
    public decimal? MinimumPurchaseAmount { get; set; }
    public decimal? MaximumDiscountAmount { get; set; }
    public DateTime? ValidFrom { get; set; }
    public DateTime? ValidUntil { get; set; }
    public int? MaxUses { get; set; }
    public int? MaxUsesPerUser { get; set; }
    public int CurrentUses { get; set; }
    public bool IsActive { get; set; }
    public bool IsFirstTimeOnly { get; set; }
    public Guid? ApplicableTourId { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreateCouponRequestDto
{
    public string Code { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public CouponType DiscountType { get; set; }
    public decimal DiscountValue { get; set; }
    public decimal? MinimumPurchaseAmount { get; set; }
    public decimal? MaximumDiscountAmount { get; set; }
    public DateTime? ValidFrom { get; set; }
    public DateTime? ValidUntil { get; set; }
    public int? MaxUses { get; set; }
    public int? MaxUsesPerUser { get; set; }
    public bool? IsActive { get; set; }
    public bool? IsFirstTimeOnly { get; set; }
    public Guid? ApplicableTourId { get; set; }
}

public class UpdateCouponRequestDto
{
    public string? Code { get; set; }
    public string? Description { get; set; }
    public CouponType? DiscountType { get; set; }
    public decimal? DiscountValue { get; set; }
    public decimal? MinimumPurchaseAmount { get; set; }
    public decimal? MaximumDiscountAmount { get; set; }
    public DateTime? ValidFrom { get; set; }
    public DateTime? ValidUntil { get; set; }
    public int? MaxUses { get; set; }
    public int? MaxUsesPerUser { get; set; }
    public bool? IsActive { get; set; }
    public bool? IsFirstTimeOnly { get; set; }
    public Guid? ApplicableTourId { get; set; }
}
