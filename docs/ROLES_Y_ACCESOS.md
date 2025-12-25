# Roles y Accesos en la Aplicación

## Roles Disponibles en la Base de Datos

### 1. Customer
- **ID:** `00000000-0000-0000-0000-000000000001`
- **Nombre:** `Customer`
- **Descripción:** Cliente regular del sistema

### 2. Admin
- **ID:** `00000000-0000-0000-0000-000000000002`
- **Nombre:** `Admin`
- **Descripción:** Administrador del sistema

---

## Políticas de Autorización Configuradas

En `Program.cs` se han definido las siguientes políticas:

1. **AdminOnly**: Requiere rol `Admin`
2. **CustomerOnly**: Requiere rol `Customer`
3. **AdminOrCustomer**: Requiere rol `Admin` o `Customer`

---

## Endpoints por Controlador y Accesos Requeridos

### 🔐 AuthController (`/api/auth`)

| Endpoint | Método | Acceso Actual | Acceso Requerido | Notas |
|----------|--------|---------------|------------------|-------|
| `/api/auth/register` | POST | Público ✅ | Público | Registro de nuevos usuarios (asigna rol Customer por defecto) |
| `/api/auth/login` | POST | Público ✅ | Público | Inicio de sesión |
| `/api/auth/refresh` | POST | Público ✅ | Público | Renovar token de acceso |
| `/api/auth/check-email` | GET | Público ✅ | Público | Verificar disponibilidad de email |
| `/api/auth/forgot-password` | POST | Público ✅ | Público | Solicitar recuperación de contraseña |
| `/api/auth/reset-password` | POST | Público ✅ | Público | Resetear contraseña con token |
| `/api/auth/logout` | POST | `[Authorize]` ✅ | `AdminOrCustomer` | Cerrar sesión (revoca refresh token) |
| `/api/auth/me` | GET | `[Authorize]` ✅ | `AdminOrCustomer` | Obtener información del usuario actual |

✅ **Estado:** Correctamente protegido

---

### 📋 ToursController (`/api/tours`)

| Endpoint | Método | Acceso Actual | Acceso Requerido | Notas |
|----------|--------|---------------|------------------|-------|
| `/api/tours` | GET | Público ✅ | Público | Listar tours activos |
| `/api/tours/{id}` | GET | Público ✅ | Público | Obtener detalles de un tour |
| `/api/tours/homepage-content` | GET | Público ✅ | Público | Obtener contenido de la página de inicio |
| `/api/tours/{tourId}/dates` | GET | Público ✅ | Público | Obtener fechas disponibles de un tour |

✅ **Estado:** Correctamente protegido (todos son públicos)

---

### 📝 BookingsController (`/api/bookings`)

| Endpoint | Método | Acceso Actual | Acceso Requerido | Notas |
|----------|--------|---------------|------------------|-------|
| `/api/bookings/my` | GET | `[Authorize]` ✅ | `Customer` o `Admin` | Obtener reservas del usuario actual |
| `/api/bookings` | GET | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Obtener todas las reservas (admin) |
| `/api/bookings/{id}` | GET | `[Authorize]` + validación ✅ | `AdminOrCustomer` | Obtener detalles de reserva (verificar que sea del usuario o admin) |
| `/api/bookings` | POST | `[Authorize]` ✅ | `Customer` o `Admin` | Crear nueva reserva |
| `/api/bookings/{id}/confirm` | POST | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Confirmar reserva (solo admin) |
| `/api/bookings/{id}/cancel` | POST | `[Authorize]` + validación ✅ | `AdminOrCustomer` | Cancelar reserva (solo el dueño o admin) |

✅ **Estado:** **PROTEGIDO CORRECTAMENTE**

**Acciones necesarias:**
1. Agregar `[Authorize(Policy = "CustomerOnly")]` a nivel de clase o método específico
2. Agregar `[Authorize(Policy = "AdminOnly")]` a `GetAllBookings` y `ConfirmBooking`
3. Agregar `[Authorize]` a `CreateBooking` y `GetMyBookings`
4. Agregar validación en `GetBooking` y `CancelBooking` para verificar que el usuario sea el dueño o admin

---

### 💳 PaymentsController (`/api/payments`)

| Endpoint | Método | Acceso Actual | Acceso Requerido | Notas |
|----------|--------|---------------|------------------|-------|
| `/api/payments/create-intent` | POST | `[Authorize]` ✅ | `Customer` o `Admin` | Crear intención de pago |
| `/api/payments/confirm` | POST | `[Authorize]` ✅ | `Customer` o `Admin` | Confirmar pago |
| `/api/payments/webhook` | POST | Público ✅ | Público | Webhook de Stripe (sin autenticación) |
| `/api/payments/refund` | POST | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Procesar reembolso |

✅ **Estado:** Correctamente protegido

---

### 🔧 AdminController (`/api/admin`)

