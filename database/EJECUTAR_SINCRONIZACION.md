# 🚀 Guía Rápida: Ejecutar Sincronización

## ✅ Requisitos

- PostgreSQL 18 instalado en `C:\Program Files\PostgreSQL\18\bin`
- PowerShell (viene con Windows)
- Acceso a base de datos localhost
- Acceso a base de datos Render

## 📋 Proceso Completo (3 Pasos)

### Paso 1: Sincronizar Esquema (Estructura)

Ejecuta este script para sincronizar la estructura de la base de datos:

```powershell
cd database
.\sync_to_render.ps1
```

**Qué hace:**
- ✅ Agrega columnas faltantes
- ✅ Crea tablas nuevas
- ✅ Crea índices
- ✅ Sincroniza datos de seed (roles, admin, países)

**Tiempo estimado:** 1-2 minutos

---

### Paso 2: Exportar Datos desde Localhost

Ejecuta este script para exportar tus datos:

```powershell
.\export_localhost_data.ps1
```

**Qué hace:**
- 📤 Exporta datos de tablas de negocio
- 💾 Guarda en `export_business_data.sql`

**Tiempo estimado:** Depende del tamaño de datos (generalmente < 1 minuto)

---

### Paso 3: Importar Datos a Render

Ejecuta este script para importar los datos exportados:

```powershell
.\import_to_render.ps1
```

**Qué hace:**
- 📥 Importa datos en Render
- ⚠️ Te pedirá confirmación antes de importar

**Tiempo estimado:** Depende del tamaño de datos (generalmente 1-3 minutos)

---

### Paso 4: Verificar Sincronización (Opcional)

Ejecuta este script para comparar ambas bases de datos:

```powershell
.\verify_sync.ps1
```

**Qué hace:**
- 🔍 Compara conteos de registros
- ✅ Muestra si están sincronizadas
- 📊 Muestra tabla comparativa

---

## 🎯 Ejecución Rápida (Todo en Uno)

Si quieres ejecutar todo el proceso de una vez:

```powershell
cd database

# Paso 1: Sincronizar esquema
Write-Host "Paso 1: Sincronizando esquema..." -ForegroundColor Cyan
.\sync_to_render.ps1

# Paso 2: Exportar datos
Write-Host "`nPaso 2: Exportando datos..." -ForegroundColor Cyan
.\export_localhost_data.ps1

# Paso 3: Importar datos
Write-Host "`nPaso 3: Importando datos..." -ForegroundColor Cyan
.\import_to_render.ps1

# Paso 4: Verificar
Write-Host "`nPaso 4: Verificando sincronización..." -ForegroundColor Cyan
.\verify_sync.ps1
```

## ⚠️ Notas Importantes

1. **Backup**: Siempre haz backup de Render antes de sincronizar
2. **Orden**: Ejecuta los scripts en orden (1 → 2 → 3 → 4)
3. **Errores**: Si un script falla, revisa el mensaje de error antes de continuar
4. **Usuarios**: Los usuarios NO se sincronizan (para preservar passwords de producción)

## 🆘 Troubleshooting

### Error: "No se encuentra psql.exe"
- Verifica que PostgreSQL esté instalado en `C:\Program Files\PostgreSQL\18\bin`
- O modifica la variable `$psqlPath` en los scripts

### Error: "No se puede conectar a localhost"
- Verifica que PostgreSQL esté corriendo
- Verifica las credenciales en el script

### Error: "No se puede conectar a Render"
- Verifica que la conexión a internet funcione
- Verifica las credenciales de Render
- Verifica que el firewall permita la conexión

### Error: "duplicate key value"
- Hay datos duplicados entre localhost y Render
- Considera limpiar Render primero o usar `ON CONFLICT DO UPDATE`

## 📁 Archivos Generados

- `export_business_data.sql` - Archivo con datos exportados (se crea en Paso 2)

## ✅ Resultado Final

Después de ejecutar todos los pasos:
- ✅ Esquema sincronizado
- ✅ Datos sincronizados
- ✅ Ambas bases de datos homologadas

