# Configuración de Stripe en Modo de Pruebas

Esta guía te ayudará a configurar Stripe en modo de pruebas (Test Mode) para poder realizar reservas y probar los pagos sin usar dinero real.

## 📋 Requisitos Previos

1. Crear una cuenta en Stripe (si no tienes una)
2. Acceder al Dashboard de Stripe
3. Activar el modo de pruebas

## 🔑 Paso 1: Obtener las Claves de Prueba de Stripe

### 1.1 Acceder al Dashboard de Stripe

1. Ve a [https://dashboard.stripe.com](https://dashboard.stripe.com)
2. Inicia sesión con tu cuenta de Stripe
3. **Asegúrate de estar en "Modo de Pruebas"** (Test Mode)
   - Verifica que el toggle en la parte superior derecha diga "Test mode" o "Modo de prueba"

### 1.2 Obtener la Clave Pública (Publishable Key)

1. En el Dashboard, ve a **Developers** → **API keys**
2. En la sección **Publishable key**, copia la clave que empieza con `pk_test_`
3. Esta es tu **Publishable Key** (clave pública)

### 1.3 Obtener la Clave Secreta (Secret Key)

1. En la misma página, en la sección **Secret key**
2. Haz clic en **Reveal test key** para mostrar la clave
3. Copia la clave que empieza con `sk_test_`
4. Esta es tu **Secret Key** (clave secreta)

### 1.4 Obtener el Webhook Secret (Opcional para pruebas locales)

Para desarrollo local, puedes usar Stripe CLI. Para producción en Render:

1. Ve a **Developers** → **Webhooks**
2. Crea un nuevo endpoint webhook o usa uno existente
3. Copia el **Signing secret** que empieza con `whsec_`

## ⚙️ Paso 2: Configurar las Claves en la Aplicación

### 2.1 Para Desarrollo Local

Edita el archivo `src/PanamaTravelHub.API/appsettings.json`:

```json
{
  "Stripe": {
    "SecretKey": "sk_test_TU_CLAVE_SECRETA_AQUI",
    "PublishableKey": "pk_test_TU_CLAVE_PUBLICA_AQUI",
    "WebhookSecret": "whsec_TU_WEBHOOK_SECRET_AQUI"
  }
}
```

### 2.2 Para Producción en Render

1. Ve a tu servicio en Render Dashboard
2. Ve a **Environment** → **Environment Variables**
3. Agrega las siguientes variables:

```
Stripe__SecretKey = sk_test_TU_CLAVE_SECRETA_AQUI
Stripe__PublishableKey = pk_test_TU_CLAVE_PUBLICA_AQUI
Stripe__WebhookSecret = whsec_TU_WEBHOOK_SECRET_AQUI
```

**Nota:** En Render, usa doble guion bajo `__` para separar las secciones de configuración.

## 🧪 Paso 3: Tarjetas de Prueba de Stripe

Stripe proporciona tarjetas de prueba para simular diferentes escenarios:

### Tarjetas que Funcionan (Pago Exitoso)

| Número de Tarjeta | CVV | Fecha | Resultado |
|-------------------|-----|-------|-----------|
| 4242 4242 4242 4242 | Cualquier 3 dígitos | Cualquier fecha futura | ✅ Pago exitoso |
| 4000 0025 0000 3155 | Cualquier 3 dígitos | Cualquier fecha futura | ✅ Requiere autenticación 3D Secure |

### Tarjetas que Fallan (Para Probar Errores)

| Número de Tarjeta | CVV | Resultado |
|-------------------|-----|-----------|
| 4000 0000 0000 0002 | Cualquier 3 dígitos | ❌ Tarjeta rechazada (genérico) |
| 4000 0000 0000 9995 | Cualquier 3 dígitos | ❌ Fondos insuficientes |
| 4000 0000 0000 0069 | Cualquier 3 dígitos | ❌ Tarjeta expirada |

### Otros Números Útiles

- **Cualquier fecha futura** funciona (ej: 12/25, 01/26)
- **Cualquier CVV de 3 dígitos** funciona (ej: 123, 456)
- **Cualquier código postal** funciona para pruebas

## 🔍 Paso 4: Verificar la Configuración

### 4.1 Verificar que las Claves Estén Configuradas

1. Inicia la aplicación
2. Ve a `/admin.html` y verifica que no haya errores en la consola
3. Intenta crear una reserva y llegar al checkout

### 4.2 Probar un Pago de Prueba

1. Selecciona un tour
2. Completa el checkout
3. Usa la tarjeta de prueba: `4242 4242 4242 4242`
4. Usa cualquier fecha futura (ej: 12/25) y CVV (ej: 123)
5. Completa el pago

### 4.3 Verificar en el Dashboard de Stripe

1. Ve a **Payments** en el Dashboard de Stripe
2. Deberías ver el pago de prueba que acabas de realizar
3. Verifica que el estado sea "Succeeded" o "Completado"

## 🚨 Solución de Problemas

### Error: "Stripe no está configurado"

**Causa:** Las claves no están configuradas correctamente.

**Solución:**
1. Verifica que las claves empiecen con `sk_test_` y `pk_test_`
2. Verifica que no haya espacios extra en las claves
3. Reinicia la aplicación después de cambiar la configuración

### Error: "Invalid API Key"

**Causa:** La clave secreta es incorrecta o está usando una clave de producción.

**Solución:**
1. Verifica que estés usando claves de **test mode** (empiezan con `sk_test_` y `pk_test_`)
2. Asegúrate de estar en modo de pruebas en el Dashboard de Stripe
3. Regenera las claves si es necesario

### Error: "Payment failed"

**Causa:** Estás usando una tarjeta de prueba que simula un error.

**Solución:**
- Usa la tarjeta `4242 4242 4242 4242` para pagos exitosos
- Revisa los logs de la aplicación para más detalles

## 📝 Notas Importantes

1. **Modo de Pruebas vs Producción:**
   - Las claves de prueba (`sk_test_`, `pk_test_`) NO procesan pagos reales
   - Las claves de producción (`sk_live_`, `pk_live_`) procesan pagos reales
   - **NUNCA** uses claves de producción en desarrollo

2. **Webhooks en Desarrollo Local:**
   - Para desarrollo local, usa Stripe CLI para recibir webhooks
   - En producción, configura el endpoint webhook en el Dashboard de Stripe

3. **Seguridad:**
   - **NUNCA** subas las claves secretas a Git
   - Usa variables de entorno en producción
   - Las claves públicas son seguras de exponer en el frontend

## 🔗 Enlaces Útiles

- [Dashboard de Stripe](https://dashboard.stripe.com)
- [Documentación de Stripe Testing](https://stripe.com/docs/testing)
- [Tarjetas de Prueba de Stripe](https://stripe.com/docs/testing)
- [Stripe CLI para Webhooks](https://stripe.com/docs/stripe-cli)

## ✅ Checklist de Configuración

- [ ] Cuenta de Stripe creada
- [ ] Modo de pruebas activado en Stripe Dashboard
- [ ] Clave pública (`pk_test_`) obtenida
- [ ] Clave secreta (`sk_test_`) obtenida
- [ ] Claves configuradas en `appsettings.json` o variables de entorno
- [ ] Aplicación reiniciada después de configurar
- [ ] Pago de prueba realizado exitosamente
- [ ] Pago verificado en Stripe Dashboard

---

**¿Necesitas ayuda?** Revisa los logs de la aplicación o consulta la documentación de Stripe.

