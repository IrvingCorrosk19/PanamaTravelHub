# Flujo Completo de Reserva de Cupo - PanamaTravelHub

## 📋 Resumen del Flujo

Este documento describe el flujo completo de reserva de cupo desde la página principal hasta la confirmación final.

---

## 🎯 Paso 1: Acceso a la Homepage

**URL:** `https://localhost:7009/` o `http://localhost:5018/`

### Acciones del Usuario:
1. El usuario accede a la página principal
2. Ve el hero section con título, subtítulo e imagen de fondo
3. Puede buscar tours usando la barra de búsqueda
4. Puede usar filtros avanzados (precio, duración, ubicación)

### Elementos Visuales:
- ✅ Hero section con imagen de fondo
- ✅ Barra de búsqueda prominente
- ✅ Botón "Buscar"
- ✅ Toggle de filtros avanzados
- ✅ Grid de tours disponibles

### Verificaciones:
- [ ] La página carga correctamente
- [ ] Los tours se muestran en grid
- [ ] La búsqueda funciona
- [ ] Los filtros funcionan

---

## 🔍 Paso 2: Búsqueda y Selección de Tour

### Acciones del Usuario:
1. Usuario busca un tour (ej: "Panamá", "Canal", "Islas")
2. O hace clic en un tour del grid
3. Ve la lista de tours filtrados
4. Hace clic en "Ver Detalles" o en la tarjeta del tour

### Elementos Visuales:
- ✅ Grid de tours con imágenes
- ✅ Información básica: nombre, precio, duración, ubicación
- ✅ Botón "Ver Detalles" o tarjeta clickeable

### Verificaciones:
- [ ] Los tours se filtran correctamente
- [ ] La búsqueda retorna resultados relevantes
- [ ] Los filtros aplican correctamente
- [ ] Al hacer clic, navega a `tour-detail.html?id={tourId}`

---

## 📄 Paso 3: Página de Detalle del Tour

**URL:** `https://localhost:7009/tour-detail.html?id={tourId}`

### Acciones del Usuario:
1. Ve la información completa del tour:
   - Galería de imágenes
   - Descripción detallada
   - Itinerario
   - Incluye/Excluye
   - Precio por persona
   - Disponibilidad
   - Duración
   - Ubicación
   - Mapa (si está disponible)
   - Reviews/Calificaciones

2. Puede:
   - Ver todas las imágenes en carousel
   - Agregar a favoritos (si está logueado)
   - Ver reviews de otros usuarios
   - Hacer clic en "Reservar Ahora"

### Elementos Visuales:
- ✅ Sidebar sticky con precio y disponibilidad
- ✅ Botón "Reservar Ahora" prominente
- ✅ Galería de imágenes con carousel
- ✅ Secciones de información organizadas
- ✅ Sticky CTA en móvil

### Verificaciones:
- [ ] El tour se carga correctamente
- [ ] Las imágenes se muestran en carousel
- [ ] El precio y disponibilidad son correctos
- [ ] El botón "Reservar Ahora" funciona
- [ ] Los reviews se muestran (si existen)

---

## 🛒 Paso 4: Checkout - Página de Reserva

**URL:** `https://localhost:7009/checkout.html?tourId={tourId}`

### 4.1. Autenticación Inline (si no está logueado)

**Acciones del Usuario:**
1. Si no está autenticado, ve sección de login/registro inline
2. Ingresa su email
3. Sistema detecta si el email existe:
   - **Si existe:** Muestra campo de contraseña → Login
   - **Si NO existe:** Muestra campos de registro (nombre, apellido, contraseña) → Registro automático

**Elementos Visuales:**
- ✅ Sección "Inicia Sesión o Continúa Rápido"
- ✅ Campo de email
- ✅ Campos dinámicos según si el email existe o no
- ✅ Botón "Continuar"
- ✅ Mensaje: "Al continuar, creas una cuenta automáticamente si no tienes una"

**Verificaciones:**
- [ ] El sistema detecta correctamente si el email existe
- [ ] Muestra los campos apropiados
- [ ] El login funciona
- [ ] El registro automático funciona
- [ ] Después de autenticarse, la sección desaparece

