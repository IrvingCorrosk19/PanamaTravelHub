# 📱 Implementación de SMS Notifications y Blog Público

## ✅ Sistema de SMS Notifications

### 📋 Componentes Implementados

#### 1. Entidades y Enums
- **`SmsNotification`**: Entidad principal para almacenar SMS
  - Campos: `ToPhoneNumber`, `Message`, `Type`, `Status`, `ProviderMessageId`, etc.
  - Similar a `EmailNotification` para consistencia

- **`SmsNotificationType`**: Tipos de SMS
  - `BookingConfirmation = 1`
  - `BookingReminder = 2`
  - `PaymentConfirmation = 3`
  - `BookingCancellation = 4`

- **`SmsNotificationStatus`**: Estados de SMS
  - `Pending = 1`
  - `Sent = 2`
  - `Failed = 3`
  - `Retrying = 4`

#### 2. Servicio de SMS
- **`ISmsNotificationService`**: Interfaz del servicio
- **`SmsNotificationService`**: Implementación con soporte para Twilio
  - Modo simulador para desarrollo (configurable)
  - Normalización de números telefónicos (formato E.164)
  - Plantillas de SMS predefinidas
  - Reintentos automáticos
  - Procesamiento de cola

#### 3. Integración con Reservas
- **Al crear reserva**: Envía SMS de confirmación
- **Al cancelar reserva**: Envía SMS de cancelación
- Obtiene teléfono del usuario o participantes

#### 4. Base de Datos
- Tabla `sms_notifications` creada
- Script SQL: `database/10_create_sms_notifications_table.sql`
- Índices optimizados para búsquedas

### ⚙️ Configuración

**appsettings.json:**
```json
{
  "Twilio": {
    "Enabled": false,
    "UseSimulator": true,
    "AccountSid": "YOUR_TWILIO_ACCOUNT_SID",
    "AuthToken": "YOUR_TWILIO_AUTH_TOKEN",
    "FromNumber": "+1234567890"
  }
}
```

**Para usar Twilio real:**
1. Crea una cuenta en Twilio
2. Obtén `AccountSid`, `AuthToken` y `FromNumber`
3. Configura en `appsettings.json`:
   ```json
   "Twilio": {
     "Enabled": true,
     "UseSimulator": false,
     "AccountSid": "ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
     "AuthToken": "your_auth_token",
     "FromNumber": "+1234567890"
   }
   ```
4. (Opcional) Instala el paquete NuGet:
   ```bash
   dotnet add package Twilio
   ```
   Luego descomenta el código en `SmsNotificationService.SendSmsWithTwilioAsync`

**Modo Simulador (Desarrollo):**
- Cuando `UseSimulator: true`, los SMS se registran pero no se envían realmente
- Útil para desarrollo y pruebas sin costos
- Los SMS aparecen en los logs como `📱 [SIMULADOR] SMS enviado...`

### 📱 Plantillas de SMS

El servicio incluye plantillas predefinidas:

1. **booking-confirmation**: "✅ Reserva confirmada! Tour: {TourName}, Fecha: {TourDate}. ID: {BookingId}..."

2. **booking-reminder**: "⏰ Recordatorio: Tu tour '{TourName}' es el {TourDate}..."

3. **payment-confirmation**: "💳 Pago confirmado: {Amount}. Tu reserva está confirmada..."

4. **booking-cancellation**: "❌ Reserva cancelada: {TourName}..."

### 🔄 Uso del Servicio

```csharp
// Enviar SMS inmediatamente
await _smsNotificationService.SendSmsAsync(
    phoneNumber: "+50760000000",
    message: "Tu reserva está confirmada",
    type: SmsNotificationType.BookingConfirmation,
    userId: userId,
    bookingId: bookingId
);

// Enviar SMS con plantilla
await _smsNotificationService.SendTemplatedSmsAsync(
    phoneNumber: "+50760000000",
    templateName: "booking-confirmation",
    templateData: new { TourName = "Canal de Panamá", TourDate = "01/02/2025" },
    type: SmsNotificationType.BookingConfirmation,
    userId: userId,
    bookingId: bookingId
);

// Agendar SMS para el futuro
await _smsNotificationService.QueueSmsAsync(
    phoneNumber: "+50760000000",
    message: "Recordatorio de tu tour",
    type: SmsNotificationType.BookingReminder,
    scheduledFor: DateTime.UtcNow.AddDays(1),
    userId: userId,
    bookingId: bookingId
);
```

---

## 📝 Sistema de Blog Público

### 📋 Componentes Implementados

#### 1. Controlador Público
- **`BlogController`**: Endpoints públicos para blog
  - No requiere autenticación
  - Solo muestra posts publicados

#### 2. Endpoints Disponibles

**GET `/api/blog`**
- Lista todos los posts de blog publicados
- Paginación soportada
- Búsqueda opcional
- Query parameters:
  - `page`: Número de página (default: 1)
  - `pageSize`: Tamaño de página (default: 10, max: 50)
  - `search`: Término de búsqueda opcional

