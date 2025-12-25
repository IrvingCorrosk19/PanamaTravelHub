# Flujo Completo de Usuario - PanamaTravelHub

## 📋 Guía Paso a Paso del Flujo de Reserva

### 1. 🏠 Inicio - Página Principal

**URL:** `http://localhost:5018/` o `https://localhost:7009/`

**Acciones:**
- Usuario ve la página principal con tours disponibles
- Puede navegar por el catálogo
- Puede buscar tours usando la barra de búsqueda
- Cada tour muestra:
  - Imagen principal
  - Nombre del tour
  - Precio
  - Duración
  - Ubicación
  - Estado (Disponible/Agotado)

**Endpoints utilizados:**
- `GET /api/tours` - Lista todos los tours activos
- `GET /api/tours/homepage-content` - Contenido de la homepage (incluyendo logo)

**Estado:** ✅ Funcional

---

### 2. 👁️ Ver Detalles del Tour

**URL:** `http://localhost:5018/tour-detail.html?id={tourId}`

**Acciones:**
- Usuario hace clic en un tour para ver detalles completos
- Ve información detallada:
  - Descripción completa
  - Itinerario
  - Qué incluye
  - Fechas disponibles
  - Precio
  - Capacidad
- Botón "Reservar Ahora" lo lleva al checkout

**Endpoints utilizados:**
- `GET /api/tours/{tourId}` - Detalles del tour
- `GET /api/tours/{tourId}/dates` - Fechas disponibles

**Estado:** ✅ Funcional

---

### 3. 🔐 Registro / Inicio de Sesión

**URL:** `http://localhost:5018/login.html`

#### 3.1. Registro de Nuevo Usuario

**Acciones:**
1. Usuario hace clic en "Regístrate" (toggle)
2. Completa el formulario:
   - Email (se valida en tiempo real si ya existe)
   - Contraseña (mínimo 8 caracteres, 1 mayúscula, 1 minúscula, 1 número)
   - Confirmar contraseña
   - Nombre
   - Apellido
3. Indicador de fortaleza de contraseña en tiempo real
4. Indicador de coincidencia de contraseñas
5. Al enviar, se crea la cuenta con rol "Customer"

**Endpoints utilizados:**
- `GET /api/auth/check-email?email={email}` - Validar email disponible
- `POST /api/auth/register` - Registrar nuevo usuario

**Validaciones:**
- Email único
- Contraseña segura
- Campos requeridos

**Estado:** ✅ Funcional

#### 3.2. Inicio de Sesión

**Acciones:**
1. Usuario ingresa email y contraseña
2. Validación de email en tiempo real (muestra si está registrado)
3. Sistema valida credenciales
4. Si es correcto:
   - Se genera JWT token
   - Se almacena en localStorage
   - Redirección según rol:
     - **Customer** → `/reservas.html`
     - **Admin** → `/admin.html`
5. Si es incorrecto:
   - Mensaje genérico (por seguridad)
   - Contador de intentos fallidos
   - Bloqueo temporal después de 5 intentos

**Endpoints utilizados:**
- `GET /api/auth/check-email?email={email}` - Verificar email
- `POST /api/auth/login` - Iniciar sesión

**Estado:** ✅ Funcional

---

### 4. 🛒 Checkout - Crear Reserva

**URL:** `http://localhost:5018/checkout.html?tourId={tourId}`

#### 4.1. Resumen del Tour

**Acciones:**
- Usuario ve resumen del tour seleccionado:
  - Nombre
  - Imagen
  - Precio por persona
  - Duración

**Estado:** ✅ Funcional

#### 4.2. Seleccionar Fecha

**Acciones:**
1. Sistema carga fechas disponibles del tour
2. Usuario selecciona una fecha del calendario
3. Se muestra:
   - Fecha y hora
   - Cupos disponibles
4. Solo se muestran fechas futuras con cupos disponibles

**Endpoints utilizados:**
- `GET /api/tours/{tourId}/dates` - Fechas disponibles

**Estado:** ✅ Funcional

#### 4.3. Seleccionar País ⭐ NUEVO

**Acciones:**
1. Sistema carga lista de países disponibles
2. Usuario selecciona el país desde el cual realiza la reserva
3. Campo opcional pero recomendado
4. Lista de países:
   - Costa Rica
   - Panamá
   - Estados Unidos
   - México
   - Colombia
   - Y más...

**Endpoints utilizados:**
- `GET /api/tours/countries` - Lista de países

**Estado:** ✅ Funcional (NUEVO)

#### 4.4. Información de Participantes