### 4.2. Selección de Participantes

**Acciones del Usuario:**
1. Selecciona número de participantes (1-10)
2. Ve el precio total actualizado automáticamente

**Elementos Visuales:**
- ✅ Campo numérico "Número de Personas"
- ✅ Hint: "Podrás completar los datos de cada participante después de confirmar la reserva"
- ✅ Precio total actualizado en tiempo real

**Verificaciones:**
- [ ] El contador funciona (1-10)
- [ ] El precio total se actualiza correctamente
- [ ] El cálculo es: `precio * número de participantes`

### 4.3. Selección de Fecha (si el tour tiene fechas disponibles)

**Acciones del Usuario:**
1. Ve un calendario o lista de fechas disponibles
2. Selecciona una fecha para el tour
3. Ve la disponibilidad de esa fecha

**Elementos Visuales:**
- ✅ Selector de fecha (calendario o dropdown)
- ✅ Fechas disponibles destacadas
- ✅ Fechas no disponibles deshabilitadas

**Verificaciones:**
- [ ] Las fechas disponibles se muestran correctamente
- [ ] Las fechas no disponibles están deshabilitadas
- [ ] La selección funciona

### 4.4. Aplicación de Cupón (Opcional)

**Acciones del Usuario:**
1. Ve campo "¿Tienes un cupón?"
2. Ingresa código de cupón
3. Hace clic en "Aplicar"
4. Ve el descuento aplicado
5. El precio total se actualiza automáticamente

**Elementos Visuales:**
- ✅ Campo de texto para código de cupón
- ✅ Botón "Aplicar"
- ✅ Mensaje de éxito/error
- ✅ Descuento mostrado en resumen
- ✅ Precio total actualizado

**Verificaciones:**
- [ ] El cupón válido se aplica correctamente
- [ ] El cupón inválido muestra error
- [ ] El cupón expirado muestra error
- [ ] El cupón con límite de usos funciona
- [ ] El precio se recalcula correctamente
- [ ] El cupón se puede remover

### 4.5. Selección de Método de Pago

**Acciones del Usuario:**
1. Ve opciones de pago:
   - 💳 Tarjeta de Crédito/Débito (Stripe)
   - 🅿️ PayPal
   - 💰 Yappy
2. Selecciona un método
3. Si selecciona tarjeta, completa:
   - Número de tarjeta
   - Vencimiento (MM/AA)
   - CVV
   - Nombre en la tarjeta

**Elementos Visuales:**
- ✅ Cards de métodos de pago
- ✅ Radio buttons para selección
- ✅ Campos de tarjeta (si Stripe está seleccionado)
- ✅ Iconos distintivos para cada método

**Verificaciones:**
- [ ] Los métodos de pago se muestran
- [ ] La selección funciona
- [ ] Los campos de tarjeta aparecen solo para Stripe
- [ ] La validación de tarjeta funciona (formato)

### 4.6. Resumen de Reserva (Sidebar Derecho)

**Elementos Visuales:**
- ✅ Imagen del tour
- ✅ Nombre del tour
- ✅ Precio por persona
- ✅ Número de participantes
- ✅ Subtotal
- ✅ Descuento (si hay cupón)
- ✅ Total
- ✅ Información adicional (duración, fecha, etc.)

**Verificaciones:**
- [ ] El resumen se actualiza en tiempo real
- [ ] Todos los valores son correctos
- [ ] El cálculo del total es preciso

### 4.7. Confirmación y Pago

**Acciones del Usuario:**
1. Revisa toda la información
2. Acepta términos y condiciones (si aplica)
3. Hace clic en "Confirmar Reserva" o "Pagar Ahora"
4. Ve indicador de carga
5. Espera confirmación

**Elementos Visuales:**
- ✅ Botón grande "Confirmar Reserva"
- ✅ Spinner de carga durante el proceso
- ✅ Mensajes de estado

**Verificaciones:**
- [ ] El botón está habilitado solo cuando todo está completo
- [ ] El proceso de pago funciona
- [ ] Los errores se manejan correctamente
- [ ] La reserva se crea en la base de datos

---

