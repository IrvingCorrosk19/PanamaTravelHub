# Script para ejecutar fix_all_missing_columns.sql usando .NET
$ErrorActionPreference = 'Stop'

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Corrigiendo Columnas Faltantes en BD" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$sqlFile = Join-Path $projectRoot "database\fix_all_missing_columns.sql"

if (-not (Test-Path $sqlFile)) {
    Write-Host "Error: No se encuentra $sqlFile" -ForegroundColor Red
    exit 1
}

Write-Host "Conectando a PostgreSQL..." -ForegroundColor Yellow
$connectionString = "Host=localhost;Port=5432;Database=PanamaTravelHub;Username=postgres;Password=Panama2020`$"

try {
    $dotnetPath = Get-Command dotnet -ErrorAction SilentlyContinue
    if (-not $dotnetPath) {
        Write-Host "Error: .NET SDK no encontrado" -ForegroundColor Red
        Write-Host "Por favor ejecuta el script SQL manualmente usando pgAdmin o DBeaver" -ForegroundColor Yellow
        Write-Host "Archivo: $sqlFile" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "Usando .NET para ejecutar SQL..." -ForegroundColor Yellow
    
    # Crear un directorio temporal
    $tempDir = Join-Path $env:TEMP "fix_db_$(Get-Date -Format 'yyyyMMddHHmmss')"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    # Copiar el archivo SQL al directorio temporal
    Copy-Item $sqlFile (Join-Path $tempDir "fix.sql") -Force
    
    # Crear csproj
    $csprojContent = @'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Npgsql" Version="8.0.0" />
  </ItemGroup>
</Project>
'@
    
    $csprojFile = Join-Path $tempDir "FixDb.csproj"
    $csprojContent | Out-File -FilePath $csprojFile -Encoding UTF8
    
    # Crear Program.cs que lee el archivo SQL
    $sqlPathEscaped = (Join-Path $tempDir "fix.sql") -replace '\\', '\\\\'
    $csCode = @"
using System;
using System.IO;
using System.Threading.Tasks;
using Npgsql;

class Program
{
    static async Task Main(string[] args)
    {
        var connectionString = "$connectionString";
        var sqlPath = @"$sqlPathEscaped";
        
        if (!File.Exists(sqlPath)) {
            Console.WriteLine($"Error: No se encuentra el archivo SQL en {sqlPath}");
            Environment.Exit(1);
        }
        
        var sql = await File.ReadAllTextAsync(sqlPath);
        
        Console.WriteLine("Conectando a la base de datos...");
        await using var conn = new NpgsqlConnection(connectionString);
        await conn.OpenAsync();
        Console.WriteLine("Conectado exitosamente.");

        Console.WriteLine("Ejecutando script SQL...");
        await using var cmd = new NpgsqlCommand(sql, conn);
        
        try
        {
            await cmd.ExecuteNonQueryAsync();
            Console.WriteLine("Script ejecutado exitosamente.");
            Console.WriteLine("Todas las columnas faltantes han sido agregadas.");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error: {ex.Message}");
            if (ex.InnerException != null) {
                Console.WriteLine($"Inner: {ex.InnerException.Message}");
            }
            Environment.Exit(1);
        }
    }
}
"@
    
    $mainFile = Join-Path $tempDir "Program.cs"
    $csCode | Out-File -FilePath $mainFile -Encoding UTF8
    
    Push-Location $tempDir
    try {
        Write-Host "Restaurando paquetes..." -ForegroundColor Yellow
        dotnet restore 2>&1 | Out-Null
        
        Write-Host "Compilando..." -ForegroundColor Yellow
        $buildOutput = dotnet build -c Release 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host $buildOutput -ForegroundColor Red
            exit 1
        }
        
        Write-Host "Ejecutando..." -ForegroundColor Yellow
        dotnet run -c Release --no-build
    } finally {
        Pop-Location
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n========================================" -ForegroundColor Green
        Write-Host "Proceso completado exitosamente" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
    } else {
        Write-Host "`nError al ejecutar el script" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack: $($_.Exception.StackTrace)" -ForegroundColor Gray
    Write-Host "`nPor favor ejecuta el script SQL manualmente:" -ForegroundColor Yellow
    Write-Host "  $sqlFile" -ForegroundColor Yellow
    exit 1
}
