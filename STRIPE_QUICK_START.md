# 🚀 Quick Start: Configurar Stripe en 5 Minutos

## Paso 1: Obtener Claves de Prueba (2 minutos)

1. Ve a [https://dashboard.stripe.com/test/apikeys](https://dashboard.stripe.com/test/apikeys)
2. Asegúrate de estar en **"Test mode"** (toggle en la parte superior)
3. Copia estas dos claves:
   - **Publishable key**: `pk_test_...` (clave pública)
   - **Secret key**: `sk_test_...` (haz clic en "Reveal test key")

## Paso 2: Configurar en Render (2 minutos)

1. Ve a tu servicio en [Render Dashboard](https://dashboard.render.com)
2. Click en **Environment** → **Environment Variables**
3. Agrega estas 3 variables:

```
Stripe__SecretKey = sk_test_TU_CLAVE_AQUI
Stripe__PublishableKey = pk_test_TU_CLAVE_AQUI
Stripe__WebhookSecret = whsec_TU_WEBHOOK_AQUI
```

4. Click en **Save Changes**
5. Render reiniciará automáticamente el servicio

## Paso 3: Probar (1 minuto)

1. Ve a tu aplicación en Render
2. Crea una reserva
3. En el checkout, usa esta tarjeta de prueba:
   - **Número**: `4242 4242 4242 4242`
   - **Fecha**: `12/25` (cualquier fecha futura)
   - **CVV**: `123` (cualquier 3 dígitos)
   - **Nombre**: Cualquier nombre

4. Completa el pago ✅

## ✅ Listo!

Ahora puedes hacer reservas de prueba sin usar dinero real.

**Ver tus pagos de prueba:**
- Ve a [Stripe Dashboard → Payments](https://dashboard.stripe.com/test/payments)

---

**¿Problemas?** Revisa `CONFIGURACION_STRIPE_PRUEBAS.md` para más detalles.


