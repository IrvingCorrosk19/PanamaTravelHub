using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Infrastructure.Data;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/admin/audit")]
[Authorize(Policy = "AdminOnly")]
public class AuditController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<AuditController> _logger;

    public AuditController(
        ApplicationDbContext context,
        ILogger<AuditController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Obtiene los logs de auditoría con filtros opcionales
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<AuditLogDto>>> GetAuditLogs(
        [FromQuery] Guid? userId = null,
        [FromQuery] string? entityType = null,
        [FromQuery] Guid? entityId = null,
        [FromQuery] string? action = null,
        [FromQuery] DateTime? startDate = null,
        [FromQuery] DateTime? endDate = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50)
    {
        try
        {
            var query = _context.AuditLogs.AsQueryable();

            // Aplicar filtros
            if (userId.HasValue)
            {
                query = query.Where(a => a.UserId == userId.Value);
            }

            if (!string.IsNullOrEmpty(entityType))
            {
                query = query.Where(a => a.EntityType == entityType);
            }

            if (entityId.HasValue)
            {
                query = query.Where(a => a.EntityId == entityId.Value);
            }

            if (!string.IsNullOrEmpty(action))
            {
                query = query.Where(a => a.Action == action);
            }

            if (startDate.HasValue)
            {
                query = query.Where(a => a.CreatedAt >= startDate.Value);
            }

            if (endDate.HasValue)
            {
                query = query.Where(a => a.CreatedAt <= endDate.Value);
            }

            // Ordenar por fecha descendente
            query = query.OrderByDescending(a => a.CreatedAt);

            // Paginación
            var totalCount = await query.CountAsync();
            var auditLogs = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Include(a => a.User)
                .ToListAsync();

            var result = auditLogs.Select(a => new AuditLogDto
            {
                Id = a.Id,
                UserId = a.UserId,
                UserEmail = a.User?.Email,
                EntityType = a.EntityType,
                EntityId = a.EntityId,
                Action = a.Action,
                BeforeState = a.BeforeState,
                AfterState = a.AfterState,
                IpAddress = a.IpAddress,
                UserAgent = a.UserAgent,
                CorrelationId = a.CorrelationId,
                CreatedAt = a.CreatedAt
            });

            Response.Headers["X-Total-Count"] = totalCount.ToString();
            Response.Headers["X-Page"] = page.ToString();
            Response.Headers["X-Page-Size"] = pageSize.ToString();

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener logs de auditoría");
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }

    /// <summary>
    /// Obtiene un log de auditoría específico
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<AuditLogDto>> GetAuditLog(Guid id)
    {
        try
        {
            var auditLog = await _context.AuditLogs
                .Include(a => a.User)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (auditLog == null)
            {
                return NotFound(new { message = "Log de auditoría no encontrado" });
            }

            var result = new AuditLogDto
            {
                Id = auditLog.Id,
                UserId = auditLog.UserId,
                UserEmail = auditLog.User?.Email,
                EntityType = auditLog.EntityType,
                EntityId = auditLog.EntityId,
                Action = auditLog.Action,
                BeforeState = auditLog.BeforeState,
                AfterState = auditLog.AfterState,
                IpAddress = auditLog.IpAddress,
                UserAgent = auditLog.UserAgent,
                CorrelationId = auditLog.CorrelationId,
                CreatedAt = auditLog.CreatedAt
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener log de auditoría {Id}", id);
            return StatusCode(500, new { message = "Error interno del servidor" });
        }
    }
}

public class AuditLogDto
{
    public Guid Id { get; set; }
    public Guid? UserId { get; set; }
    public string? UserEmail { get; set; }
    public string EntityType { get; set; } = string.Empty;
    public Guid EntityId { get; set; }
    public string Action { get; set; } = string.Empty;
    public string? BeforeState { get; set; }
    public string? AfterState { get; set; }
    public string? IpAddress { get; set; }
    public string? UserAgent { get; set; }
    public Guid? CorrelationId { get; set; }
    public DateTime CreatedAt { get; set; }
}