## ✅ Paso 5: Página de Confirmación

**URL:** `https://localhost:7009/booking-success.html?bookingId={bookingId}`

### Acciones del Usuario:
1. Ve mensaje de confirmación
2. Ve detalles de la reserva:
   - ID de reserva
   - Tour reservado
   - Fecha del tour
   - Número de participantes
   - Total pagado
   - Estado de la reserva
3. Recibe email de confirmación (automático)
4. Puede:
   - Ver detalles completos
   - Descargar comprobante (si está disponible)
   - Ir a "Mis Reservas"
   - Volver al inicio

### Elementos Visuales:
- ✅ Mensaje de éxito grande
- ✅ Icono de confirmación (✓)
- ✅ Detalles de la reserva en card
- ✅ Botones de acción:
   - "Ver Mis Reservas"
   - "Volver al Inicio"
   - "Descargar Comprobante" (si está disponible)

### Verificaciones:
- [ ] La página se carga correctamente
- [ ] Los detalles de la reserva son correctos
- [ ] El email de confirmación se envía
- [ ] Los botones de navegación funcionan

---

## 📧 Paso 6: Notificaciones y Seguimiento

### Email de Confirmación

**Contenido:**
- ✅ Asunto: "Confirmación de Reserva - {Nombre del Tour}"
- ✅ Saludo personalizado
- ✅ Detalles de la reserva:
   - ID de reserva
   - Tour
   - Fecha
   - Participantes
   - Total
- ✅ Instrucciones adicionales
- ✅ Contacto de soporte
- ✅ Botón "Ver Reserva" (link a reservas.html)

### SMS (si está configurado)

**Contenido:**
- ✅ Mensaje breve de confirmación
- ✅ ID de reserva
- ✅ Fecha del tour

---

## 🔄 Flujos Alternativos y Casos Especiales

### Caso 1: Tour Sin Disponibilidad

**Flujo:**
1. Usuario intenta reservar
2. Sistema detecta que no hay cupos disponibles
3. Muestra mensaje: "Lo sentimos, este tour no tiene cupos disponibles"
4. Ofrece opción de agregarse a waitlist
5. Si acepta, se agrega a waitlist
6. Recibe notificación cuando hay disponibilidad

### Caso 2: Cupón Inválido

**Flujo:**
1. Usuario ingresa código de cupón
2. Hace clic en "Aplicar"
3. Sistema valida el cupón
4. Si es inválido, muestra error:
   - "Cupón no encontrado"
   - "Cupón expirado"
   - "Cupón ya utilizado"
   - "Cupón no aplicable a este tour"
5. El usuario puede intentar con otro código

### Caso 3: Pago Fallido

**Flujo:**
1. Usuario completa el checkout
2. Hace clic en "Confirmar Reserva"
3. El pago falla (tarjeta rechazada, fondos insuficientes, etc.)
4. Sistema muestra error específico
5. Usuario puede:
   - Intentar con otro método de pago
   - Corregir información de tarjeta
   - Contactar soporte

### Caso 4: Usuario No Autenticado

**Flujo:**
1. Usuario navega sin estar logueado
2. Puede ver tours y detalles
3. Al intentar reservar, se le pide autenticarse
4. Puede registrarse o iniciar sesión inline
5. Continúa con el proceso de reserva

### Caso 5: Reserva Parcial (Pago Parcial)

**Flujo:**
1. Usuario selecciona "Pago Parcial" (si está disponible)
2. Paga un porcentaje del total
3. Recibe confirmación de reserva parcial
4. Debe completar el pago antes de la fecha del tour
5. Recibe recordatorios de pago pendiente

---

## 🧪 Checklist de Pruebas

### Pruebas Funcionales

