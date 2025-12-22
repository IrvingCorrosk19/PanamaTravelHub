# Guía de Deployment en Render

Esta guía te ayudará a desplegar ToursPanama en Render.

## Prerrequisitos

1. Cuenta en [Render](https://render.com)
2. Repositorio Git (GitHub, GitLab, o Bitbucket)

## Opción 1: Deployment Automático con render.yaml

### Paso 1: Subir código a Git

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin <tu-repositorio-git>
git push -u origin main
```

### Paso 2: Crear servicio en Render

1. Ve a [Render Dashboard](https://dashboard.render.com)
2. Click en "New +" → "Blueprint"
3. Conecta tu repositorio
4. Render detectará automáticamente el archivo `render.yaml`
5. Click en "Apply"

### Paso 3: Configurar Variables de Entorno

Render creará automáticamente:
- Base de datos PostgreSQL
- Servicio web con las variables configuradas

## Opción 2: Deployment Manual

### Paso 1: Crear Base de Datos PostgreSQL

1. En Render Dashboard, click "New +" → "PostgreSQL"
2. Configura:
   - **Name**: `panamatravelhub-db`
   - **Database**: `PanamaTravelHub`
   - **User**: `panamatravelhub`
   - **Plan**: Starter (gratis)
3. Guarda la **Internal Database URL**

### Paso 2: Crear Servicio Web

1. Click "New +" → "Web Service"
2. Conecta tu repositorio
3. Configura:
   - **Name**: `panamatravelhub-api`
   - **Environment**: `Docker`
   - **Region**: Elige la más cercana
   - **Branch**: `main`
   - **Root Directory**: (dejar vacío)
   - **Build Command**: 
     ```bash
     dotnet restore && dotnet publish -c Release -o ./publish
     ```
   - **Start Command**:
     ```bash
     cd ./publish && dotnet PanamaTravelHub.API.dll
     ```

### Paso 3: Configurar Variables de Entorno

En el servicio web, ve a "Environment" y agrega:

```
ASPNETCORE_ENVIRONMENT=Production
ASPNETCORE_URLS=http://0.0.0.0:10000
ConnectionStrings__DefaultConnection=<tu-connection-string-de-postgres>
```

**Nota**: Reemplaza `<tu-connection-string-de-postgres>` con la Internal Database URL de tu base de datos.

### Paso 4: Configurar Health Check (Opcional)

1. Ve a "Settings" → "Health Check Path"
2. Agrega: `/health`

## Opción 3: Usando Dockerfile

Si prefieres usar Docker:

### Crear Dockerfile

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["src/PanamaTravelHub.API/PanamaTravelHub.API.csproj", "src/PanamaTravelHub.API/"]
COPY ["src/PanamaTravelHub.Infrastructure/PanamaTravelHub.Infrastructure.csproj", "src/PanamaTravelHub.Infrastructure/"]
COPY ["src/PanamaTravelHub.Application/PanamaTravelHub.Application.csproj", "src/PanamaTravelHub.Application/"]
COPY ["src/PanamaTravelHub.Domain/PanamaTravelHub.Domain.csproj", "src/PanamaTravelHub.Domain/"]
RUN dotnet restore "src/PanamaTravelHub.API/PanamaTravelHub.API.csproj"
COPY . .
WORKDIR "/src/src/PanamaTravelHub.API"
RUN dotnet build "PanamaTravelHub.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "PanamaTravelHub.API.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "PanamaTravelHub.API.dll"]
```

Luego en Render:
- **Environment**: `Docker`
- Render detectará automáticamente el Dockerfile

## Aplicar Migraciones

Después del primer deployment, las migraciones se aplicarán automáticamente gracias al código en `Program.cs`.

Si necesitas aplicarlas manualmente:

1. Conecta a tu base de datos usando psql o un cliente
2. Ejecuta los scripts SQL de la carpeta `database/`

## Verificar Deployment

1. Una vez desplegado, Render te dará una URL como: `https://panamatravelhub-api.onrender.com`
2. Verifica:
   - `https://tu-url.onrender.com/` - Debe mostrar el frontend
   - `https://tu-url.onrender.com/swagger` - Debe mostrar Swagger UI
   - `https://tu-url.onrender.com/api/tours` - Debe retornar JSON

## Troubleshooting

### Error: "Could not connect to database"
- Verifica que la variable `ConnectionStrings__DefaultConnection` esté correctamente configurada
- Asegúrate de usar la **Internal Database URL** (no la externa)

### Error: "Migration failed"
- Verifica los logs en Render Dashboard
- Asegúrate de que la base de datos tenga los permisos necesarios

### Error: "Port already in use"
- Render usa el puerto definido en `PORT` o `ASPNETCORE_URLS`
- Asegúrate de que `ASPNETCORE_URLS=http://0.0.0.0:10000` esté configurado

## Costos

- **Starter Plan (PostgreSQL)**: Gratis (con limitaciones)
- **Starter Plan (Web Service)**: Gratis (se duerme después de 15 min de inactividad)
- **Pro Plan**: Desde $7/mes (sin sleep, mejor rendimiento)

## Notas Importantes

1. **Sleep Mode**: El plan gratuito se duerme después de 15 minutos de inactividad. La primera petición puede tardar ~30 segundos en "despertar"
2. **Base de Datos**: El plan gratuito tiene límites de tamaño y conexiones
3. **HTTPS**: Render proporciona HTTPS automáticamente
4. **Custom Domain**: Puedes agregar tu dominio personalizado en Settings

## Siguiente Paso

Una vez desplegado, actualiza el frontend para usar la URL de producción en lugar de `localhost`.

