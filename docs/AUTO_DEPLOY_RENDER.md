# Configuración de Auto-Deploy en Render

Esta guía explica cómo configurar el despliegue automático en Render cuando haces push a Git.

## ¿Qué es Auto-Deploy?

Auto-deploy es una funcionalidad de Render que automáticamente despliega tu aplicación cada vez que haces push a la rama principal (main) de tu repositorio Git.

## Configuración Automática con render.yaml

El archivo `render.yaml` ya está configurado con auto-deploy habilitado:

```yaml
services:
  - type: web
    name: panamatravelhub-api
    autoDeploy: true  # ✅ Auto-deploy habilitado
    branch: main      # ✅ Rama que activa el deploy
```

## Configuración Manual en Render Dashboard

Si prefieres configurarlo manualmente o verificar la configuración:

### Paso 1: Acceder a Render Dashboard

1. Ve a [Render Dashboard](https://dashboard.render.com)
2. Inicia sesión con tu cuenta
3. Selecciona tu servicio `panamatravelhub-api`

### Paso 2: Configurar Auto-Deploy

1. En el panel izquierdo, haz clic en **"Settings"**
2. Desplázate hasta la sección **"Build & Deploy"**
3. Verifica o configura:
   - **Auto-Deploy**: Debe estar en **"Yes"** ✅
   - **Branch**: Debe ser **"main"** (o la rama que uses)
   - **Pull Request Previews**: Opcional (puedes habilitarlo para probar PRs)

### Paso 3: Verificar Webhook de Git

Render crea automáticamente un webhook en tu repositorio Git que escucha los eventos de push.

Para verificar:
1. En Render Dashboard, ve a **"Settings"** → **"Build & Deploy"**
2. Verás la sección **"Webhook URL"** - esta es la URL que Render usa para recibir notificaciones de Git
3. Si necesitas regenerar el webhook, haz clic en **"Regenerate"**

## Cómo Funciona

1. **Haces push a Git:**
   ```bash
   git push origin main
   ```

2. **GitHub/GitLab/Bitbucket notifica a Render:**
   - El webhook de Render recibe la notificación
   - Render detecta que hay cambios en la rama `main`

3. **Render inicia el despliegue automáticamente:**
   - Render clona el código más reciente
   - Ejecuta el `buildCommand` (compila la aplicación)
   - Ejecuta el `startCommand` (inicia la aplicación)
   - La aplicación queda disponible en la URL de Render

4. **Recibes notificación:**
   - Render te envía un email cuando el despliegue comienza
   - Otro email cuando el despliegue termina (éxito o error)

## Verificar el Estado del Deploy

### En Render Dashboard

1. Ve a tu servicio en Render Dashboard
2. Haz clic en la pestaña **"Events"** o **"Logs"**
3. Verás el historial de despliegues con:
   - ✅ Estado (éxito/error)
   - ⏱️ Tiempo de despliegue
   - 📝 Logs del build y deploy

### En los Logs

Los logs muestran:
- **Build logs**: Compilación de la aplicación
- **Deploy logs**: Inicio de la aplicación
- **Runtime logs**: Logs de la aplicación en ejecución

## Desactivar Auto-Deploy (Temporalmente)

Si necesitas desactivar el auto-deploy temporalmente:

### Opción 1: Desde render.yaml

```yaml
autoDeploy: false  # Desactiva auto-deploy
```

### Opción 2: Desde Render Dashboard

1. Ve a **Settings** → **Build & Deploy**
2. Cambia **Auto-Deploy** a **"No"**
3. Guarda los cambios

**Nota**: Con auto-deploy desactivado, deberás hacer deploy manual desde el dashboard.

## Deploy Manual

Si auto-deploy está desactivado, puedes hacer deploy manual:

1. En Render Dashboard, haz clic en **"Manual Deploy"**
2. Selecciona la rama y commit que quieres desplegar
3. Haz clic en **"Deploy"**

## Solución de Problemas

### El deploy no se inicia automáticamente

1. **Verifica el webhook:**
   - Ve a tu repositorio en GitHub/GitLab/Bitbucket
   - Ve a Settings → Webhooks
   - Verifica que el webhook de Render esté activo y recibiendo eventos

2. **Verifica la rama:**
   - Asegúrate de hacer push a la rama configurada (normalmente `main`)
   - Verifica en Render que la rama esté correctamente configurada

3. **Verifica los permisos:**
   - Render necesita acceso de lectura a tu repositorio
   - Ve a Render Dashboard → Settings → Repository
   - Verifica que el repositorio esté conectado correctamente

### El deploy falla

1. **Revisa los logs:**
   - Ve a Render Dashboard → Logs
   - Busca errores en el build o deploy
   - Los errores más comunes:
     - Errores de compilación
     - Variables de entorno faltantes
     - Problemas de conexión a la base de datos

2. **Verifica el buildCommand:**
   - Asegúrate de que el comando de build sea correcto
   - Verifica que todas las dependencias estén en el repositorio

3. **Verifica las variables de entorno:**
   - Ve a Settings → Environment
   - Asegúrate de que todas las variables necesarias estén configuradas

## Notificaciones

Render puede enviarte notificaciones por email cuando:
- Un deploy comienza
- Un deploy termina (éxito o error)
- Hay errores en el build

Para configurar notificaciones:
1. Ve a Render Dashboard → Account Settings
2. Ve a **Notifications**
3. Configura tus preferencias de notificación

## Mejores Prácticas

1. **Usa ramas para desarrollo:**
   - `main` → Producción (auto-deploy activado)
   - `develop` → Desarrollo (auto-deploy opcional)
   - Feature branches → Sin auto-deploy

2. **Revisa los logs después de cada deploy:**
   - Verifica que la aplicación inició correctamente
   - Revisa los logs de runtime para errores

3. **Prueba antes de hacer push a main:**
   - Usa Pull Requests para revisar cambios
   - Prueba localmente antes de hacer push

4. **Mantén el render.yaml actualizado:**
   - Cualquier cambio en `render.yaml` requiere un nuevo deploy
   - Render detecta cambios en `render.yaml` y los aplica automáticamente

## Comandos Útiles

### Ver el estado del último deploy
```bash
# Desde Render Dashboard → Events
```

### Ver logs en tiempo real
```bash
# Desde Render Dashboard → Logs
# Haz clic en "Stream Logs" para ver logs en tiempo real
```

### Forzar un nuevo deploy
```bash
# Desde Render Dashboard → Manual Deploy
# O simplemente haz un push vacío:
git commit --allow-empty -m "Trigger deploy"
git push origin main
```

## Resumen

✅ **Auto-deploy está habilitado** en `render.yaml`
✅ **Cada push a `main`** activa un despliegue automático
✅ **Render notifica** por email el estado del deploy
✅ **Los logs** están disponibles en Render Dashboard

**¡Ahora cada vez que hagas `git push origin main`, Render desplegará automáticamente tu aplicación!** 🚀

