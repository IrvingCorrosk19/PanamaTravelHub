# Migración de Base de Datos: Render → Local

## Resumen

Este documento describe cómo migrar la base de datos de Render a una instancia local de PostgreSQL.

## Requisitos Previos

1. PostgreSQL instalado localmente (versión 18 recomendada)
2. PostgreSQL binarios en PATH o ruta completa: `C:\Program Files\PostgreSQL\18\bin\`
3. Base de datos local creada o permisos para crearla
4. Credenciales de acceso a Render (ya configuradas en los scripts)

## Configuración Local

**Cadena de conexión local:**
```
Host=localhost;Port=5432;Database=PanamaTravelHub;Username=postgres;Password=Panama2020$
```

## Proceso de Migración

### Opción 1: Script Completo (Recomendado)

Ejecutar el script completo que hace todo automáticamente:

```powershell
.\scripts\migrate-render-to-local.ps1
```

Este script:
1. Exporta la base de datos de Render a un archivo SQL
2. Crea/recrea la base de datos local si es necesario
3. Importa todos los datos al servidor local

### Opción 2: Pasos Manuales

#### Paso 1: Exportar de Render

```powershell
.\scripts\export-render-db.ps1
```

Esto creará un archivo en `database/render-backup-YYYYMMDD-HHMMSS.sql`

#### Paso 2: Importar a Local

```powershell
.\scripts\import-to-local-db.ps1 [archivo.sql]
```

Si no especificas el archivo, usará el más reciente de `database/`

### Opción 3: Comandos Manuales

#### Exportar de Render

```powershell
$env:PGPASSWORD = "YFxc28DdPtabZS11XfVxywP5SnS53yZP"
pg_dump -h dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com `
        -U panamatravelhub_user `
        -d panamatravelhub `
        --no-owner --no-privileges --clean --if-exists `
        -f database/render-backup.sql
```

#### Crear Base de Datos Local

```powershell
$env:PGPASSWORD = "Panama2020$"
createdb -h localhost -p 5432 -U postgres PanamaTravelHub
psql -h localhost -p 5432 -U postgres -d PanamaTravelHub -c "CREATE EXTENSION IF NOT EXISTS ""uuid-ossp"";"
```

#### Importar a Local

```powershell
$env:PGPASSWORD = "Panama2020$"
psql -h localhost -p 5432 -U postgres -d PanamaTravelHub -f database/render-backup.sql
```

## Verificación

Después de la migración, verifica que:

1. **Las tablas existen:**
```powershell
$env:PGPASSWORD = "Panama2020$"
psql -h localhost -p 5432 -U postgres -d PanamaTravelHub -c "\dt"
```

2. **Los usuarios están presentes:**
```powershell
$env:PGPASSWORD = "Panama2020$"
psql -h localhost -p 5432 -U postgres -d PanamaTravelHub -c "SELECT email, first_name, last_name FROM users;"
```

3. **La aplicación funciona:**
   - Ejecutar la aplicación en modo Development
   - Verificar que se conecta a la BD local
   - Probar login con usuarios existentes

## Configuración de la Aplicación

Después de la migración, la aplicación ya está configurada para usar la BD local cuando está en modo `Development`:

**appsettings.Development.json:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=PanamaTravelHub;Username=postgres;Password=Panama2020$"
  }
}
```

## Notas Importantes

1. **El script eliminará y recreará la BD local** si ya existe (con confirmación)
2. **Los permisos y ownerships no se migran** (usando `--no-owner --no-privileges`)
3. **Las extensiones necesarias** se habilitan automáticamente (uuid-ossp)
4. **El proceso puede tardar varios minutos** dependiendo del tamaño de la BD
5. **Asegúrate de tener una copia de seguridad** antes de ejecutar si hay datos importantes locales

## Solución de Problemas

### Error: "password authentication failed"
- Verifica que la contraseña local sea `Panama2020$`
- Verifica que el usuario `postgres` tenga permisos

### Error: "database already exists"
- El script pregunta si deseas eliminar y recrear
- Puedes hacerlo manualmente: `dropdb -U postgres PanamaTravelHub`

### Error: "extension uuid-ossp does not exist"
- Instala las extensiones contrib de PostgreSQL
- En Windows, asegúrate de que `share/extension/uuid-ossp.sql` esté disponible

### Error de encoding
- El dump se crea en UTF-8
- Asegúrate de que tu PostgreSQL local esté configurado con encoding UTF-8

## Credenciales

**Render (origen):**
- Host: dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com
- Database: panamatravelhub
- Username: panamatravelhub_user
- Password: YFxc28DdPtabZS11XfVxywP5SnS53yZP

**Local (destino):**
- Host: localhost
- Port: 5432
- Database: PanamaTravelHub
- Username: postgres
- Password: Panama2020$

---

**Última actualización:** 2025-01-XX