**Acciones:**
1. Usuario selecciona número de participantes (1-10)
2. Se generan campos dinámicos para cada participante:
   - Nombre (requerido)
   - Apellido (requerido)
   - Email (opcional)
   - Teléfono (opcional, validado)
   - Fecha de nacimiento (opcional)
3. Validación en tiempo real de cada campo

**Validaciones:**
- Nombre y apellido requeridos
- Email válido si se proporciona
- Teléfono válido si se proporciona
- Fecha de nacimiento válida si se proporciona

**Estado:** ✅ Funcional

#### 4.5. Método de Pago

**Opciones disponibles:**

**a) Stripe (Tarjeta de Crédito/Débito)**
- Visa, Mastercard, Amex
- Campos:
  - Número de tarjeta
  - Fecha de vencimiento (MM/AA)
  - CVV
  - Nombre en la tarjeta
- Pago seguro con SSL
- Modo prueba: Tarjeta `4242 4242 4242 4242`

**b) PayPal**
- Pago rápido y seguro
- Redirección a PayPal
- Modo sandbox para pruebas

**c) Yappy (Pago Móvil Panameño)**
- Método local panameño
- Requiere número de teléfono
- Genera código QR para escanear

**Estado:** ✅ Funcional (Stripe y Yappy implementados, PayPal parcial)

#### 4.6. Resumen de Orden

**Información mostrada:**
- Tour seleccionado
- Fecha seleccionada
- Número de participantes
- Precio por persona
- **Total** (precio × participantes)
- Método de pago seleccionado

**Estado:** ✅ Funcional

#### 4.7. Confirmar y Pagar

**Flujo completo:**
1. Usuario completa toda la información
2. Hace clic en "Confirmar Reserva"
3. **Backend crea la reserva:**
   - Valida cupos disponibles
   - Crea registro en `bookings`
   - Guarda participantes en `booking_participants`
   - Asocia país si se seleccionó
   - Estado inicial: `Pending`
   - Expira en 24 horas si no se paga
4. **Procesa el pago:**
   - Crea payment intent según método
   - Procesa transacción
   - Si es exitoso: marca reserva como `Confirmed`
5. **Notificaciones:**
   - Email de confirmación (✅ implementado)
   - SMS (⚠️ pendiente)
6. Redirección a página de éxito

**Endpoints utilizados:**
- `POST /api/bookings` - Crear reserva
- `POST /api/payments/create` - Crear payment intent
- `POST /api/payments/confirm` - Confirmar pago

**Estado:** ✅ Funcional (Email ✅, SMS ⚠️ pendiente)

---

### 5. ✅ Página de Éxito

**URL:** `http://localhost:5018/booking-success.html?bookingId={id}&amount={amount}`

**Información mostrada:**
- Mensaje de confirmación
- ID de reserva
- Monto pagado
- Detalles del tour
- Próximos pasos
- Botón para ver mis reservas

**Estado:** ✅ Funcional

---

### 6. 📋 Ver Mis Reservas

**URL:** `http://localhost:5018/reservas.html`

**Acciones:**
1. Usuario debe estar autenticado
2. Sistema carga todas sus reservas
3. Se muestra:
   - Estado (Pending, Confirmed, Cancelled, Completed)
   - Tour reservado
   - Fecha del tour
   - Número de participantes
   - Monto total
   - Fecha de creación
4. Acciones disponibles:
   - Ver detalles completos
   - Cancelar (si está permitido)

**Endpoints utilizados:**
- `GET /api/bookings/my` - Obtener mis reservas
- `GET /api/bookings/{id}` - Detalles de reserva
- `POST /api/bookings/{id}/cancel` - Cancelar reserva

**Validaciones:**
- Usuario solo ve sus propias reservas
- No puede cancelar reservas confirmadas/completadas (reglas de negocio)

**Estado:** ✅ Funcional

---

### 7. 📄 Detalles de Reserva

**Acciones:**
- Usuario ve información completa:
  - Detalles del tour
  - Información de pago
  - Lista de participantes
  - Estado actual
  - Fechas importantes
  - Notas (si las hay)

**Endpoints utilizados:**
- `GET /api/bookings/{id}` - Detalles de reserva

**Validaciones:**
- Usuario solo puede ver sus propias reservas
- Admin puede ver todas

**Estado:** ✅ Funcional

---

### 8. ❌ Cancelar Reserva

**Acciones:**
1. Usuario selecciona reserva a cancelar
2. Confirma cancelación
3. Sistema valida:
   - Reserva pertenece al usuario
   - Estado permite cancelación
4. Si procede:
   - Actualiza estado a `Cancelled`
   - Libera cupos
   - Envía email de cancelación
   - Procesa reembolso si aplica

**Endpoints utilizados:**
- `POST /api/bookings/{id}/cancel` - Cancelar reserva

