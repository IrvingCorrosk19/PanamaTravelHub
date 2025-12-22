# Dockerfile para ToursPanama
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copiar archivos de proyecto
COPY ["src/PanamaTravelHub.API/PanamaTravelHub.API.csproj", "src/PanamaTravelHub.API/"]
COPY ["src/PanamaTravelHub.Infrastructure/PanamaTravelHub.Infrastructure.csproj", "src/PanamaTravelHub.Infrastructure/"]
COPY ["src/PanamaTravelHub.Application/PanamaTravelHub.Application.csproj", "src/PanamaTravelHub.Application/"]
COPY ["src/PanamaTravelHub.Domain/PanamaTravelHub.Domain.csproj", "src/PanamaTravelHub.Domain/"]

# Restaurar dependencias
RUN dotnet restore "src/PanamaTravelHub.API/PanamaTravelHub.API.csproj"

# Copiar todo el código
COPY . .

# Build
WORKDIR "/src/src/PanamaTravelHub.API"
RUN dotnet build "PanamaTravelHub.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "PanamaTravelHub.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "PanamaTravelHub.API.dll"]

