using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Infrastructure.Data;
using System.Text.RegularExpressions;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CategoriesController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<CategoriesController> _logger;

    public CategoriesController(ApplicationDbContext context, ILogger<CategoriesController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Obtiene todas las categorías activas
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<CategoryDto>>> GetCategories()
    {
        var categories = await _context.TourCategories
            .Where(c => c.IsActive)
            .OrderBy(c => c.DisplayOrder)
            .ThenBy(c => c.Name)
            .Select(c => new CategoryDto
            {
                Id = c.Id,
                Name = c.Name,
                Slug = c.Slug,
                Description = c.Description
            })
            .ToListAsync();

        return Ok(categories);
    }

    /// <summary>
    /// Obtiene todos los tags
    /// </summary>
    [HttpGet("tags")]
    public async Task<ActionResult<IEnumerable<TagDto>>> GetTags()
    {
        var tags = await _context.TourTags
            .OrderBy(t => t.Name)
            .Select(t => new TagDto
            {
                Id = t.Id,
                Name = t.Name,
                Slug = t.Slug
            })
            .ToListAsync();

        return Ok(tags);
    }

    /// <summary>
    /// Obtiene tours por categoría
    /// </summary>
    [HttpGet("{slug}/tours")]
    public async Task<ActionResult<IEnumerable<TourDto>>> GetToursByCategory(string slug)
    {
        var category = await _context.TourCategories
            .FirstOrDefaultAsync(c => c.Slug == slug && c.IsActive);

        if (category == null)
        {
            return NotFound(new { message = "Categoría no encontrada" });
        }

        var tours = await _context.Tours
            .Include(t => t.TourImages)
            .Include(t => t.TourCategoryAssignments)
                .ThenInclude(a => a.Category)
            .Where(t => t.IsActive && t.TourCategoryAssignments.Any(a => a.CategoryId == category.Id))
            .Select(t => new CategoryTourDto
            {
                Id = t.Id,
                Name = t.Name,
                Description = t.Description,
                Price = t.Price,
                DurationHours = t.DurationHours,
                Location = t.Location,
                ImageUrl = t.TourImages.FirstOrDefault(i => i.IsPrimary)!.ImageUrl,
                AvailableSpots = t.AvailableSpots
            })
            .ToListAsync();

        return Ok(tours);
    }
}

// DTOs
public class CategoryDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public string? Description { get; set; }
}

public class TagDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
}

// DTO específico para tours por categoría (evita duplicación con TourDto en ToursController)
// TODO: Mover a un archivo DTOs compartido
public class CategoryTourDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int DurationHours { get; set; }
    public string? Location { get; set; }
    public string? ImageUrl { get; set; }
    public int AvailableSpots { get; set; }
}
