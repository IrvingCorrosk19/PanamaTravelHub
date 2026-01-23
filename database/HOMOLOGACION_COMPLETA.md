# Guía Completa de Homologación: Localhost → Render

## 🎯 Objetivo

Homologar completamente la base de datos de Render con la de localhost, asegurando que **ambas tengan las mismas tablas, columnas Y datos**.

## 📊 Estado Actual

### ✅ Esquema (Estructura)
- **Localhost**: ✅ Completo (todas las tablas y columnas)
- **Render**: ❌ Incompleto (faltan 8 cambios)

### ✅ Datos
- **Localhost**: ✅ Completo (datos de negocio + seed)
- **Render**: ❓ Desconocido (necesita verificación y sincronización)

## 🔄 Proceso de Homologación

### Fase 1: Sincronizar Esquema (Estructura)

**Archivo**: `12_sync_render_database.sql`

Este script:
- ✅ Agrega columnas faltantes
- ✅ Crea tablas nuevas
- ✅ Crea índices necesarios
- ✅ Sincroniza datos de seed (roles, usuario admin, países)

**Ejecutar**:
```bash
psql "Host=dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com;Port=5432;Database=panamatravelhub;Username=panamatravelhub_user;Password=YFxc28DdPtabZS11XfVxywP5SnS53yZP;SSL Mode=Require;Trust Server Certificate=true" -f database/12_sync_render_database.sql
```

**Resultado esperado**: Render tendrá la misma estructura que localhost.

### Fase 2: Sincronizar Datos de Negocio

**Archivo**: `EXPORT_LOCALHOST_DATA.md` (guía completa)

Este proceso:
- 📤 Exporta datos desde localhost
- 📥 Importa datos en Render
- ✅ Verifica que los datos sean idénticos

**Pasos rápidos**:

1. **Exportar desde localhost**:
```bash
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
```

2. **Importar en Render**:
```bash
psql "Host=dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com;Port=5432;Database=panamatravelhub;Username=panamatravelhub_user;Password=YFxc28DdPtabZS11XfVxywP5SnS53yZP;SSL Mode=Require;Trust Server Certificate=true" -f database/export_business_data.sql
```

## ✅ Verificación de Homologación

### 1. Verificar Esquema

Ejecutar en ambas bases de datos:

```sql
-- Listar todas las tablas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Listar columnas de una tabla específica
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'tours'
ORDER BY ordinal_position;
```

**Resultado esperado**: Mismas tablas y columnas en ambas bases.

### 2. Verificar Datos

Ejecutar en ambas bases de datos:

```sql
-- Conteo de registros por tabla
SELECT 'tours' as tabla, COUNT(*) as total FROM tours
UNION ALL
SELECT 'tour_images', COUNT(*) FROM tour_images
UNION ALL
SELECT 'tour_dates', COUNT(*) FROM tour_dates
UNION ALL
SELECT 'bookings', COUNT(*) FROM bookings
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL
SELECT 'countries', COUNT(*) FROM countries
ORDER BY tabla;
```

**Resultado esperado**: Mismos conteos en ambas bases.

### 3. Verificar Datos de Seed

```sql
-- Verificar roles
SELECT id, name FROM roles ORDER BY name;

-- Verificar usuario admin
SELECT id, email, first_name, last_name, is_active FROM users WHERE email = 'admin@toursanama.com';

-- Verificar países
SELECT code, name, is_active FROM countries ORDER BY display_order;
```

**Resultado esperado**: Mismos datos de seed en ambas bases.

## 📋 Checklist de Homologación

### Esquema
- [ ] Ejecutado `12_sync_render_database.sql` en Render
- [ ] Verificadas todas las tablas existen
- [ ] Verificadas todas las columnas existen
- [ ] Verificados todos los índices existen

### Datos de Seed
- [ ] Roles sincronizados (Customer, Admin)
- [ ] Usuario admin sincronizado
- [ ] Países sincronizados (20 países)

### Datos de Negocio
- [ ] Tours exportados e importados
- [ ] Tour images exportados e importados
- [ ] Tour dates exportados e importados
- [ ] Bookings exportados e importados
- [ ] Payments exportados e importados
- [ ] Email notifications exportados e importados
- [ ] Home page content exportado e importado
- [ ] Media files exportados e importados
- [ ] Pages exportados e importados

### Verificación Final
- [ ] Conteos de registros coinciden
- [ ] Aplicación funciona correctamente en Render
- [ ] No hay errores de foreign keys
- [ ] No hay errores de datos faltantes

## 🚨 Consideraciones Importantes

### 1. Usuarios y Passwords
- ⚠️ **NO sincronizar usuarios** a menos que sea necesario
- Los usuarios de producción pueden tener passwords diferentes
- Si sincronizas usuarios, los passwords de Render se sobrescribirán

### 2. IDs y Relaciones
- Los UUIDs se mantienen iguales, preservando relaciones
- Si hay conflictos, usar `ON CONFLICT DO UPDATE`

### 3. Timestamps
- `created_at` y `updated_at` se copian tal cual
- Considera si quieres actualizar `updated_at` al sincronizar

### 4. Datos en Producción
- ⚠️ **Cuidado**: Sincronizar datos puede sobrescribir información de producción
- Haz backup de Render antes de sincronizar
- Considera sincronizar solo datos específicos si es necesario

## 📁 Archivos de Referencia

1. **`12_sync_render_database.sql`** - Sincroniza esquema y datos de seed
2. **`13_sync_render_data.sql`** - Referencia para sincronización de datos
3. **`EXPORT_LOCALHOST_DATA.md`** - Guía detallada de exportación/importación
4. **`SYNC_RENDER_INSTRUCTIONS.md`** - Instrucciones de sincronización de esquema
5. **`CHANGES_SUMMARY.md`** - Resumen de cambios de esquema

## 🆘 Troubleshooting

### Error: "relation already exists"
- Normal si el esquema ya está sincronizado
- El script es idempotente, se puede ejecutar múltiples veces

### Error: "duplicate key value"
- Hay datos duplicados entre localhost y Render
- Usar `ON CONFLICT DO UPDATE` o limpiar Render primero

### Error: "foreign key constraint"
- Verificar que las tablas relacionadas existan
- Importar en orden: tours → tour_images → tour_dates → bookings

### Datos no coinciden después de sincronizar
- Verificar que el export/import se completó correctamente
- Comparar conteos tabla por tabla
- Revisar logs de importación para errores

## ✅ Resultado Final

Después de completar ambas fases:

- ✅ **Esquema**: Render = Localhost (mismas tablas, columnas, índices)
- ✅ **Datos de Seed**: Render = Localhost (roles, admin, países)
- ✅ **Datos de Negocio**: Render = Localhost (tours, bookings, etc.)

**Ambas bases de datos estarán completamente homologadas.**

