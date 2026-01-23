# Guía para Exportar y Sincronizar Datos de Localhost a Render

## 📋 Resumen

Esta guía explica cómo replicar **todos los datos** de tu base de datos localhost (principal) a Render, asegurando que ambas bases de datos estén completamente homologadas.

## ⚠️ Importante

- **Localhost es la fuente de verdad**: Todos los datos se copian desde localhost hacia Render
- **Backup primero**: Siempre haz backup de Render antes de sincronizar
- **Orden de ejecución**: 
  1. Primero ejecuta `12_sync_render_database.sql` (sincroniza esquema)
  2. Luego ejecuta esta guía (sincroniza datos)

## 🔍 Paso 1: Verificar Homologación del Esquema

Antes de sincronizar datos, asegúrate de que el esquema esté sincronizado:

```bash
# En Render, ejecuta el script de sincronización de esquema
psql "Host=dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com;Port=5432;Database=panamatravelhub;Username=panamatravelhub_user;Password=YFxc28DdPtabZS11XfVxywP5SnS53yZP;SSL Mode=Require;Trust Server Certificate=true" -f database/12_sync_render_database.sql
```

## 📤 Paso 2: Exportar Datos desde Localhost

### Opción A: Exportar Datos Específicos (Recomendado)

Exporta solo las tablas de negocio, excluyendo datos de sistema:

```bash
# Exportar datos de tablas principales
pg_dump -h localhost -U postgres -d PanamaTravelHub \
  --data-only \
  --table=tours \
  --table=tour_images \
  --table=tour_dates \
  --table=bookings \
  --table=booking_participants \
  --table=payments \
  --table=email_notifications \
  --table=sms_notifications \
  --table=home_page_content \
  --table=media_files \
  --table=pages \
  -f database/export_business_data.sql

# O exportar TODO (incluyendo usuarios, pero cuidado con passwords)
pg_dump -h localhost -U postgres -d PanamaTravelHub \
  --data-only \
  -f database/export_all_data.sql
```

### Opción B: Exportar Tabla por Tabla

Si prefieres más control:

```bash
# Tours
pg_dump -h localhost -U postgres -d PanamaTravelHub --data-only --table=tours -f database/export_tours.sql

# Tour Images
pg_dump -h localhost -U postgres -d PanamaTravelHub --data-only --table=tour_images -f database/export_tour_images.sql

# Tour Dates
pg_dump -h localhost -U postgres -d PanamaTravelHub --data-only --table=tour_dates -f database/export_tour_dates.sql

# Bookings
pg_dump -h localhost -U postgres -d PanamaTravelHub --data-only --table=bookings -f database/export_bookings.sql

# Y así sucesivamente...
```

## 📥 Paso 3: Importar Datos en Render

### Opción A: Importar Archivo Completo

```bash
# Importar datos de negocio
psql "Host=dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com;Port=5432;Database=panamatravelhub;Username=panamatravelhub_user;Password=YFxc28DdPtabZS11XfVxywP5SnS53yZP;SSL Mode=Require;Trust Server Certificate=true" -f database/export_business_data.sql
```

### Opción B: Importar Tabla por Tabla

```bash
# Importar tours
psql "Host=dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com;Port=5432;Database=panamatravelhub;Username=panamatravelhub_user;Password=YFxc28DdPtabZS11XfVxywP5SnS53yZP;SSL Mode=Require;Trust Server Certificate=true" -f database/export_tours.sql

# Y así sucesivamente...
```

## 🔄 Paso 4: Manejar Conflictos

Si hay datos duplicados, el script de importación puede fallar. Opciones:

### Opción 1: Limpiar Render Primero (⚠️ CUIDADO)

```sql
-- En Render, eliminar datos existentes antes de importar
TRUNCATE TABLE tours CASCADE;
TRUNCATE TABLE tour_images CASCADE;
TRUNCATE TABLE tour_dates CASCADE;
TRUNCATE TABLE bookings CASCADE;
-- etc...
```

### Opción 2: Usar ON CONFLICT

Modifica el archivo exportado para usar `ON CONFLICT DO UPDATE`:

```sql
-- En lugar de INSERT simple, usar:
INSERT INTO tours (...) VALUES (...)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    -- etc...
```

## ✅ Paso 5: Verificar Sincronización

Ejecuta estas consultas en ambas bases de datos y compara:

