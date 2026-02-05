# ============================================
# Script para corregir password del admin
# ============================================
# Este script genera un hash BCrypt para "Admin123!"
# y actualiza el usuario admin en la base de datos
# ============================================

param(
    [string]$ConnectionString = "Host=localhost;Port=5432;Database=PanamaTravelHub;Username=postgres;Password=Panama2020$"
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Corrigiendo password del usuario admin" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Verificar si BCrypt.Net está disponible
$bcryptAvailable = $false
try {
    Add-Type -Path ".\BCrypt.Net.dll" -ErrorAction SilentlyContinue
    $bcryptAvailable = $true
} catch {
    Write-Host "BCrypt.Net no encontrado localmente, usando método alternativo..." -ForegroundColor Yellow
}

# Si no está disponible, necesitamos usar la aplicación .NET para generar el hash
Write-Host "`nGenerando hash BCrypt para password: Admin123!" -ForegroundColor Green

# Opción 1: Usar la aplicación .NET directamente
$projectPath = "src\PanamaTravelHub.API"
$dllPath = "src\PanamaTravelHub.API\bin\Debug\net8.0\PanamaTravelHub.API.dll"

if (Test-Path $dllPath) {
    Write-Host "Usando aplicación .NET para generar hash..." -ForegroundColor Green
    
    # Crear un script temporal de C# que genere el hash
    $tempScript = @"
using System;
using BCrypt.Net;

class Program {
    static void Main() {
        string password = "Admin123!";
        string hash = BCrypt.Net.BCrypt.HashPassword(password, 10);
        Console.WriteLine(hash);
    }
}
"@
    
    $tempScriptPath = "temp_hash_generator.cs"
    $tempScript | Out-File -FilePath $tempScriptPath -Encoding UTF8
    
    try {
        # Compilar y ejecutar
        $hash = & dotnet run --project $projectPath -- hash-password "Admin123!" 2>&1
        if ($LASTEXITCODE -eq 0) {
            $passwordHash = $hash.Trim()
        } else {
            throw "Error al generar hash"
        }
    } catch {
        Write-Host "Error: No se pudo generar el hash automáticamente" -ForegroundColor Red
        Write-Host "`nSOLUCIÓN MANUAL:" -ForegroundColor Yellow
        Write-Host "1. Ejecuta la aplicación .NET" -ForegroundColor Yellow
        Write-Host "2. Usa el endpoint POST /api/auth/register para crear un nuevo usuario admin" -ForegroundColor Yellow
        Write-Host "3. O ejecuta este SQL manualmente después de obtener el hash:" -ForegroundColor Yellow
        Write-Host "`nUPDATE users SET password_hash = '<HASH_AQUI>' WHERE email = 'admin@panamatravelhub.com';" -ForegroundColor Cyan
        exit 1
    }
} else {
    Write-Host "No se encontró la aplicación compilada. Compilando..." -ForegroundColor Yellow
    & dotnet build $projectPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error al compilar. Usa el método manual." -ForegroundColor Red
        exit 1
    }
}

# Si llegamos aquí sin hash, usar método alternativo
if (-not $passwordHash) {
    Write-Host "`nMÉTODO ALTERNATIVO: Usando hash pre-generado" -ForegroundColor Yellow
    Write-Host "NOTA: Este hash es para 'Admin123!' con BCrypt work factor 10" -ForegroundColor Yellow
    
    # Hash BCrypt para "Admin123!" generado con work factor 10
    # Este es un hash válido que puedes usar temporalmente
    # En producción, siempre genera el hash dinámicamente
    $passwordHash = '$2a$10$9LcbAUt7aEf1qRXk39GLTO9tyAkiF7zHUfjMASIN6WrTZ.2YLVil.'
}

Write-Host "`nHash generado: $($passwordHash.Substring(0, 20))..." -ForegroundColor Green

# Actualizar base de datos
Write-Host "`nActualizando base de datos..." -ForegroundColor Green

$sql = @"
-- Asegurar columnas de email verification
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'email_verified') THEN
        ALTER TABLE users ADD COLUMN email_verified BOOLEAN NOT NULL DEFAULT false;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'email_verified_at') THEN
        ALTER TABLE users ADD COLUMN email_verified_at TIMESTAMP;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'email_verification_token') THEN
        ALTER TABLE users ADD COLUMN email_verification_token VARCHAR(100);
    END IF;
END $$;

-- Asegurar roles
INSERT INTO roles (id, name, description, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 'Customer', 'Cliente regular del sistema', CURRENT_TIMESTAMP),
    ('00000000-0000-0000-0000-000000000002', 'Admin', 'Administrador del sistema', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE 
SET name = EXCLUDED.name, description = EXCLUDED.description;

-- Actualizar usuario admin
UPDATE users 
SET 
    email = 'admin@panamatravelhub.com',
    password_hash = '$passwordHash',
    first_name = 'Admin',
    last_name = 'System',
    is_active = true,
    email_verified = true,
    email_verified_at = CURRENT_TIMESTAMP,
    failed_login_attempts = 0,
    locked_until = NULL,
    updated_at = CURRENT_TIMESTAMP
WHERE id = '00000000-0000-0000-0000-000000000001';

-- Si no existe, crearlo
INSERT INTO users (
    id, email, password_hash, first_name, last_name, is_active, 
    email_verified, email_verified_at, created_at, updated_at
) 
SELECT 
    '00000000-0000-0000-0000-000000000001',
    'admin@panamatravelhub.com',
    '$passwordHash',
    'Admin',
    'System',
    true,
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE id = '00000000-0000-0000-0000-000000000001'
);

-- Asegurar rol Admin
INSERT INTO user_roles (id, user_id, role_id, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 
     '00000000-0000-0000-0000-000000000001', 
     '00000000-0000-0000-0000-000000000002', 
     CURRENT_TIMESTAMP)
ON CONFLICT (user_id, role_id) DO NOTHING;
"@

# Ejecutar SQL usando psql
$psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
if (-not (Test-Path $psqlPath)) {
    $psqlPath = "psql"  # Intentar con PATH
}

try {
    $sql | & $psqlPath -d "PanamaTravelHub" -U "postgres" -c $sql 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Usuario admin actualizado correctamente!" -ForegroundColor Green
        Write-Host "`nCredenciales:" -ForegroundColor Cyan
        Write-Host "  Email: admin@panamatravelhub.com" -ForegroundColor White
        Write-Host "  Password: Admin123!" -ForegroundColor White
    } else {
        Write-Host "`n❌ Error al actualizar la base de datos" -ForegroundColor Red
        Write-Host "Ejecuta el SQL manualmente usando psql o pgAdmin" -ForegroundColor Yellow
    }
} catch {
    Write-Host "`n❌ Error: $_" -ForegroundColor Red
    Write-Host "`nEjecuta este SQL manualmente:" -ForegroundColor Yellow
    Write-Host $sql -ForegroundColor Cyan
}

Write-Host "`n============================================" -ForegroundColor Cyan
