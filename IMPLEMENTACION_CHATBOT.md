# 🤖 IMPLEMENTACIÓN DE CHATBOT CON IA

**Fecha:** 2026-01-24  
**Estado:** ✅ Implementado

---

## 📋 RESUMEN

Se ha implementado un chatbot inteligente con IA que atiende a los usuarios en `https://localhost:7009/`. El chatbot puede responder preguntas sobre tours, precios, reservas, métodos de pago y más.

---

## 🎯 CARACTERÍSTICAS

### ✅ Frontend
- Widget de chat flotante con diseño premium
- Interfaz responsive (mobile-first)
- Animaciones suaves
- Indicador de escritura (typing)
- Acciones rápidas (quick actions)
- Historial de conversación

### ✅ Backend
- Controlador REST API (`/api/chatbot/message`)
- Detección de intenciones inteligente
- Respuestas contextuales basadas en la base de datos
- Integración con tours, precios y disponibilidad
- Manejo de errores robusto

### ✅ Funcionalidades
- **Búsqueda de tours:** Muestra tours disponibles con precios y descripciones
- **Información de precios:** Precios mínimos, máximos y promedio
- **Proceso de reserva:** Guía paso a paso
- **Información de contacto:** Email y horarios
- **Política de cancelación:** Detalles sobre cancelaciones y reembolsos
- **Métodos de pago:** Stripe, PayPal, Yappy
- **Saludos y ayuda general**

---

## 📁 ARCHIVOS CREADOS

### Frontend
1. **`wwwroot/css/chatbot.css`** - Estilos del widget de chat
2. **`wwwroot/js/chatbot.js`** - Lógica del cliente del chatbot
3. **`wwwroot/index.html`** - Actualizado para incluir el chatbot

### Backend
1. **`Controllers/ChatbotController.cs`** - Controlador API para procesar mensajes

---

## 🚀 INSTALACIÓN Y USO

### 1. El chatbot ya está integrado

El chatbot se carga automáticamente en `index.html`. Para agregarlo a otras páginas, incluye estos scripts antes de `</body>`:

```html
<script src="/js/chatbot.js"></script>
```

### 2. El CSS se carga automáticamente

El archivo CSS se carga dinámicamente desde `chatbot.js`, pero puedes incluirlo manualmente si prefieres:

```html
<link rel="stylesheet" href="/css/chatbot.css" />
```

### 3. Verificar que el backend esté funcionando

El endpoint `/api/chatbot/message` debe estar disponible. Verifica en:
- `https://localhost:7009/api/chatbot/message`

---

## 🔧 CONFIGURACIÓN

### Variables de Entorno (Opcional)

Si quieres usar OpenAI API para respuestas más avanzadas, agrega a `appsettings.json`:

```json
{
  "OpenAI": {
    "ApiKey": "tu-api-key-aqui",
    "Model": "gpt-3.5-turbo",
    "Enabled": false
  }
}
```

**Nota:** Actualmente el chatbot usa respuestas inteligentes basadas en reglas y contexto de la base de datos. Esto funciona perfectamente sin necesidad de OpenAI.

---

## 📝 USO DEL CHATBOT

### Para Usuarios

1. **Abrir el chatbot:** Haz clic en el botón flotante en la esquina inferior derecha
2. **Escribir mensaje:** Escribe tu pregunta en el campo de texto
3. **Enviar:** Presiona Enter o haz clic en el botón de enviar
4. **Acciones rápidas:** Usa los botones de acciones rápidas para preguntas comunes

### Ejemplos de Preguntas

- "¿Qué tours tienen disponibles?"
- "¿Cuánto cuesta un tour?"
- "¿Cómo puedo reservar?"
- "¿Qué métodos de pago aceptan?"
- "¿Cuál es la política de cancelación?"
- "¿Cómo puedo contactarlos?"

---

## 🎨 PERSONALIZACIÓN

### Cambiar Colores

Edita `chatbot.css`:

```css
.chatbot-button {
  background: linear-gradient(135deg, #TU_COLOR_1 0%, #TU_COLOR_2 100%);
}
```

### Cambiar Mensajes

Edita `ChatbotController.cs` y modifica los métodos de respuesta:
- `GetGreetingResponse()`
- `GetToursResponse()`
- `GetPricingResponse()`
- etc.

### Agregar Nuevas Intenciones

1. Agrega un nuevo caso en el enum `Intent`:
```csharp
public enum Intent
{
    // ... existentes
    NewIntent
}
```

2. Agrega detección en `DetectIntent()`:
```csharp
if (Regex.IsMatch(message, @"\b(palabra_clave)\b", RegexOptions.IgnoreCase))
    return Intent.NewIntent;
```

3. Agrega caso en `GenerateResponse()`:
```csharp
case Intent.NewIntent:
    return GetNewIntentResponse();
```

4. Crea el método de respuesta:
```csharp
private string GetNewIntentResponse()
{
    return "Tu respuesta aquí";
}
```

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### El chatbot no aparece

1. Verifica que `chatbot.js` esté cargado (consola del navegador)
2. Verifica que no haya errores de JavaScript
3. Verifica que el CSS se haya cargado correctamente

### El chatbot no responde

1. Verifica que el backend esté corriendo
2. Verifica la consola del navegador para errores
3. Verifica que el endpoint `/api/chatbot/message` esté accesible
4. Revisa los logs del servidor

### Errores de base de datos

Si ves errores relacionados con columnas faltantes (como `available_languages`), ejecuta:

```sql
-- Ejecutar el script de corrección
\i database/fix_missing_tour_columns.sql
```

O ejecuta manualmente:
```powershell
# Si tienes psql en el PATH
psql -U postgres -d panamatravelhub -f database\fix_missing_tour_columns.sql
```

---

## 🔄 PRÓXIMAS MEJORAS (Opcional)

### Integración con OpenAI

Para respuestas más avanzadas con IA, puedes extender `ChatbotController.cs`:

```csharp
private async Task<string> GenerateResponseWithOpenAI(string message, string sessionId)
{
    // Si OpenAI está habilitado
    if (_configuration["OpenAI:Enabled"] == "true")
    {
        // Llamar a OpenAI API
        // ...
    }
    
    // Fallback a respuestas inteligentes
    return await GenerateResponse(message, sessionId);
}
```

### Persistencia de Conversaciones

Puedes crear una tabla `chatbot_conversations` para guardar historial:

```sql
CREATE TABLE chatbot_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    response TEXT NOT NULL,
    intent VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Analytics

Agregar tracking de:
- Preguntas más frecuentes
- Intenciones más comunes
- Tasa de satisfacción
- Tiempo de respuesta

---

## ✅ VERIFICACIÓN

### Checklist

- [x] Frontend del chatbot implementado
- [x] Backend API implementado
- [x] Integración con base de datos
- [x] Detección de intenciones
- [x] Respuestas contextuales
- [x] Manejo de errores
- [x] Diseño responsive
- [x] Documentación completa

---

## 📞 SOPORTE

Si tienes problemas o preguntas sobre el chatbot:
1. Revisa los logs del servidor
2. Verifica la consola del navegador
3. Revisa este documento
4. Contacta al equipo de desarrollo

---

**Última actualización:** 2026-01-24  
**Versión:** 1.0.0
