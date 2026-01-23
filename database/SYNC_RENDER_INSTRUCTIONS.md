# Instrucciones para Sincronizar Base de Datos de Render

## Resumen

Este documento explica cómo sincronizar la base de datos de Render con la base de datos local, aplicando todos los cambios que están en localhost pero faltan en Render.

## Credenciales

### Localhost
```
Host: localhost
Port: 5432
Database: PanamaTravelHub
Username: postgres
Password: Panama2020$
```

### Render (Producción)
```
Host: dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com
Port: 5432
Database: panamatravelhub
Username: panamatravelhub_user
Password: YFxc28DdPtabZS11XfVxywP5SnS53yZP
SSL Mode: Require
Trust Server Certificate: true
```

## Cambios a Aplicar

El script `12_sync_render_database.sql` aplica los siguientes cambios:

### 1. Campos de Logo en `home_page_content`
- `logo_url` - Logo principal para navbar
- `favicon_url` - Favicon del sitio
- `logo_url_social` - Logo para redes sociales (Open Graph)
- `hero_image_url` - Imagen hero de la página principal

### 2. Nueva Tabla: `media_files`
- Biblioteca de archivos multimedia del CMS
- Permite gestionar imágenes y otros archivos

### 3. Nueva Tabla: `pages`
- Páginas dinámicas del CMS
- Permite crear páginas personalizadas con SEO

### 4. Nueva Tabla: `countries` + Campo en `bookings`
- Tabla de países con códigos ISO
- Campo `country_id` en `bookings` para identificar el país de origen de la reserva
- Incluye 20 países predefinidos (América Central, América del Sur, España, etc.)

### 5. Nueva Tabla: `sms_notifications`
- Tabla para almacenar notificaciones SMS
- Similar a `email_notifications` pero para SMS
- Soporta múltiples estados y reintentos

### 6. Campo `tour_date` en `tours`
- Fecha principal del tour
- Permite tener una fecha principal además de las fechas específicas en `tour_dates`

### 7. Campo `includes` en `tours`
- Campo de texto para almacenar "Qué Incluye" del tour
- Permite listar los items incluidos en el tour

## Cómo Aplicar el Script

### Opción 1: Usando psql (Recomendado)

```bash
# Conectar a la base de datos de Render
psql "Host=dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com;Port=5432;Database=panamatravelhub;Username=panamatravelhub_user;Password=YFxc28DdPtabZS11XfVxywP5SnS53yZP;SSL Mode=Require;Trust Server Certificate=true" -f database/12_sync_render_database.sql
```

### Opción 2: Usando pgAdmin o DBeaver

1. Conectar a la base de datos de Render usando las credenciales de producción
2. Abrir el archivo `database/12_sync_render_database.sql`
3. Ejecutar el script completo

### Opción 3: Desde el código (usando Npgsql)

Si tienes acceso programático, puedes ejecutar el script desde la aplicación:

```csharp
var script = await File.ReadAllTextAsync("database/12_sync_render_database.sql");
await context.Database.ExecuteSqlRawAsync(script);
```

## Verificación

Después de ejecutar el script, verifica que:

1. ✅ Las columnas se agregaron correctamente:
   ```sql
   SELECT column_name 
   FROM information_schema.columns 
   WHERE table_name = 'home_page_content' 
     AND column_name IN ('logo_url', 'favicon_url', 'logo_url_social', 'hero_image_url');
   
   SELECT column_name 
   FROM information_schema.columns 
   WHERE table_name = 'tours' 
     AND column_name IN ('tour_date', 'includes');
   
   SELECT column_name 
   FROM information_schema.columns 
   WHERE table_name = 'bookings' 
     AND column_name = 'country_id';
   ```

2. ✅ Las tablas se crearon correctamente:
   ```sql
   SELECT table_name 
   FROM information_schema.tables 
   WHERE table_name IN ('media_files', 'pages', 'countries', 'sms_notifications');
   ```

3. ✅ Los países se insertaron:
   ```sql
   SELECT COUNT(*) FROM countries;
   -- Debe retornar 20
   ```

4. ✅ Los índices se crearon:
   ```sql
   SELECT indexname 
   FROM pg_indexes 
   WHERE tablename IN ('media_files', 'pages', 'countries', 'sms_notifications', 'bookings', 'tours')
     AND indexname LIKE 'idx_%';
   ```

## Notas Importantes

- ⚠️ **El script es idempotente**: Se puede ejecutar múltiples veces sin causar errores
- ⚠️ **No elimina datos**: Solo agrega columnas y tablas, no modifica datos existentes
- ⚠️ **Backup recomendado**: Aunque el script es seguro, siempre es recomendable hacer un backup antes de aplicar cambios en producción
- ⚠️ **SSL requerido**: La conexión a Render requiere SSL, asegúrate de tener `Trust Server Certificate=true`

## Troubleshooting

### Error: "relation already exists"
- Esto es normal si el script se ejecuta múltiples veces
- El script usa `CREATE TABLE IF NOT EXISTS` para evitar este error

### Error: "column already exists"
- Esto es normal si el script se ejecuta múltiples veces
- El script verifica la existencia antes de agregar columnas

### Error de conexión SSL
- Asegúrate de tener `SSL Mode=Require;Trust Server Certificate=true` en la cadena de conexión
- Verifica que el firewall permita conexiones desde tu IP

## Orden de Ejecución de Scripts

Si necesitas recrear la base de datos desde cero, el orden correcto es:

1. `01_create_extensions.sql`
2. `02_create_enums.sql`
3. `03_create_tables.sql`
4. `04_create_indexes.sql`
5. `05_create_functions.sql`
6. `06_seed_data.sql`
7. `12_sync_render_database.sql` ← **Este script aplica todos los cambios adicionales**

