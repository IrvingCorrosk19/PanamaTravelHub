# 📋 Instrucciones para Verificar Tablas en Render

## Opción 1: Usando psql desde PowerShell (Recomendado)

### Paso 1: Abrir PowerShell
Abre PowerShell en la carpeta del proyecto:
```powershell
cd C:\Proyectos\PanamaTravelHub\PanamaTravelHub
```

### Paso 2: Ejecutar el comando de verificación
Copia y pega este comando completo:

```powershell
$env:PGPASSWORD='YFxc28DdPtabZS11XfVxywP5SnS53yZP'; & "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com -U panamatravelhub_user -d panamatravelhub -f scripts\verificar-tablas-directo.sql
```

**O usa este comando más simple (sin archivo):**

```powershell
$env:PGPASSWORD='YFxc28DdPtabZS11XfVxywP5SnS53yZP'; & "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com -U panamatravelhub_user -d panamatravelhub -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' ORDER BY table_name;"
```

### Paso 3: Ver los resultados
El comando mostrará:
- Lista de todas las tablas existentes
- Estado de cada tabla esperada (✅ EXISTE o ❌ FALTA)

---

## Opción 2: Usando psql interactivo

### Paso 1: Conectar a la base de datos
```powershell
$env:PGPASSWORD='YFxc28DdPtabZS11XfVxywP5SnS53yZP'
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com -U panamatravelhub_user -d panamatravelhub
```

### Paso 2: Ejecutar comandos SQL
Una vez conectado, ejecuta:

```sql
-- Ver todas las tablas
\dt

-- O verificar específicamente:
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

### Paso 3: Salir
```sql
\q
```

---

## Opción 3: Usando el script PowerShell

### Paso 1: Ejecutar el script
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-tables.ps1
```

---

## Tablas que DEBEN existir (11 tablas principales):

1. ✅ `users` - Usuarios del sistema
2. ✅ `roles` - Roles (Admin, Customer)
3. ✅ `user_roles` - Relación usuarios-roles
4. ✅ `tours` - Tours disponibles
5. ✅ `tour_images` - Imágenes de tours
6. ✅ `tour_dates` - Fechas disponibles de tours
7. ✅ `bookings` - Reservas
8. ✅ `booking_participants` - Participantes de reservas
9. ✅ `payments` - Pagos
10. ✅ `email_notifications` - Cola de emails
11. ✅ `audit_logs` - Logs de auditoría

**Nota:** Las tablas `home_page_content` y `refresh_tokens` existen en el código pero pueden no estar migradas aún. Si las necesitas, se crearán automáticamente con EF Core.

---

## Si faltan tablas:

Si alguna tabla falta, ejecuta los scripts SQL en orden:

```powershell
# 1. Extensiones
$env:PGPASSWORD='YFxc28DdPtabZS11XfVxywP5SnS53yZP'
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com -U panamatravelhub_user -d panamatravelhub -f database\01_create_extensions.sql

# 2. Enums
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com -U panamatravelhub_user -d panamatravelhub -f database\02_create_enums.sql

# 3. Tablas
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com -U panamatravelhub_user -d panamatravelhub -f database\03_create_tables.sql

# 4. Índices
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com -U panamatravelhub_user -d panamatravelhub -f database\04_create_indexes.sql

# 5. Funciones
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d54nnjf5r7bin\psql.exe" -h dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com -U panamatravelhub_user -d panamatravelhub -f database\05_create_functions.sql

# 6. Datos iniciales (opcional)
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com -U panamatravelhub_user -d panamatravelhub -f database\06_seed_data.sql
```

---

## Comando rápido de verificación:

```powershell
$env:PGPASSWORD='YFxc28DdPtabZS11XfVxywP5SnS53yZP'; & "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com -U panamatravelhub_user -d panamatravelhub -c "SELECT COUNT(*) as total_tablas FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';"
```

Este comando mostrará el total de tablas. Debería ser **11 o más** (las 11 principales más cualquier tabla adicional de EF Core como `__EFMigrationsHistory`).

