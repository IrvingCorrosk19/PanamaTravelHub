# 🧪 Guía Práctica de Prueba - Flujo Completo de Usuario

## 📋 Checklist de Preparación

Antes de comenzar, asegúrate de:

- [ ] Base de datos PostgreSQL funcionando (Render o local)
- [ ] Scripts SQL ejecutados:
  - [ ] `database/08_add_logo_fields.sql` - Campos de logo
  - [ ] `database/09_add_countries_and_country_to_bookings.sql` - Países y campo en bookings
- [ ] Aplicación compilada sin errores
- [ ] Servidor corriendo en `http://localhost:5018` o `https://localhost:7009`
- [ ] Tener al menos un tour creado en la base de datos

---

## 🎯 Flujo de Prueba Completo

### Paso 1: Acceder a la Página Principal

**Acción:**
1. Abre tu navegador
2. Ve a `http://localhost:5018/` o `https://localhost:7009/`

**Verificar:**
- ✅ Página carga correctamente
- ✅ Logo aparece (si está configurado)
- ✅ Se muestran los tours disponibles
- ✅ Barra de búsqueda funciona
- ✅ Navegación visible (Tours, Mis Reservas, Iniciar Sesión)

**Si no hay tours:**
- Ve al panel de admin (`/admin.html`) y crea al menos un tour

---

### Paso 2: Ver Detalles de un Tour

**Acción:**
1. Haz clic en cualquier tour de la lista
2. O ve directamente a `/tour-detail.html?id={tourId}`

**Verificar:**
- ✅ Página de detalles carga
- ✅ Información completa del tour se muestra
- ✅ Imágenes se cargan
- ✅ Precio visible
- ✅ Botón "Reservar Ahora" visible
- ✅ Fechas disponibles se muestran (si hay)

---

### Paso 3: Registrar un Nuevo Usuario

**Acción:**
1. Haz clic en "Iniciar Sesión"
2. Haz clic en "Regístrate" (toggle)
3. Completa el formulario:
   ```
   Email: test@example.com
   Contraseña: Test1234!
   Confirmar Contraseña: Test1234!
   Nombre: Juan
   Apellido: Pérez
   ```
4. Observa las validaciones en tiempo real:
   - Indicador de fortaleza de contraseña
   - Indicador de coincidencia de contraseñas
   - Validación de email (muestra si ya existe)
5. Haz clic en "Registrarse"

**Verificar:**
- ✅ Formulario valida correctamente
- ✅ Email disponible muestra mensaje positivo
- ✅ Contraseña cumple requisitos (8+ chars, mayúscula, minúscula, número)
- ✅ Registro exitoso
- ✅ Redirección automática a `/reservas.html` (o login si hay error)

**Nota:** Si el email ya existe, usa otro diferente.

---

### Paso 4: Iniciar Sesión

**Acción:**
1. Si no estás logueado, ve a `/login.html`
2. Ingresa:
   ```
   Email: test@example.com
   Contraseña: Test1234!
   ```
3. Haz clic en "Iniciar Sesión"

**Verificar:**
- ✅ Validación de email en tiempo real (muestra si está registrado)
- ✅ Login exitoso
- ✅ Token almacenado en localStorage
- ✅ Redirección según rol:
  - Customer → `/reservas.html`
  - Admin → `/admin.html`

---

### Paso 5: Explorar Tours Disponibles

**Acción:**
1. Ve a la página principal (`/`)
2. Explora los tours disponibles
3. Usa la barra de búsqueda si hay muchos tours

**Verificar:**
- ✅ Tours se cargan correctamente
- ✅ Búsqueda funciona
- ✅ Filtros funcionan (si hay)

---

### Paso 6: Crear una Reserva (Flujo Completo)

#### 6.1. Seleccionar Tour y Fecha

**Acción:**
1. Haz clic en "Reservar Ahora" en cualquier tour
2. O ve a `/checkout.html?tourId={tourId}`

**Verificar:**
- ✅ Página de checkout carga
- ✅ Resumen del tour visible
- ✅ Fechas disponibles se cargan
- ✅ Calendario de fechas se muestra

#### 6.2. Seleccionar País ⭐ NUEVO

