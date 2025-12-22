# PanamaTravelHub - Sistema de Reservas de Tours

Sistema completo de administración y reservas de tours en Panamá desarrollado con ASP.NET Core 8 y PostgreSQL.

## Arquitectura

El proyecto sigue **Clean Architecture** con las siguientes capas:

- **Domain**: Entidades, Enums, Value Objects
- **Application**: Casos de uso, DTOs, Interfaces, Validators
- **Infrastructure**: DbContext, Repositories, Email, Payments, Audit
- **API**: Controllers, Middlewares, Filters, Auth

## Requisitos

- .NET 8.0 SDK
- PostgreSQL 16+ (o Docker)
- Visual Studio 2022 / VS Code / Rider

## Configuración de Base de Datos

### Opción 1: Docker Compose (Recomendado)

```bash
docker-compose up -d
```

Esto iniciará PostgreSQL en el puerto 5432 con:
- Database: `PanamaTravelHub`
- Username: `postgres`
- Password: `Panama2020$`

### Opción 2: PostgreSQL Local

1. Instalar PostgreSQL 16+
2. Crear la base de datos:
```sql
CREATE DATABASE "PanamaTravelHub";
```

3. Ejecutar los scripts SQL en orden:
```bash
psql -U postgres -d PanamaTravelHub -f database/01_create_extensions.sql
psql -U postgres -d PanamaTravelHub -f database/02_create_enums.sql
psql -U postgres -d PanamaTravelHub -f database/03_create_tables.sql
psql -U postgres -d PanamaTravelHub -f database/04_create_indexes.sql
psql -U postgres -d PanamaTravelHub -f database/05_create_functions.sql
psql -U postgres -d PanamaTravelHub -f database/06_seed_data.sql
```

## Configuración de la Aplicación

1. Clonar el repositorio
2. Restaurar paquetes NuGet:
```bash
dotnet restore
```

3. Configurar la cadena de conexión en `src/PanamaTravelHub.API/appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=PanamaTravelHub;Username=postgres;Password=Panama2020$"
  }
}
```

4. Aplicar migraciones de Entity Framework Core:
```bash
dotnet ef database update --project src/PanamaTravelHub.Infrastructure --startup-project src/PanamaTravelHub.API
```

O si las herramientas de EF Core no están instaladas:
```bash
dotnet tool install --global dotnet-ef
dotnet ef database update --project src/PanamaTravelHub.Infrastructure --startup-project src/PanamaTravelHub.API
```

## Ejecutar la Aplicación

```bash
dotnet run --project src/PanamaTravelHub.API
```

La API estará disponible en:
- HTTP: `http://localhost:5000`
- HTTPS: `https://localhost:5001`
- Swagger: `https://localhost:5001/swagger`

## Estructura de Base de Datos

### Tablas Principales

- **users**: Usuarios del sistema
- **roles**: Roles (Customer, Admin)
- **user_roles**: Relación usuarios-roles
- **tours**: Catálogo de tours
- **tour_images**: Imágenes de tours
- **tour_dates**: Fechas disponibles para tours
- **bookings**: Reservas
- **booking_participants**: Participantes de reservas
- **payments**: Pagos
- **email_notifications**: Notificaciones por email
- **audit_logs**: Logs de auditoría

### Características de Seguridad

- UUID como Primary Keys
- Constraints CHECK para validación
- Foreign Keys con acciones apropiadas
- Control de concurrencia con SELECT FOR UPDATE
- Funciones para prevenir sobreventa
- Triggers automáticos para `updated_at`

## Desarrollo

### Crear una nueva migración

```bash
dotnet ef migrations add NombreMigracion --project src/PanamaTravelHub.Infrastructure --startup-project src/PanamaTravelHub.API
```

### Aplicar migraciones

```bash
dotnet ef database update --project src/PanamaTravelHub.Infrastructure --startup-project src/PanamaTravelHub.API
```

### Revertir migración

```bash
dotnet ef database update NombreMigracionAnterior --project src/PanamaTravelHub.Infrastructure --startup-project src/PanamaTravelHub.API
```

## Scripts SQL Manuales

Los scripts SQL están disponibles en el directorio `database/`:

1. `01_create_extensions.sql` - Extensiones PostgreSQL
2. `02_create_enums.sql` - Documentación de enums
3. `03_create_tables.sql` - Creación de tablas
4. `04_create_indexes.sql` - Índices para performance
5. `05_create_functions.sql` - Funciones y triggers
6. `06_seed_data.sql` - Datos iniciales
7. `07_drop_all.sql` - Script de limpieza (usar con precaución)

## Próximos Pasos

- [ ] Implementar autenticación JWT
- [ ] Implementar casos de uso de Application layer
- [ ] Crear controllers de API
- [ ] Implementar sistema de pagos (Stripe, PayPal, Yappy)
- [ ] Implementar sistema de emails
- [ ] Implementar auditoría
- [ ] Crear tests unitarios e integración

## Licencia

Proyecto privado - Todos los derechos reservados
