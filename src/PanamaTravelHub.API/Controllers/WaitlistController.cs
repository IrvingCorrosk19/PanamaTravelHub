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
[Route("api/waitlist")]
public class WaitlistController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<WaitlistController> _logger;

    public WaitlistController(
        ApplicationDbContext context,
        ILogger<WaitlistController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Registra un usuario en la lista de espera
    /// </summary>
    [HttpPost]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult<WaitlistDto>> AddToWaitlist([FromBody] AddToWaitlistRequestDto request)
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            // Verificar que el tour existe
            var tour = await _context.Tours.FindAsync(request.TourId);
            if (tour == null)
            {
                return NotFound(new { message = "Tour no encontrado" });
            }

            // Verificar que el tour date existe si se proporciona
            if (request.TourDateId.HasValue)
            {
                var tourDate = await _context.TourDates
                    .FirstOrDefaultAsync(td => td.Id == request.TourDateId.Value && td.TourId == request.TourId);

                if (tourDate == null)
                {
                    return NotFound(new { message = "Fecha de tour no encontrada" });
                }
            }

            // Verificar que el usuario no esté ya en la lista de espera para este tour/fecha
            var existingWaitlist = await _context.Waitlist
                .FirstOrDefaultAsync(w => w.TourId == request.TourId &&
                                         w.UserId == userId &&
                                         (request.TourDateId == null || w.TourDateId == request.TourDateId) &&
                                         w.IsActive);

            if (existingWaitlist != null)
            {
                return BadRequest(new { message = "Ya estás en la lista de espera para este tour" });
            }

            // Obtener la siguiente prioridad (basada en fecha de registro)
            var maxPriority = await _context.Waitlist
                .Where(w => w.TourId == request.TourId &&
                           (request.TourDateId == null || w.TourDateId == request.TourDateId) &&
                           w.IsActive)
                .MaxAsync(w => (int?)w.Priority) ?? -1;

            var waitlist = new Waitlist
            {
                TourId = request.TourId,
                TourDateId = request.TourDateId,
                UserId = userId,
                NumberOfParticipants = request.NumberOfParticipants,
                Priority = maxPriority + 1,
                IsActive = true
            };

            _context.Waitlist.Add(waitlist);
            await _context.SaveChangesAsync();

            // Cargar relaciones
            await _context.Entry(waitlist)
                .Reference(w => w.Tour)
                .LoadAsync();
            await _context.Entry(waitlist)
                .Reference(w => w.User)
                .LoadAsync();

            var result = new WaitlistDto
            {
                Id = waitlist.Id,
                TourId = waitlist.TourId,
                TourName = waitlist.Tour.Name,
                TourDateId = waitlist.TourDateId,
                NumberOfParticipants = waitlist.NumberOfParticipants,
                Priority = waitlist.Priority,
                IsNotified = waitlist.IsNotified,
                CreatedAt = waitlist.CreatedAt
            };

            return CreatedAtAction(nameof(GetWaitlist), new { id = waitlist.Id }, result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al agregar a lista de espera");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Obtiene la lista de espera del usuario actual
    /// </summary>
    [HttpGet("my")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult<IEnumerable<WaitlistDto>>> GetMyWaitlist()
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var waitlist = await _context.Waitlist
                .Include(w => w.Tour)
                .Include(w => w.TourDate)
                .Where(w => w.UserId == userId && w.IsActive)
                .OrderBy(w => w.Priority)
                .Select(w => new WaitlistDto
                {
                    Id = w.Id,
                    TourId = w.TourId,
                    TourName = w.Tour.Name,
                    TourDateId = w.TourDateId,
                    TourDateTime = w.TourDate != null ? w.TourDate.TourDateTime : null,
                    NumberOfParticipants = w.NumberOfParticipants,
                    Priority = w.Priority,
                    IsNotified = w.IsNotified,
                    CreatedAt = w.CreatedAt
                })
                .ToListAsync();

            return Ok(waitlist);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener lista de espera");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Obtiene una entrada específica de la lista de espera
    /// </summary>
    [HttpGet("{id}")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult<WaitlistDto>> GetWaitlist(Guid id)
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var waitlist = await _context.Waitlist
                .Include(w => w.Tour)
                .Include(w => w.TourDate)
                .FirstOrDefaultAsync(w => w.Id == id);

            if (waitlist == null)
            {
                return NotFound(new { message = "Entrada de lista de espera no encontrada" });
            }

            // Verificar propiedad o rol admin
            if (waitlist.UserId != userId && !User.IsInRole("Admin"))
            {
                return StatusCode(403, new { message = "No tienes permisos para ver esta entrada" });
            }

            var result = new WaitlistDto
            {
                Id = waitlist.Id,
                TourId = waitlist.TourId,
                TourName = waitlist.Tour.Name,
                TourDateId = waitlist.TourDateId,
                TourDateTime = waitlist.TourDate != null ? waitlist.TourDate.TourDateTime : null,
                NumberOfParticipants = waitlist.NumberOfParticipants,
                Priority = waitlist.Priority,
                IsNotified = waitlist.IsNotified,
                CreatedAt = waitlist.CreatedAt
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener entrada de lista de espera {Id}", id);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Elimina una entrada de la lista de espera
    /// </summary>
    [HttpDelete("{id}")]
    [Authorize(Policy = "AdminOrCustomer")]
    public async Task<ActionResult> RemoveFromWaitlist(Guid id)
    {
        try
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? 
                             User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized();
            }

            var waitlist = await _context.Waitlist.FindAsync(id);

            if (waitlist == null)
            {
                return NotFound(new { message = "Entrada de lista de espera no encontrada" });
            }

            // Verificar propiedad o rol admin
            if (waitlist.UserId != userId && !User.IsInRole("Admin"))
            {
                return StatusCode(403, new { message = "No tienes permisos para eliminar esta entrada" });
            }

            // En lugar de eliminar, desactivar
            waitlist.IsActive = false;
            waitlist.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al eliminar de lista de espera {Id}", id);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Obtiene todas las listas de espera (Admin)
    /// </summary>
    [HttpGet]
    [Authorize]
    public async Task<ActionResult<IEnumerable<WaitlistDto>>> GetAllWaitlist(
        [FromQuery] Guid? tourId = null,
        [FromQuery] bool? isActive = null)
    {
        try
        {
            var query = _context.Waitlist
                .Include(w => w.Tour)
                .Include(w => w.TourDate)
                .Include(w => w.User)
                .AsQueryable();

            if (tourId.HasValue)
            {
                query = query.Where(w => w.TourId == tourId.Value);
            }

            if (isActive.HasValue)
            {
                query = query.Where(w => w.IsActive == isActive.Value);
            }

            var waitlist = await query
                .OrderBy(w => w.Priority)
                .Select(w => new WaitlistDto
                {
                    Id = w.Id,
                    TourId = w.TourId,
                    TourName = w.Tour.Name,
                    TourDateId = w.TourDateId,
                    TourDateTime = w.TourDate != null ? w.TourDate.TourDateTime : null,
                    NumberOfParticipants = w.NumberOfParticipants,
                    Priority = w.Priority,
                    IsActive = w.IsActive,
                    IsNotified = w.IsNotified,
                    UserEmail = w.User.Email,
                    UserName = $"{w.User.FirstName} {w.User.LastName}",
                    CreatedAt = w.CreatedAt
                })
                .ToListAsync();

            return Ok(waitlist);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener todas las listas de espera");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }
}

// DTOs
public class AddToWaitlistRequestDto
{
    public Guid TourId { get; set; }
    public Guid? TourDateId { get; set; }
    public int NumberOfParticipants { get; set; }
}

public class WaitlistDto
{
    public Guid Id { get; set; }
    public Guid TourId { get; set; }
    public string TourName { get; set; } = string.Empty;
    public Guid? TourDateId { get; set; }
    public DateTime? TourDateTime { get; set; }
    public int NumberOfParticipants { get; set; }
    public int Priority { get; set; }
    public bool IsActive { get; set; }
    public bool IsNotified { get; set; }
    public string? UserEmail { get; set; }
    public string? UserName { get; set; }
    public DateTime CreatedAt { get; set; }
}