**Acción:**
1. En la sección "Información de Ubicación"
2. Selecciona un país del dropdown (ej: "Costa Rica")

**Verificar:**
- ✅ Lista de países se carga
- ✅ Puedes seleccionar un país
- ✅ Campo es opcional

#### 6.3. Agregar Participantes

**Acción:**
1. Selecciona número de participantes (ej: 2)
2. Completa información de cada participante:
   ```
   Participante 1:
   - Nombre: Juan
   - Apellido: Pérez
   - Email: juan@example.com
   - Teléfono: +507 6000-0000
   
   Participante 2:
   - Nombre: María
   - Apellido: González
   - Email: maria@example.com
   - Teléfono: +507 6000-0001
   ```

**Verificar:**
- ✅ Campos dinámicos se generan según número de participantes
- ✅ Validaciones en tiempo real funcionan
- ✅ Email válido se valida
- ✅ Teléfono válido se valida

#### 6.4. Seleccionar Método de Pago

**Opción A: Stripe (Tarjeta)**

**Acción:**
1. Selecciona "Tarjeta de Crédito/Débito"
2. Completa:
   ```
   Número de Tarjeta: 4242 4242 4242 4242
   Fecha de Vencimiento: 12/25
   CVV: 123
   Nombre en la Tarjeta: Juan Pérez
   ```

**Opción B: Yappy**

**Acción:**
1. Selecciona "Yappy"
2. Ingresa número de teléfono: `+507 6000-0000`

#### 6.5. Revisar Resumen

**Verificar:**
- ✅ Resumen muestra tour correcto
- ✅ Fecha seleccionada visible
- ✅ Número de participantes correcto
- ✅ País seleccionado visible (si se seleccionó)
- ✅ Total calculado correctamente (precio × participantes)
- ✅ Método de pago visible

#### 6.6. Confirmar Reserva

**Acción:**
1. Haz clic en "Confirmar Reserva"
2. Observa el proceso:
   - "Creando reserva..."
   - "Procesando pago..."
   - Redirección a página de éxito

**Verificar:**
- ✅ Reserva se crea correctamente
- ✅ Pago se procesa
- ✅ Redirección a `/booking-success.html`
- ✅ Email de confirmación enviado (verificar logs o bandeja)

---

### Paso 7: Ver Página de Éxito

**Acción:**
1. Observa la página de éxito
2. Verifica la información mostrada

**Verificar:**
- ✅ Mensaje de confirmación visible
- ✅ ID de reserva mostrado
- ✅ Monto pagado correcto
- ✅ Botón "Ver Mis Reservas" funciona

---

### Paso 8: Ver Mis Reservas

**Acción:**
1. Haz clic en "Ver Mis Reservas" o ve a `/reservas.html`
2. Observa la lista de reservas

**Verificar:**
- ✅ Lista de reservas se carga
- ✅ Reserva recién creada aparece
- ✅ Estado correcto (Confirmed)
- ✅ Información correcta:
  - Tour
  - Fecha
  - Participantes
  - Monto
- ✅ País visible (si se seleccionó)

---

### Paso 9: Ver Detalles de Reserva

**Acción:**
1. Haz clic en una reserva para ver detalles
2. O ve a la API directamente

**Verificar:**
- ✅ Detalles completos se muestran
- ✅ Lista de participantes visible
- ✅ Información de pago visible
- ✅ País asociado visible (si se seleccionó)
- ✅ Estado actual visible

---

### Paso 10: Cancelar Reserva (Opcional)

**Acción:**
1. Selecciona una reserva que puedas cancelar
2. Haz clic en "Cancelar"
3. Confirma la cancelación

**Verificar:**
- ✅ Cancelación exitosa
- ✅ Estado cambia a "Cancelled"
- ✅ Cupos liberados
- ✅ Email de cancelación enviado

---

## 🔍 Verificaciones Adicionales

### Verificar en Base de Datos

**Reserva creada:**
```sql
SELECT b.*, c.name as country_name, u.email as user_email
FROM bookings b
LEFT JOIN countries c ON b.country_id = c.id
LEFT JOIN users u ON b.user_id = u.id
ORDER BY b.created_at DESC
LIMIT 5;
```

