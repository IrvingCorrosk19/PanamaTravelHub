# Configuración de Pasarelas de Pago

Este documento describe cómo configurar las pasarelas de pago (Stripe, PayPal y Yappy) en modo de pruebas para PanamaTravelHub.

## Configuración General

Todas las pasarelas están configuradas para funcionar en **modo de pruebas** por defecto. Esto permite probar el flujo de pago completo sin realizar transacciones reales.

## 1. Stripe

### Configuración en appsettings.json

```json
{
  "Stripe": {
    "SecretKey": "sk_test_YOUR_STRIPE_SECRET_KEY",
    "PublishableKey": "pk_test_YOUR_STRIPE_PUBLISHABLE_KEY",
    "WebhookSecret": "whsec_YOUR_STRIPE_WEBHOOK_SECRET"
  }
}
```

### Obtener Credenciales de Prueba

1. Regístrate en [Stripe](https://stripe.com)
2. Accede al [Dashboard de Stripe](https://dashboard.stripe.com/test/apikeys)
3. Copia las claves de prueba:
   - **Secret Key**: `sk_test_...`
   - **Publishable Key**: `pk_test_...`
4. Para webhooks, configura un endpoint en [Stripe Webhooks](https://dashboard.stripe.com/test/webhooks)

### Tarjetas de Prueba

- **Pago exitoso**: `4242 4242 4242 4242`
- **Pago rechazado**: `4000 0000 0000 0002`
- **Requiere autenticación**: `4000 0025 0000 3155`
- **Fecha de vencimiento**: Cualquier fecha futura (ej: 12/25)
- **CVV**: Cualquier código de 3 dígitos (ej: 123)

## 2. PayPal

### Configuración en appsettings.json

```json
{
  "PayPal": {
    "ClientId": "YOUR_PAYPAL_CLIENT_ID",
    "ClientSecret": "YOUR_PAYPAL_CLIENT_SECRET",
    "TestMode": "true"
  }
}
```

### Obtener Credenciales de Prueba

1. Regístrate en [PayPal Developer](https://developer.paypal.com)
2. Crea una aplicación en el [Dashboard de PayPal](https://developer.paypal.com/dashboard/applications/sandbox)
3. Selecciona el entorno **Sandbox**
4. Copia las credenciales:
   - **Client ID**
   - **Client Secret**

### Modo de Pruebas

- **TestMode**: `"true"` - Usa PayPal Sandbox
- **TestMode**: `"false"` - Usa PayPal Live (producción)

### Nota

En modo de pruebas, el sistema simula el flujo de PayPal. Para integración completa en producción, se requiere implementar el SDK oficial de PayPal.

## 3. Yappy

### Configuración en appsettings.json

```json
{
  "Yappy": {
    "MerchantId": "YOUR_YAPPY_MERCHANT_ID",
    "TestMode": "true"
  }
}
```

### Obtener Credenciales

1. Contacta con [Yappy](https://yappy.pe) para obtener credenciales de prueba
2. Obtén tu **Merchant ID** del panel de Yappy

### Modo de Pruebas

- **TestMode**: `"true"` - Genera códigos QR simulados
- **TestMode**: `"false"` - Usa Yappy en producción

### Nota

Yappy es un método de pago panameño basado en códigos QR. En modo de pruebas, el sistema genera códigos QR simulados. Para integración completa, se requiere la API oficial de Yappy.

## Configuración de BaseUrl

Asegúrate de configurar la URL base de tu aplicación:

```json
{
  "BaseUrl": "https://localhost:5001"
}
```

En producción, cambia esto a la URL de tu dominio:

```json
{
  "BaseUrl": "https://panamatravelhub.com"
}
```

## Flujo de Pago

### Stripe

1. El usuario ingresa los datos de su tarjeta
2. Se crea un PaymentIntent en Stripe
3. Se confirma el pago con Stripe
4. Se actualiza el estado de la reserva a "Confirmed"

### PayPal

1. El usuario selecciona PayPal
2. Se crea un checkout de PayPal
3. El usuario es redirigido a PayPal (o se simula en modo de pruebas)
4. Después de la confirmación, se actualiza el estado de la reserva

### Yappy

1. El usuario ingresa su número de teléfono
2. Se genera un código QR
3. El usuario escanea el código con la app Yappy
4. Se confirma el pago automáticamente

## Webhooks

Para recibir notificaciones de pago en tiempo real, configura los webhooks:

- **Stripe**: Configura el endpoint en el Dashboard de Stripe
- **PayPal**: Configura el endpoint en el Dashboard de PayPal
- **Yappy**: Configura el endpoint en el panel de Yappy

## Seguridad

⚠️ **IMPORTANTE**: Nunca commitees las credenciales reales al repositorio. Usa variables de entorno o un servicio de gestión de secretos en producción.

### Variables de Entorno (Recomendado)

```bash
# Stripe
Stripe__SecretKey=sk_test_...
Stripe__PublishableKey=pk_test_...
Stripe__WebhookSecret=whsec_...

# PayPal
PayPal__ClientId=...
PayPal__ClientSecret=...
PayPal__TestMode=true

# Yappy
Yappy__MerchantId=...
Yappy__TestMode=true
```

## Pruebas

Para probar cada pasarela:

1. **Stripe**: Usa las tarjetas de prueba mencionadas arriba
2. **PayPal**: En modo de pruebas, el sistema simula el flujo automáticamente
3. **Yappy**: En modo de pruebas, el sistema simula el escaneo del QR automáticamente

## Solución de Problemas

### Stripe

- Verifica que las claves sean de prueba (contienen `test` en el nombre)
- Asegúrate de que el webhook esté configurado correctamente
- Revisa los logs para ver errores de Stripe

### PayPal

- Verifica que `TestMode` esté en `"true"` para pruebas
- Asegúrate de que las credenciales sean del entorno Sandbox
- Revisa los logs para ver errores de PayPal

### Yappy

- Verifica que `TestMode` esté en `"true"` para pruebas
- Asegúrate de que el número de teléfono tenga el formato correcto (+507)
- Revisa los logs para ver errores de Yappy

## Migración a Producción

Antes de pasar a producción:

1. Cambia todas las credenciales de prueba por las de producción
2. Configura `TestMode` a `"false"` para PayPal y Yappy
3. Usa las claves de producción de Stripe (sin `test`)
4. Configura los webhooks en producción
5. Prueba cada pasarela en un entorno de staging primero
6. Monitorea los logs y las transacciones

