# Instrucciones para Ejecutar la Migración Manualmente

Debido a restricciones de PowerShell o tiempo de ejecución, puedes ejecutar los comandos manualmente:

## Opción 1: Usar PowerShell (Recomendado)

Abre PowerShell como Administrador y ejecuta:

```powershell
# Cambiar al directorio del proyecto
cd C:\Proyectos\PanamaTravelHub\PanamaTravelHub

# 1. Exportar de Render
$env:PGPASSWORD = "YFxc28DdPtabZS11XfVxywP5SnS53yZP"
& "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" `
  -h dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com `
  -U panamatravelhub_user `
  -d panamatravelhub `
  --no-owner --no-privileges --clean --if-exists `
  --format=plain `
  -f database\render-backup.sql

# 2. Crear base de datos local (si no existe)
$env:PGPASSWORD = "Panama2020$"
& "C:\Program Files\PostgreSQL\18\bin\createdb.exe" -h localhost -p 5432 -U postgres PanamaTravelHub

# 3. Habilitar extensiones
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -p 5432 -U postgres -d PanamaTravelHub -c "CREATE EXTENSION IF NOT EXISTS ""uuid-ossp"";"

# 4. Importar el dump
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -p 5432 -U postgres -d PanamaTravelHub -f database\render-backup.sql
```

## Opción 2: Usar pgAdmin o DBeaver

1. **Conectar a Render:**
   - Host: dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com
   - Port: 5432
   - Database: panamatravelhub
   - Username: panamatravelhub_user
   - Password: YFxc28DdPtabZS11XfVxywP5SnS53yZP

2. **Exportar:**
   - Click derecho en la base de datos → Backup
   - Selecciona formato "Plain" o "SQL"
   - Guarda el archivo como `render-backup.sql`

3. **Conectar a Local:**
   - Host: localhost
   - Port: 5432
   - Database: PanamaTravelHub (crear si no existe)
   - Username: postgres
   - Password: Panama2020$

4. **Importar:**
   - Click derecho en la base de datos → Restore
   - Selecciona el archivo `render-backup.sql`
   - Ejecuta

## Opción 3: Comandos SQL directos (para tablas específicas)

Si solo necesitas migrar datos específicos, puedes ejecutar queries SELECT en Render y INSERT en local.

## Verificación

Después de la migración, verifica:

```powershell
$env:PGPASSWORD = "Panama2020$"
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -p 5432 -U postgres -d PanamaTravelHub -c "\dt"
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -p 5432 -U postgres -d PanamaTravelHub -c "SELECT COUNT(*) FROM users;"
```

