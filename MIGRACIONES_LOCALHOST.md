# Migraciones para Localhost - PanamaTravelHub

## ✅ Estado Actual

**Migración Creada:**
- `20241221000000_InitialCreate.cs` - Migración inicial con todas las tablas

## 🚀 Aplicar Migraciones en Localhost

### Opción 1: Automática (Recomendada) ⭐

La aplicación está configurada para aplicar migraciones **automáticamente** al iniciar:

```bash
dotnet run --project src/PanamaTravelHub.API
```

**¿Qué hace?**
- Al iniciar la aplicación, se conecta a la base de datos
- Verifica si hay migraciones pendientes
- Las aplica automáticamente
- Si hay errores, los muestra en los logs

**Ventajas:**
- ✅ No necesitas instalar herramientas adicionales
- ✅ Siempre actualizada al iniciar
- ✅ Funciona en desarrollo y producción

### Opción 2: Manual con EF Core Tools

Si prefieres aplicar migraciones manualmente:

1. **Instalar herramientas EF Core:**
```bash
dotnet tool install --global dotnet-ef
```

2. **Aplicar migraciones:**
```bash
dotnet ef database update --project src/PanamaTravelHub.Infrastructure --startup-project src/PanamaTravelHub.API
```

3. **Ver migraciones aplicadas:**
```bash
dotnet ef migrations list --project src/PanamaTravelHub.Infrastructure --startup-project src/PanamaTravelHub.API
```

### Opción 3: Scripts SQL Manuales

Si prefieres usar los scripts SQL directamente:

```bash
# Conectarse a PostgreSQL
psql -U postgres -d PanamaTravelHub

# O ejecutar desde archivo
psql -U postgres -d PanamaTravelHub -f database/01_create_extensions.sql
psql -U postgres -d PanamaTravelHub -f database/02_create_enums.sql
psql -U postgres -d PanamaTravelHub -f database/03_create_tables.sql
psql -U postgres -d PanamaTravelHub -f database/04_create_indexes.sql
psql -U postgres -d PanamaTravelHub -f database/05_create_functions.sql
psql -U postgres -d PanamaTravelHub -f database/06_seed_data.sql
```

## 📋 Verificar Migraciones Aplicadas

### En PostgreSQL:

```sql
-- Ver todas las tablas creadas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Ver historial de migraciones EF Core
SELECT * FROM "__EFMigrationsHistory";

-- Verificar estructura de una tabla
\d users
\d tours
\d bookings
```

### Tablas que se Crean:

1. ✅ `users` - Usuarios del sistema
2. ✅ `roles` - Roles (Customer, Admin)
3. ✅ `user_roles` - Relación usuarios-roles
4. ✅ `tours` - Catálogo de tours
5. ✅ `tour_images` - Imágenes de tours
6. ✅ `tour_dates` - Fechas disponibles
7. ✅ `bookings` - Reservas
8. ✅ `booking_participants` - Participantes
9. ✅ `payments` - Pagos
10. ✅ `email_notifications` - Notificaciones
11. ✅ `audit_logs` - Logs de auditoría
12. ✅ `__EFMigrationsHistory` - Historial de migraciones

## 🔧 Configuración de Base de Datos

### Connection String (appsettings.json):

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=PanamaTravelHub;Username=postgres;Password=Panama2020$"
  }
}
```

### Crear Base de Datos (si no existe):

```sql
-- Conectarse a PostgreSQL
psql -U postgres

-- Crear base de datos
CREATE DATABASE "PanamaTravelHub";

-- Salir
\q
```

## 🐛 Troubleshooting

### Error: "Could not connect to database"

**Solución:**
1. Verifica que PostgreSQL esté corriendo:
   ```bash
   # Windows
   Get-Service postgresql*
   
   # O verificar en pgAdmin
   ```

2. Verifica la connection string en `appsettings.json`

3. Verifica que la base de datos exista:
   ```sql
   SELECT datname FROM pg_database WHERE datname = 'PanamaTravelHub';
   ```

### Error: "Migration already applied"

**Solución:**
- Esto es normal si ya aplicaste la migración
- La aplicación verificará automáticamente y no intentará aplicar de nuevo

### Error: "Table already exists"

**Solución:**
- Si creaste las tablas manualmente con SQL, EF Core puede tener conflictos
- Opción 1: Eliminar tablas y dejar que EF Core las cree
- Opción 2: Marcar la migración como aplicada:
  ```sql
  INSERT INTO "__EFMigrationsHistory" (MigrationId, ProductVersion)
  VALUES ('20241221000000_InitialCreate', '8.0.11');
  ```

## 📝 Crear Nueva Migración

Si necesitas crear una nueva migración después de cambiar el modelo:

```bash
# Instalar herramientas (si no están)
dotnet tool install --global dotnet-ef

# Crear migración
dotnet ef migrations add NombreMigracion --project src/PanamaTravelHub.Infrastructure --startup-project src/PanamaTravelHub.API

# Aplicar migración
dotnet ef database update --project src/PanamaTravelHub.Infrastructure --startup-project src/PanamaTravelHub.API
```

## ✅ Verificación Final

Después de aplicar migraciones, verifica:

1. **Ejecutar la aplicación:**
   ```bash
   dotnet run --project src/PanamaTravelHub.API
   ```

2. **Verificar logs:**
   - Deberías ver: "Migraciones aplicadas exitosamente!"

3. **Probar endpoints:**
   - `https://localhost:7009/` - Frontend
   - `https://localhost:7009/api/tours` - API
   - `https://localhost:7009/swagger` - Swagger

## 🎯 Resumen

**Para localhost, la forma más fácil es:**

1. ✅ Asegúrate de que PostgreSQL esté corriendo
2. ✅ Verifica la connection string en `appsettings.json`
3. ✅ Ejecuta: `dotnet run --project src/PanamaTravelHub.API`
4. ✅ Las migraciones se aplicarán automáticamente
5. ✅ ¡Listo! 🎉