- [ ] **Homepage carga correctamente**
- [ ] Búsqueda de tours funciona
- [ ] Filtros aplican correctamente
- [ ] Navegación a detalle de tour funciona
- [ ] Detalle de tour muestra toda la información
- [ ] Botón "Reservar Ahora" navega a checkout
- [ ] Autenticación inline funciona (login y registro)
- [ ] Selección de participantes funciona
- [ ] Selección de fecha funciona (si aplica)
- [ ] Aplicación de cupón funciona
- [ ] Validación de cupón funciona (válido, inválido, expirado)
- [ ] Selección de método de pago funciona
- [ ] Campos de tarjeta se validan correctamente
- [ ] Resumen de reserva se actualiza en tiempo real
- [ ] Proceso de pago funciona
- [ ] Reserva se crea en la base de datos
- [ ] Página de confirmación muestra detalles correctos
- [ ] Email de confirmación se envía
- [ ] SMS de confirmación se envía (si está configurado)

### Pruebas de UI/UX

- [ ] Diseño es responsive (móvil, tablet, desktop)
- [ ] Los elementos son clickeables y accesibles
- [ ] Los mensajes de error son claros
- [ ] Los mensajes de éxito son claros
- [ ] Los indicadores de carga se muestran
- [ ] La navegación es intuitiva
- [ ] Los precios se formatean correctamente
- [ ] Las imágenes se cargan correctamente

### Pruebas de Integración

- [ ] API de tours responde correctamente
- [ ] API de autenticación funciona
- [ ] API de cupones funciona
- [ ] API de reservas funciona
- [ ] API de pagos funciona (Stripe/PayPal/Yappy)
- [ ] Servicio de email funciona
- [ ] Servicio de SMS funciona (si está configurado)

### Pruebas de Seguridad

- [ ] Los datos sensibles no se exponen en el frontend
- [ ] Las validaciones se hacen en backend
- [ ] Los tokens de autenticación se manejan correctamente
- [ ] Los pagos se procesan de forma segura
- [ ] Los cupones se validan en backend

---

## 📝 Notas Técnicas

### Endpoints Utilizados

1. **GET** `/api/tours` - Listar tours
2. **GET** `/api/tours/{id}` - Obtener detalle de tour
3. **GET** `/api/tours/search` - Buscar tours
4. **POST** `/api/auth/login` - Iniciar sesión
5. **POST** `/api/auth/register` - Registrar usuario
6. **GET** `/api/coupons/validate/{code}` - Validar cupón
7. **POST** `/api/bookings` - Crear reserva
8. **POST** `/api/payments/process` - Procesar pago

### Variables de Estado

- `currentTour` - Tour actual seleccionado
- `numberOfParticipants` - Número de participantes
- `selectedTourDateId` - Fecha seleccionada
- `appliedCoupon` - Cupón aplicado
- `selectedPaymentMethod` - Método de pago seleccionado

### Validaciones Importantes

1. **Participantes:** Mínimo 1, máximo 10 (o según disponibilidad)
2. **Fecha:** Debe ser futura y tener disponibilidad
3. **Cupón:** Debe ser válido, no expirado, y aplicable
4. **Pago:** Tarjeta debe ser válida, fondos suficientes
5. **Disponibilidad:** Debe haber cupos suficientes

---

## 🎯 Resultado Esperado

Al completar el flujo, el usuario debe:

1. ✅ Haber seleccionado un tour
2. ✅ Haber completado la autenticación (si era necesario)
3. ✅ Haber seleccionado participantes y fecha
4. ✅ Haber aplicado un cupón (opcional)
5. ✅ Haber completado el pago
6. ✅ Haber recibido confirmación
7. ✅ Tener la reserva visible en "Mis Reservas"
8. ✅ Haber recibido email de confirmación

---

## 🐛 Problemas Conocidos y Soluciones

### Problema: Cupón no se aplica
**Solución:** Verificar que el cupón esté activo, no expirado, y aplicable al tour

### Problema: Pago falla
**Solución:** Verificar configuración de Stripe/PayPal, fondos suficientes, tarjeta válida

### Problema: Reserva no se crea
**Solución:** Verificar logs del backend, validaciones, disponibilidad de cupos

### Problema: Email no se envía
**Solución:** Verificar configuración de SMTP, cola de emails, logs del servicio

---

## 📚 Referencias

- `checkout.js` - Lógica principal del checkout
- `api.js` - Cliente API
- `main.js` - Lógica de la homepage
- `tour-detail.html` - Página de detalle
- `checkout.html` - Página de checkout
- `booking-success.html` - Página de confirmación
