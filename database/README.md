# Scripts de Base de Datos PostgreSQL

Este directorio contiene los scripts SQL para crear y gestionar la base de datos del proyecto ToursPanama.

## Orden de Ejecución

1. **01_create_extensions.sql** - Crea las extensiones necesarias (UUID)
2. **02_create_enums.sql** - Documentación de enums (se manejan como integers)
3. **03_create_tables.sql** - Crea todas las tablas con constraints y foreign keys
4. **04_create_indexes.sql** - Crea índices para optimizar consultas
5. **05_create_functions.sql** - Funciones y triggers para control de concurrencia
6. **06_seed_data.sql** - Datos iniciales (roles y usuario admin)
7. **07_drop_all.sql** - Script para eliminar todo (usar con precaución)
8. **11_add_tour_date_to_tours.sql** - Agrega columna tour_date a la tabla tours

## Ejecución

### Opción 1: Ejecutar todos los scripts en orden
```bash
psql -U postgres -d panamatravelhub -f 01_create_extensions.sql
psql -U postgres -d panamatravelhub -f 02_create_enums.sql
psql -U postgres -d panamatravelhub -f 03_create_tables.sql
psql -U postgres -d panamatravelhub -f 04_create_indexes.sql
psql -U postgres -d panamatravelhub -f 05_create_functions.sql
psql -U postgres -d panamatravelhub -f 06_seed_data.sql
```

### Opción 2: Usar migraciones de Entity Framework Core
Las migraciones de EF Core se generarán automáticamente y aplicarán estos cambios.

## Características de Seguridad

- UUID como Primary Keys
- Constraints CHECK para validación de datos
- Foreign Keys con acciones apropiadas (CASCADE, RESTRICT, SET NULL)
- Control de concurrencia con SELECT FOR UPDATE
- Funciones para prevenir sobreventa de cupos
- Triggers automáticos para updated_at

## Índices Optimizados

- Índices en foreign keys
- Índices en campos de búsqueda frecuente (email, status, dates)
- Índices compuestos para consultas complejas
- Índices parciales para campos con filtros comunes

## Notas

- Los enums de .NET se mapean a integers en PostgreSQL
- JSONB se usa para campos flexibles (metadata, before/after states)
- Los triggers actualizan automáticamente el campo `updated_at`