**GET `/api/blog/{slug}`**
- Obtiene un post específico por slug
- Retorna contenido completo
- Incluye metadatos SEO

**GET `/api/blog/recent`**
- Obtiene los posts más recientes
- Útil para sidebar o homepage
- Query parameter:
  - `limit`: Número de posts (default: 5, max: 20)

#### 3. Filtrado de Posts
- Solo muestra posts con:
  - `IsPublished = true`
  - `PublishedAt <= DateTime.UtcNow`
  - `Template = "Blog"` o `"blog"` o `null`

### 📊 Estructura de Respuesta

**GET /api/blog:**
```json
{
  "posts": [
    {
      "id": "guid",
      "title": "Título del Post",
      "slug": "titulo-del-post",
      "excerpt": "Resumen del post...",
      "publishedAt": "2025-01-15T10:00:00Z",
      "createdAt": "2025-01-10T08:00:00Z",
      "metaTitle": "SEO Title",
      "metaDescription": "SEO Description"
    }
  ],
  "totalCount": 25,
  "page": 1,
  "pageSize": 10,
  "totalPages": 3,
  "hasNextPage": true,
  "hasPreviousPage": false
}
```

**GET /api/blog/{slug}:**
```json
{
  "id": "guid",
  "title": "Título del Post",
  "slug": "titulo-del-post",
  "content": "<p>Contenido HTML completo...</p>",
  "excerpt": "Resumen del post...",
  "publishedAt": "2025-01-15T10:00:00Z",
  "createdAt": "2025-01-10T08:00:00Z",
  "updatedAt": "2025-01-12T14:00:00Z",
  "metaTitle": "SEO Title",
  "metaDescription": "SEO Description",
  "metaKeywords": "keyword1, keyword2"
}
```

### 🎨 Crear Posts de Blog

Para crear un post de blog, usa el endpoint de admin:

**POST `/api/admin/pages`** (requiere autenticación Admin)
```json
{
  "title": "10 Consejos para Viajar a Panamá",
  "slug": "10-consejos-viajar-panama",
  "content": "<p>Contenido HTML del post...</p>",
  "excerpt": "Descubre los mejores consejos para tu viaje a Panamá",
  "template": "Blog",
  "isPublished": true,
  "publishedAt": "2025-01-15T10:00:00Z",
  "metaTitle": "10 Consejos para Viajar a Panamá | PanamaTravelHub",
  "metaDescription": "Guía completa con los mejores consejos para viajar a Panamá"
}
```

### 🔍 Búsqueda y Filtrado

**Búsqueda por texto:**
```
GET /api/blog?search=panama
```
Busca en: título, excerpt y contenido

**Paginación:**
```
GET /api/blog?page=2&pageSize=20
```

**Combinado:**
```
GET /api/blog?page=1&pageSize=10&search=viajes
```

---

## 🚀 Pasos para Activar

### SMS Notifications

1. **Ejecutar script SQL:**
   ```sql
   -- En Render PostgreSQL
   -- Ejecutar: database/10_create_sms_notifications_table.sql
   ```

2. **Configurar Twilio (opcional):**
   - Editar `appsettings.json` con credenciales de Twilio
   - O mantener `UseSimulator: true` para desarrollo

3. **Listo:** Los SMS se enviarán automáticamente al crear/cancelar reservas

### Blog Público

1. **Crear posts de blog:**
   - Usar panel de admin (`/admin.html`)
   - O endpoint `POST /api/admin/pages`
   - Asegurarse de que `Template = "Blog"` y `IsPublished = true`

2. **Acceder al blog:**
   - Lista: `GET /api/blog`
   - Post individual: `GET /api/blog/{slug}`
   - Posts recientes: `GET /api/blog/recent`

3. **Frontend (pendiente):**
   - Crear página HTML para mostrar el blog
   - Integrar con los endpoints creados

---

## 📊 Estado Final

| Funcionalidad | Estado | Notas |
|---------------|--------|-------|
| SMS Notifications | ✅ Completo | Modo simulador funcional, Twilio listo para configurar |
| Integración SMS en Reservas | ✅ Completo | Confirmación y cancelación |
| Blog Público - Endpoints | ✅ Completo | GET /api/blog, /api/blog/{slug}, /api/blog/recent |
| Blog Público - Frontend | ⚠️ Pendiente | Crear página HTML para mostrar blog |
| Paginación y Búsqueda | ✅ Completo | Implementado en endpoints |
| Base de Datos SMS | ✅ Completo | Tabla creada con script SQL |

---

## 📝 Notas Técnicas

### SMS
- Normalización de teléfonos a formato E.164
- Validación de números telefónicos
- Reintentos automáticos configurables
- Procesamiento asíncrono de cola
- Logging completo de operaciones

### Blog
- Filtrado automático por fecha de publicación
- Ordenamiento por fecha (más reciente primero)
- Búsqueda en múltiples campos
- Paginación eficiente
- Metadatos SEO incluidos

---

**Última actualización:** 2025-01-XX
**Versión:** 1.0.0