**Estado:** ✅ Funcional

---

## 🔄 Flujo Alternativo: Recuperación de Contraseña

### 9. 🔑 ¿Olvidaste tu Contraseña?

**URL:** `http://localhost:5018/forgot-password.html`

**Acciones:**
1. Usuario ingresa su email
2. Sistema genera token de recuperación
3. Envía email con link de recuperación
4. Usuario recibe email (mensaje genérico por seguridad)
5. Hace clic en el link → redirección a reset-password.html

**Endpoints utilizados:**
- `POST /api/auth/forgot-password` - Solicitar recuperación

**Estado:** ✅ Funcional

### 10. 🔄 Resetear Contraseña

**URL:** `http://localhost:5018/reset-password.html?token={token}`

**Acciones:**
1. Usuario ingresa nueva contraseña
2. Confirma nueva contraseña
3. Validaciones:
   - Token válido y no expirado (15 minutos)
   - Token no usado previamente
   - Contraseña cumple requisitos
   - Contraseñas coinciden
4. Si es válido:
   - Actualiza contraseña (hash con BCrypt)
   - Invalida token
   - Invalida todos los refresh tokens del usuario
   - Redirección a login

**Endpoints utilizados:**
- `POST /api/auth/reset-password` - Resetear contraseña

**Estado:** ✅ Funcional

---

## 🎨 Características Adicionales Implementadas

### ✨ Logo Dinámico ⭐ NUEVO

- Logo principal en navbar
- Logo en footer
- Favicon configurable
- Logo para redes sociales (Open Graph)
- Gestión desde panel de administración

**Estado:** ✅ Funcional (NUEVO)

### 🌍 Sistema Multi-País ⭐ NUEVO

- Selección de país en reservas
- Tabla de países con 20+ países iniciales
- Preparado para expansión internacional
- País asociado a cada reserva

**Estado:** ✅ Funcional (NUEVO)

---

## 🔒 Seguridad Implementada

1. **Autenticación JWT:**
   - Access tokens (15 min)
   - Refresh tokens (7 días)
   - Almacenamiento seguro en localStorage

2. **Autorización:**
   - Roles: Admin, Customer
   - Endpoints protegidos según rol
   - Usuarios solo ven sus propias reservas

3. **Validaciones:**
   - FluentValidation en backend
   - Validación en frontend
   - Protección contra ataques comunes

4. **Contraseñas:**
   - Hash con BCrypt (work factor 12)
   - Requisitos de complejidad
   - Bloqueo de cuenta después de intentos fallidos

5. **Tokens:**
   - Tokens de recuperación con expiración
   - Tokens de un solo uso
   - Hash de tokens en base de datos

---

## 📊 Estado de Funcionalidades

| Funcionalidad | Estado | Notas |
|---------------|--------|-------|
| Registro de Usuario | ✅ | Completo |
| Inicio de Sesión | ✅ | Completo |
| Recuperación de Contraseña | ✅ | Completo |
| Catálogo de Tours | ✅ | Completo |
| Detalles de Tour | ✅ | Completo |
| Crear Reserva | ✅ | Completo |
| Selección de País | ✅ | NUEVO |
| Selección de Fecha | ✅ | Completo |
| Información de Participantes | ✅ | Completo |
| Pago con Stripe | ✅ | Completo |
| Pago con Yappy | ✅ | Completo |
| Pago con PayPal | ⚠️ | Parcial |
| Ver Mis Reservas | ✅ | Completo |
| Detalles de Reserva | ✅ | Completo |
| Cancelar Reserva | ✅ | Completo |
| Notificaciones Email | ✅ | Completo |
| Notificaciones SMS | ❌ | Pendiente |
| Logo Dinámico | ✅ | NUEVO |
| Gestión de Contenido | ✅ | Completo |

---

## 🚀 Próximos Pasos Recomendados

1. **Sistema de SMS:**
   - Integrar Twilio o proveedor SMS
   - Enviar notificaciones por SMS al crear/cancelar reservas

2. **Sistema de Blog:**
   - Completar endpoints públicos
   - Crear frontend para mostrar blog
   - Categorías y tags

3. **Mejoras de UX:**
   - Recordatorios automáticos de tours próximos
   - Sistema de reseñas
   - Historial de pagos detallado

---

## 📝 Notas Técnicas

- **Base de datos:** PostgreSQL en Render
- **Framework:** ASP.NET Core 8
- **Frontend:** HTML/CSS/JavaScript vanilla
- **Autenticación:** JWT
- **Pagos:** Stripe, Yappy, PayPal
- **Logging:** Serilog
- **Validación:** FluentValidation

---

**Última actualización:** 2025-01-XX
**Versión:** 1.0.0