**Participantes:**
```sql
SELECT bp.*
FROM booking_participants bp
JOIN bookings b ON bp.booking_id = b.id
ORDER BY bp.created_at DESC
LIMIT 10;
```

**País asociado:**
```sql
SELECT b.id, c.code, c.name
FROM bookings b
JOIN countries c ON b.country_id = c.id
WHERE b.country_id IS NOT NULL;
```

### Verificar Logs

**Backend:**
- Revisa logs en consola o archivo de logs
- Busca mensajes de:
  - Reserva creada
  - Pago procesado
  - Email enviado
  - Errores (si hay)

**Frontend:**
- Abre DevTools (F12)
- Ve a la pestaña Console
- Busca errores de JavaScript
- Ve a Network para ver llamadas API

---

## ❌ Problemas Comunes y Soluciones

### 1. Error: "No hay tours disponibles"

**Solución:**
- Ve al panel de admin (`/admin.html`)
- Crea al menos un tour
- Asegúrate de que el tour esté activo

### 2. Error: "Email ya existe"

**Solución:**
- Usa un email diferente
- O inicia sesión con ese email

### 3. Error: "No hay fechas disponibles"

**Solución:**
- Ve al panel de admin
- Agrega fechas disponibles al tour
- Asegúrate de que las fechas sean futuras y tengan cupos

### 4. Error: "No se puede crear reserva"

**Solución:**
- Verifica que estés autenticado
- Verifica que haya cupos disponibles
- Revisa logs del backend para más detalles

### 5. Error: "Pago falló"

**Solución:**
- Para Stripe: usa tarjeta de prueba `4242 4242 4242 4242`
- Verifica que Stripe esté configurado en `appsettings.json`
- Revisa logs del backend

### 6. País no aparece en el selector

**Solución:**
- Ejecuta el script `database/09_add_countries_and_country_to_bookings.sql`
- Verifica que la tabla `countries` tenga datos:
  ```sql
  SELECT * FROM countries WHERE is_active = true;
  ```

---

## 📊 Checklist de Funcionalidades

Marca cada funcionalidad que pruebes:

### Autenticación
- [ ] Registro de usuario
- [ ] Inicio de sesión
- [ ] Validación de email en tiempo real
- [ ] Indicador de fortaleza de contraseña
- [ ] Recuperación de contraseña

### Tours
- [ ] Listar tours
- [ ] Ver detalles de tour
- [ ] Buscar tours
- [ ] Fechas disponibles

### Reservas
- [ ] Crear reserva
- [ ] Seleccionar fecha
- [ ] Seleccionar país ⭐ NUEVO
- [ ] Agregar participantes
- [ ] Seleccionar método de pago
- [ ] Procesar pago
- [ ] Ver mis reservas
- [ ] Ver detalles de reserva
- [ ] Cancelar reserva

### Pagos
- [ ] Pago con Stripe
- [ ] Pago con Yappy
- [ ] Confirmación de pago
- [ ] Página de éxito

### Notificaciones
- [ ] Email de confirmación
- [ ] Email de cancelación

### UI/UX
- [ ] Logo dinámico ⭐ NUEVO
- [ ] Favicon
- [ ] Meta tags Open Graph
- [ ] Responsive design
- [ ] Loading states
- [ ] Error handling

---

## 🎯 Resultado Esperado

Al completar este flujo, deberías tener:

1. ✅ Usuario registrado y autenticado
2. ✅ Reserva creada exitosamente
3. ✅ Pago procesado
4. ✅ Reserva visible en "Mis Reservas"
5. ✅ País asociado a la reserva
6. ✅ Email de confirmación recibido
7. ✅ Datos correctos en base de datos

---

## 📝 Notas Finales

- Este flujo prueba la funcionalidad básica del sistema
- Para pruebas avanzadas, prueba casos edge:
  - Reservas sin fecha
  - Reservas sin país
  - Múltiples participantes
  - Cancelaciones en diferentes estados
  - Errores de pago

- Los logs son tu mejor amigo para debugging
- Usa DevTools para ver llamadas API y errores

---

**Última actualización:** 2025-01-XX
**Versión:** 1.0.0