### En Localhost:
```sql
SELECT 
    'tours' as tabla, COUNT(*) as total,
    COUNT(*) FILTER (WHERE is_active = true) as activos
FROM tours
UNION ALL
SELECT 
    'tour_images', COUNT(*), COUNT(*) FILTER (WHERE is_primary = true)
FROM tour_images
UNION ALL
SELECT 
    'tour_dates', COUNT(*), COUNT(*) FILTER (WHERE is_active = true)
FROM tour_dates
UNION ALL
SELECT 
    'bookings', COUNT(*), COUNT(*) FILTER (WHERE status = 2)
FROM bookings
ORDER BY tabla;
```

### En Render:
```sql
-- Misma consulta
```

**Compara los resultados**: Deben ser idénticos.

## 📊 Script de Comparación Completo

Crea un archivo `compare_databases.sql`:

```sql
-- Comparar conteos entre bases de datos
WITH localhost_counts AS (
    -- Ejecutar en localhost y copiar resultados
    SELECT 'tours' as tabla, COUNT(*) as count FROM tours
    UNION ALL SELECT 'tour_images', COUNT(*) FROM tour_images
    UNION ALL SELECT 'tour_dates', COUNT(*) FROM tour_dates
    UNION ALL SELECT 'bookings', COUNT(*) FROM bookings
),
render_counts AS (
    -- Ejecutar en Render y copiar resultados
    SELECT 'tours' as tabla, COUNT(*) as count FROM tours
    UNION ALL SELECT 'tour_images', COUNT(*) FROM tour_images
    UNION ALL SELECT 'tour_dates', COUNT(*) FROM tour_dates
    UNION ALL SELECT 'bookings', COUNT(*) FROM bookings
)
SELECT 
    l.tabla,
    l.count as localhost,
    r.count as render,
    l.count - r.count as diferencia
FROM localhost_counts l
FULL OUTER JOIN render_counts r ON l.tabla = r.tabla
WHERE l.count != r.count OR l.count IS NULL OR r.count IS NULL;
```

## 🚨 Consideraciones Importantes

### 1. Usuarios y Passwords
- ⚠️ **NO exportes usuarios** a menos que quieras sobrescribir passwords en Render
- Los usuarios de producción pueden tener passwords diferentes
- Si necesitas sincronizar usuarios, hazlo manualmente

### 2. IDs y Foreign Keys
- Los UUIDs se mantienen iguales, así que las relaciones se preservan
- Si hay conflictos de IDs, usa `ON CONFLICT DO UPDATE`

### 3. Timestamps
- `created_at` y `updated_at` se copian tal cual
- Considera si quieres actualizar `updated_at` al momento de sincronización

### 4. Datos Sensibles
- Revisa que no exportes datos sensibles que no deberían estar en producción
- Considera anonimizar datos de prueba antes de exportar

## 🔧 Script Automatizado (Opcional)

Puedes crear un script bash para automatizar todo:

```bash
#!/bin/bash
# sync_to_render.sh

echo "Exportando datos desde localhost..."
pg_dump -h localhost -U postgres -d PanamaTravelHub \
  --data-only \
  --table=tours \
  --table=tour_images \
  --table=tour_dates \
  --table=bookings \
  --table=booking_participants \
  --table=payments \
  --table=email_notifications \
  --table=home_page_content \
  -f database/export_data.sql

echo "Importando datos en Render..."
psql "Host=dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com;Port=5432;Database=panamatravelhub;Username=panamatravelhub_user;Password=YFxc28DdPtabZS11XfVxywP5SnS53yZP;SSL Mode=Require;Trust Server Certificate=true" -f database/export_data.sql

echo "Sincronización completada!"
```

## 📝 Checklist Final

- [ ] Esquema sincronizado (ejecutado `12_sync_render_database.sql`)
- [ ] Backup de Render realizado
- [ ] Datos exportados desde localhost
- [ ] Datos importados en Render
- [ ] Verificación de conteos realizada
- [ ] Aplicación probada en Render
- [ ] Datos sensibles revisados

## 🆘 Troubleshooting

### Error: "relation already exists"
- Normal si el esquema ya está sincronizado
- Ignorar o usar `--if-exists` en pg_dump

### Error: "duplicate key value"
- Hay datos duplicados
- Usar `ON CONFLICT DO UPDATE` o limpiar primero

### Error: "foreign key constraint"
- Verificar que las tablas relacionadas existan
- Importar en orden: tours → tour_images → tour_dates → bookings

### Error de conexión SSL
- Verificar que `Trust Server Certificate=true` esté en la cadena
- Verificar firewall y acceso a Render

