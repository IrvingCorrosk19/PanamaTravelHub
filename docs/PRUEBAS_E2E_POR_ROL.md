# Pruebas E2E por Rol

## Descripción

Script que ejecuta pruebas **end-to-end** para cada rol del sistema:

1. **Público** – Sin autenticación (catálogo, tours, países)
2. **Customer** – Cliente (login, reservas, validar cupón, sin acceso admin)
3. **Admin** – Administrador (todo lo anterior + panel admin completo)

## Uso

```powershell
.\scripts\test-e2e-por-rol.ps1
```

Requisitos: API en `http://localhost:5018`, base de datos con usuarios de prueba.

## Usuarios de prueba

| Rol      | Email                      | Password    |
|----------|----------------------------|-------------|
| Admin    | admin@panamatravelhub.com  | Admin123!   |
| Customer | cliente@panamatravelhub.com| Cliente123! |

Si el login de Customer falla (401), ejecutar:

```powershell
.\scripts\fix-customer-password.ps1
```

Eso restablece la contraseña de `cliente@` a `Cliente123!` en la BD.

## Pruebas por rol

### Público (6)

- Homepage content
- Listar tours
- Buscar tours
- Detalle tour
- Fechas tour
- Países

### Customer (10)

- Login
- Auth Me
- Validar cupón (acceso; 400 por cupón inválido se considera OK)
- Mis reservas
- Crear reserva
- Obtener reserva
- Admin Tours → **403 esperado**
- Admin Bookings → **403 esperado**
- Admin Stats → **403 esperado**
- Admin Homepage → **403 esperado**

### Admin (14)

- Login
- Auth Me
- Cupones (listar)
- Mis reservas
- Admin Tours, Bookings, Stats, Homepage, Media, Pages, Users, Roles
- Crear reserva
- Obtener reserva

## Resultados

- Salida en consola (OK / ERROR por prueba).
- JSON: `test-e2e-rol-YYYYMMDD-HHMMSS.json`.

## Notas

- **Cupones**: `GET /api/coupons` es AdminOnly. Customer solo puede `POST /api/coupons/validate`.
- Las pruebas "Admin XXX (debe 403)" comprueban que Customer **no** accede a rutas admin.
