# 👥 Usuarios de Prueba y Verificación de Tablas

## 🔐 Usuarios de Prueba

### 1. Administrador
- **Email:** `admin@panamatravelhub.com`
- **Contraseña:** `Admin123!`
- **Rol:** Admin
- **Nombre:** Administrador Sistema
- **Acceso:** Panel de administración completo

### 2. Cliente Ejemplo
- **Email:** `cliente@panamatravelhub.com`
- **Contraseña:** `Cliente123!`
- **Rol:** Customer
- **Nombre:** Cliente Ejemplo
- **Acceso:** Reservas, ver tours, etc.

### 3. Usuario de Prueba 1
- **Email:** `test1@panamatravelhub.com`
- **Contraseña:** `Test123!`
- **Rol:** Customer
- **Nombre:** Test Usuario Uno
- **Acceso:** Funcionalidades de cliente

### 4. Usuario de Prueba 2
- **Email:** `test2@panamatravelhub.com`
- **Contraseña:** `Prueba123!`
- **Rol:** Customer
- **Nombre:** Test Usuario Dos
- **Acceso:** Funcionalidades de cliente

---

## 📊 Tablas Requeridas en la Base de Datos

### ✅ Tablas Principales (Implementadas)

1. **users** - Usuarios del sistema
2. **roles** - Roles (Admin, Customer)
3. **user_roles** - Relación usuarios-roles (many-to-many)

### ✅ Tablas de Tours

4. **tours** - Catálogo de tours
5. **tour_images** - Imágenes de tours
6. **tour_dates** - Fechas disponibles para tours

### ✅ Tablas de Reservas

7. **bookings** - Reservas (incluye campo `country_id` ⭐)
8. **booking_participants** - Participantes de reservas
9. **payments** - Pagos

### ✅ Tablas de Notificaciones

10. **email_notifications** - Notificaciones por email
11. **sms_notifications** - Notificaciones por SMS ⭐ NUEVO

### ✅ Tablas de Seguridad y Autenticación

12. **refresh_tokens** - Tokens de refresh para JWT
13. **password_reset_tokens** - Tokens de recuperación de contraseña
14. **audit_logs** - Logs de auditoría

### ✅ Tablas de CMS y Contenido

15. **home_page_content** - Contenido de la página de inicio (incluye campos de logo ⭐)
16. **pages** - Páginas dinámicas (incluye blog)
17. **media_files** - Archivos multimedia

### ✅ Tablas Adicionales

18. **countries** - Países para reservas ⭐ NUEVO
19. **data_protection_keys** - Claves para Data Protection

---

## 🔍 Scripts SQL de Verificación

### Verificar Tablas Existentes

```sql
-- Ver todas las tablas
SELECT table_name 
FROM information_schema.tables
WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

### Verificar Campos Específicos

```sql
-- Verificar campos de logo en home_page_content
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'home_page_content' 
    AND column_name IN ('logo_url', 'favicon_url', 'logo_url_social');

-- Verificar campo country_id en bookings
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'bookings' 
    AND column_name = 'country_id';

-- Verificar tabla countries
SELECT COUNT(*) as total_countries FROM countries;

-- Verificar tabla sms_notifications
SELECT COUNT(*) as total_sms_notifications FROM sms_notifications;
```

### Ver Usuarios y Roles

```sql
SELECT 
    u.email,
    u.first_name || ' ' || u.last_name as nombre,
    STRING_AGG(r.name, ', ') as roles,
    u.is_active
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
GROUP BY u.id, u.email, u.first_name, u.last_name, u.is_active
ORDER BY u.email;
```

---

## 📝 Scripts SQL para Aplicar

### Orden de Ejecución (si falta alguna tabla/campo)

1. **Tablas Base:** `database/03_create_tables.sql`
2. **Índices:** `database/04_create_indexes.sql`
3. **Logo Fields:** `database/08_add_logo_fields.sql` ⭐
4. **Countries y Country en Bookings:** `database/09_add_countries_and_country_to_bookings.sql` ⭐
5. **SMS Notifications:** `database/10_create_sms_notifications_table.sql` ⭐
6. **Usuarios de Prueba:** `scripts/reset-and-create-users.sql`

---

## 🚀 Comando para Conectarse a la BD

```bash
PGPASSWORD=YFxc28DdPtabZS11XfVxywP5SnS53yZP psql -h dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com -U panamatravelhub_user -d panamatravelhub
```

O usando la ruta completa de psql:
```bash
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com -U panamatravelhub_user -d panamatravelhub
```

Cuando pida contraseña, usar: `YFxc28DdPtabZS11XfVxywP5SnS53yZP`

---

## ✅ Checklist de Verificación

- [ ] Todas las tablas listadas existen
- [ ] Campo `country_id` existe en `bookings`
- [ ] Campos `logo_url`, `favicon_url`, `logo_url_social` existen en `home_page_content`
- [ ] Tabla `countries` existe y tiene datos
- [ ] Tabla `sms_notifications` existe
- [ ] Usuarios de prueba existen (4 usuarios)
- [ ] Roles asignados correctamente
- [ ] Contraseñas funcionan (verificar login)

---

**Última actualización:** 2025-01-XX

