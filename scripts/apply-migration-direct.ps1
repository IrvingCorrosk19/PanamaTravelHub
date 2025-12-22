# Script para aplicar migraciones directamente usando el DbContext
Write-Host "Aplicando migraciones a la base de datos..." -ForegroundColor Green

$projectPath = "src/PanamaTravelHub.API/PanamaTravelHub.API.csproj"

# Crear un programa temporal que solo aplica migraciones
$tempProgram = @"
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using PanamaTravelHub.Infrastructure;
using PanamaTravelHub.Infrastructure.Data;

var builder = Host.CreateApplicationBuilder(args);

// Configurar servicios
builder.Services.AddInfrastructure(builder.Configuration);

var host = builder.Build();

using var scope = host.Services.CreateScope();
var services = scope.ServiceProvider;
var logger = services.GetRequiredService<ILogger<Program>>();
var context = services.GetRequiredService<ApplicationDbContext>();

try
{
    logger.LogInformation("Aplicando migraciones...");
    await context.Database.MigrateAsync();
    logger.LogInformation("Migraciones aplicadas exitosamente!");
}
catch (Exception ex)
{
    logger.LogError(ex, "Error al aplicar migraciones");
    Environment.Exit(1);
}
"@

$tempFile = "TempMigrate.cs"
$tempProgram | Out-File -FilePath $tempFile -Encoding UTF8

try {
    # Compilar y ejecutar
    dotnet run --project $projectPath --no-build 2>&1 | Out-Null
    
    # Si llegamos aquí, intentar ejecutar directamente
    Write-Host "Intentando aplicar migraciones..." -ForegroundColor Yellow
    dotnet run --project $projectPath
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "Por favor, ejecuta la aplicación manualmente o usa los scripts SQL en database/" -ForegroundColor Yellow
} finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile
    }
}