| Endpoint | Método | Acceso Actual | Acceso Requerido | Notas |
|----------|--------|---------------|------------------|-------|
| `/api/admin/tours` | GET | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Listar todos los tours (admin) |
| `/api/admin/tours` | POST | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Crear tour |
| `/api/admin/tours/{id}` | GET | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Obtener tour (admin) |
| `/api/admin/tours/{id}` | PUT | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Actualizar tour |
| `/api/admin/tours/{id}` | DELETE | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Eliminar/desactivar tour |
| `/api/admin/bookings` | GET | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Listar todas las reservas |
| `/api/admin/stats` | GET | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Obtener estadísticas |
| `/api/admin/homepage-content` | GET | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Obtener contenido de homepage |
| `/api/admin/homepage-content` | PUT | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Actualizar contenido de homepage |
| `/api/admin/upload-image` | POST | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Subir imagen |
| `/api/admin/media` | GET | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Listar archivos de media |
| `/api/admin/media` | POST | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Subir archivo a media |
| `/api/admin/media/{id}` | DELETE | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Eliminar archivo de media |
| `/api/admin/pages` | GET | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Listar páginas |
| `/api/admin/pages/{id}` | GET | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Obtener página |
| `/api/admin/pages` | POST | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Crear página |
| `/api/admin/pages/{id}` | PUT | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Actualizar página |
| `/api/admin/pages/{id}` | DELETE | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Eliminar página |
| `/api/admin/tours/{tourId}/dates` | GET | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Obtener fechas de tour |
| `/api/admin/tours/{tourId}/dates` | POST | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Crear fecha de tour |
| `/api/admin/tours/dates/{dateId}` | PUT | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Actualizar fecha de tour |
| `/api/admin/tours/dates/{dateId}` | DELETE | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Eliminar fecha de tour |
| `/api/admin/users` | GET | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Listar usuarios |
| `/api/admin/users/{id}` | GET | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Obtener usuario |
| `/api/admin/users/{id}` | PUT | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Actualizar usuario |
| `/api/admin/users/{id}/unlock` | POST | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Desbloquear usuario |
| `/api/admin/roles` | GET | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Listar roles |

✅ **Estado:** **PROTEGIDO CORRECTAMENTE**

**Implementado:**
1. ✅ Agregado `[Authorize(Policy = "AdminOnly")]` a nivel de clase en `AdminController`

---

### 📊 AuditController (`/api/admin/audit`)

| Endpoint | Método | Acceso Actual | Acceso Requerido | Notas |
|----------|--------|---------------|------------------|-------|
| `/api/admin/audit` | GET | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Listar logs de auditoría |
| `/api/admin/audit/{id}` | GET | `[Authorize(Policy = "AdminOnly")]` ✅ | `AdminOnly` | Obtener log de auditoría |

✅ **Estado:** Correctamente protegido

---

### ❤️ HealthController

| Endpoint | Método | Acceso Actual | Acceso Requerido | Notas |
|----------|--------|---------------|------------------|-------|
| `/health` | GET | Público ✅ | Público | Health check del sistema |

✅ **Estado:** Correctamente protegido (debe ser público)

---

## Resumen de Accesos por Rol

### 👤 Customer (Cliente)

**Puede acceder a:**
- ✅ Registro y autenticación (registro, login, logout, refresh, me)
- ✅ Recuperación de contraseña
- ✅ Ver catálogo de tours (listar, detalle, fechas, homepage content)
- ✅ Crear reservas propias
- ✅ Ver sus propias reservas
- ✅ Cancelar sus propias reservas
- ✅ Crear y confirmar pagos para sus reservas
- ✅ Health check

**NO puede acceder a:**
- ❌ Endpoints de administración (`/api/admin/*`)
- ❌ Ver todas las reservas
- ❌ Confirmar reservas de otros usuarios
- ❌ Ver logs de auditoría
- ❌ Procesar reembolsos

---

### 👨‍💼 Admin (Administrador)

**Puede acceder a:**
- ✅ Todo lo que puede Customer
- ✅ Todos los endpoints de administración (`/api/admin/*`)
- ✅ Ver todas las reservas
- ✅ Confirmar/cancelar cualquier reserva
- ✅ CRUD completo de tours
- ✅ CRUD completo de usuarios
- ✅ Gestión de contenido (homepage, páginas, media)
- ✅ Ver logs de auditoría
- ✅ Ver estadísticas
- ✅ Procesar reembolsos

**NO puede acceder a:**
- (Ninguna restricción adicional - tiene acceso completo)

---

## Prioridades de Implementación

### ✅ COMPLETADO
1. ✅ Proteger `AdminController` completo con `[Authorize(Policy = "AdminOnly")]`
2. ✅ Proteger `BookingsController` con políticas apropiadas
3. ✅ Agregar validación en `GetBooking` y `CancelBooking` para verificar propiedad
4. ✅ Actualizar `GetMyBookings` para obtener userId del token JWT
5. ✅ Actualizar `CreateBooking` para obtener userId del token JWT

### 🟡 IMPORTANTE (Funcionalidad)
1. Agregar validación en endpoints de Bookings para verificar que el usuario sea el dueño o admin
2. Agregar manejo de errores 403 (Forbidden) en el frontend

### 🟢 DESEABLE (Mejoras)
1. Agregar tests de autorización
2. Documentar en Swagger los requisitos de autenticación/autorización
3. Agregar logging de intentos de acceso no autorizados

---

## Notas de Implementación

### Cómo proteger un controlador completo:
```csharp
[ApiController]
[Route("api/admin")]
[Authorize(Policy = "AdminOnly")]  // <-- Agregar aquí
public class AdminController : ControllerBase
{
    // Todos los métodos heredan la protección
}
```

### Cómo proteger métodos específicos:
```csharp
[HttpGet("my")]
[Authorize(Policy = "CustomerOnly")]
public async Task<ActionResult> GetMyBookings()
{
    // Solo usuarios con rol Customer
}
```

### Cómo permitir público y admin:
```csharp
[HttpGet]
[Authorize]  // Cualquier usuario autenticado
public async Task<ActionResult> GetResource()
{
    // Usuario autenticado (Customer o Admin)
}
```

### Verificar propiedad del recurso:
```csharp
[HttpGet("{id}")]
[Authorize]
public async Task<ActionResult> GetBooking(Guid id)
{
    var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value);
    var booking = await _bookingService.GetBookingByIdAsync(id);
    
    // Verificar que el usuario sea el dueño o admin
    if (booking.UserId != userId && !User.IsInRole("Admin"))
    {
        return Forbid();
    }
    
    return Ok(booking);
}
```

