@echo off
REM Script para crear la tabla password_reset_tokens en Render PostgreSQL
REM Ejecutar desde la raíz del proyecto

echo Conectando a Render PostgreSQL...
echo.

set PGPASSWORD=YFxc28DdPtabZS11XfVxywP5SnS53yZP
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com -U panamatravelhub_user -d panamatravelhub -f "src\PanamaTravelHub.Infrastructure\Migrations\AddPasswordResetTokens.sql"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ==========================================
    echo Tabla password_reset_tokens creada exitosamente!
    echo ==========================================
) else (
    echo.
    echo ==========================================
    echo Error al ejecutar el script SQL
    echo ==========================================
)

pause
