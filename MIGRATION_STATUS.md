# Estado de Migraciones

## Migración Creada

✅ **Migración: InitialCreate**
- Archivo: `src/PanamaTravelHub.Infrastructure/Migrations/20241221000000_InitialCreate.cs`
- Estado: Creada y lista para aplicar

## Cómo Aplicar la Migración

### Opción 1: Ejecutar la Aplicación (Recomendado)

La aplicación está configurada para aplicar migraciones automáticamente al iniciar:

```bash
dotnet run --project src/PanamaTravelHub.API
```

La migración se aplicará automáticamente cuando la aplicación se conecte a la base de datos.

### Opción 2: Usar Scripts SQL Manuales

Si prefieres aplicar los scripts SQL directamente:

```bash
# Asegúrate de que PostgreSQL esté corriendo y la base de datos exista
psql -U postgres -d PanamaTravelHub -f database/01_create_extensions.sql
psql -U postgres -d PanamaTravelHub -f database/03_create_tables.sql
psql -U postgres -d PanamaTravelHub -f database/04_create_indexes.sql
psql -U postgres -d PanamaTravelHub -f database/05_create_functions.sql
psql -U postgres -d PanamaTravelHub -f database/06_seed_data.sql
```

### Opción 3: Usar EF Core Tools (si están instaladas)

```bash
# Instalar herramientas (si no están instaladas)
dotnet tool install --global dotnet-ef

# Aplicar migraciones
dotnet ef database update --project src/PanamaTravelHub.Infrastructure --startup-project src/PanamaTravelHub.API
```

## Verificar que la Migración se Aplicó

Puedes verificar en PostgreSQL:

```sql
-- Verificar tablas creadas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Verificar migraciones aplicadas (si usas EF Core)
SELECT * FROM "__EFMigrationsHistory";
```

## Tablas que se Crearán

1. users
2. roles
3. user_roles
4. tours
5. tour_images
6. tour_dates
7. bookings
8. booking_participants
9. payments
10. email_notifications
11. audit_logs

## Notas

- La migración incluye:
  - Extensión UUID para PostgreSQL
  - Todas las tablas con constraints
  - Índices para performance
  - Funciones para control de cupos
  - Triggers para updated_at
  - Datos iniciales (roles)

- Si la base de datos ya existe y tiene datos, la migración intentará crear las tablas. Si hay conflictos, revisa los logs.

## Solución de Problemas

### Error: "database does not exist"
```sql
CREATE DATABASE "PanamaTravelHub";
```

### Error: "extension uuid-ossp does not exist"
La migración crea la extensión automáticamente, pero si falla:
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

### Error de conexión
Verifica la cadena de conexión en `appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=PanamaTravelHub;Username=postgres;Password=Panama2020$"
  }
}
```
