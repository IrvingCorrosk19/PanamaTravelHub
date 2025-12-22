using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Infrastructure;
using PanamaTravelHub.Infrastructure.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// CORS para permitir el frontend
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        var allowedOrigins = new List<string>
        {
            "http://localhost:5000",
            "http://localhost:5001",
            "https://localhost:5001",
            "http://localhost:5018",
            "https://localhost:7009"
        };

        // Agregar dominio de Render si está configurado
        var renderUrl = builder.Configuration["RENDER_URL"];
        if (!string.IsNullOrEmpty(renderUrl))
        {
            allowedOrigins.Add(renderUrl);
        }

        // En producción, permitir cualquier origen de Render
        if (builder.Environment.IsProduction())
        {
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        }
        else
        {
            policy.WithOrigins(allowedOrigins.ToArray())
                  .AllowAnyMethod()
                  .AllowAnyHeader()
                  .AllowCredentials();
        }
    });
});

// Add Infrastructure (DbContext, Repositories, etc.)
builder.Services.AddInfrastructure(builder.Configuration);

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Habilitar archivos estáticos para el frontend
app.UseDefaultFiles();
app.UseStaticFiles();

app.UseHttpsRedirection();

// CORS debe ir antes de UseAuthorization
app.UseCors("AllowFrontend");

app.UseAuthorization();
app.MapControllers();

// Health check endpoint
app.MapGet("/health", () => Results.Ok(new { status = "healthy", timestamp = DateTime.UtcNow }));

// Fallback para SPA
app.MapFallbackToFile("index.html");

// Aplicar migraciones automáticamente solo en desarrollo
// En producción, las tablas ya están creadas mediante scripts SQL
if (app.Environment.IsDevelopment())
{
    using (var scope = app.Services.CreateScope())
    {
        var services = scope.ServiceProvider;
        var logger = services.GetRequiredService<ILogger<Program>>();
        var context = services.GetRequiredService<ApplicationDbContext>();
        
        try
        {
            logger.LogInformation("Aplicando migraciones a la base de datos...");
            await context.Database.MigrateAsync();
            logger.LogInformation("Migraciones aplicadas exitosamente!");
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error al aplicar migraciones. Continuando sin migraciones...");
            // En desarrollo, no lanzamos excepción para permitir continuar
        }
    }
}

app.Run();
