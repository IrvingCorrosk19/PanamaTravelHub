# Cómo ver logs del contenedor PanamaTravelHub en el VPS

## Por qué aparece "Algo salió mal en el servidor..."

Ese mensaje se muestra cuando la **API devuelve HTTP 500** (error interno). En el frontend (`api.js`) cualquier respuesta 500 se traduce a ese texto genérico para no exponer detalles al usuario.

**Causas habituales en login (POST /api/auth/login):**
- Excepción no controlada en el backend (NullReference, DbUpdateException, etc.)
- Usuario con roles mal configurados (p. ej. `UserRole` sin `Role` asociado)
- Fallo de conexión a PostgreSQL desde el contenedor
- Configuración JWT faltante o incorrecta en producción

## Ver los logs desde tu PC (PowerShell)

Ejecuta el script que obtiene las últimas líneas del contenedor:

```powershell
cd c:\Proyectos\PanamaTravelHub\PanamaTravelHub\Com
.\verificar-logs-panamatravelhub.ps1
```

Para más líneas:

```powershell
.\verificar-logs-panamatravelhub.ps1 -Tail 300
```

En la salida busca líneas que contengan:
- `[ERR]` o `Error` o `Exception`
- `login` o `auth`
- `NullReferenceException`, `DbUpdateException`, `NpgsqlException`

El **correlationId** que devuelve la API en el error (si el frontend lo muestra en consola o en la respuesta) coincide con el que puede aparecer en los logs para seguir la traza.

## Ver logs directamente en el VPS (SSH)

Si tienes SSH al servidor:

```bash
# Últimas 200 líneas
docker logs --tail 200 panamatravelhub_web

# En tiempo real (para reproducir el error)
docker logs -f panamatravelhub_web
```

Luego intenta iniciar sesión en https://travel.autonomousflow.lat/login.html y revisa qué excepción se imprime.

## Cambios aplicados en el código para evitar 500 en login

1. **Roles nulos:** Si un usuario tiene `UserRole` sin `Role` (rol eliminado o datos inconsistentes), antes se producía `NullReferenceException`. Ahora se filtran roles nulos y, si el usuario no tiene ningún rol, se asume "Customer" y se registra un warning en log.

2. **Logging del error:** En el `catch` del login se registra tipo de excepción, mensaje e `InnerException`, para que en los logs del contenedor veas la causa real del 500.

Tras desplegar de nuevo, si vuelve a fallar el login, ejecuta `.\verificar-logs-panamatravelhub.ps1` y revisa la excepción que aparezca; con eso se puede afinar el siguiente fix.
