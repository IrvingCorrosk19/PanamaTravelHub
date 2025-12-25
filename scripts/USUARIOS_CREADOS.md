# Usuarios Creados en la Base de Datos

## Resumen
Se han eliminado todos los usuarios existentes y se han creado 4 usuarios nuevos:

## Usuarios Creados

### 1. Administrador
- **Email:** admin@panamatravelhub.com
- **Password:** Admin123!
- **Nombre:** Administrador Sistema
- **Rol:** Admin
- **Estado:** Activo

### 2. Cliente
- **Email:** cliente@panamatravelhub.com
- **Password:** Cliente123!
- **Nombre:** Cliente Ejemplo
- **Rol:** Customer
- **Estado:** Activo

### 3. Usuario de Prueba 1
- **Email:** test1@panamatravelhub.com
- **Password:** Test123!
- **Nombre:** Test Usuario Uno
- **Rol:** Customer
- **Estado:** Activo

### 4. Usuario de Prueba 2
- **Email:** test2@panamatravelhub.com
- **Password:** Prueba123!
- **Nombre:** Test Usuario Dos
- **Rol:** Customer
- **Estado:** Activo

## Roles Disponibles

1. **Customer** - Cliente regular del sistema
2. **Admin** - Administrador del sistema

## Notas

- Todas las contraseñas están hasheadas con BCrypt (work factor 12)
- Los usuarios fueron creados con IDs fijos (UUIDs) para facilitar las pruebas
- Los roles Customer y Admin fueron creados/actualizados si no existían

## Scripts Relacionados

- `reset-and-create-users.sql` - Script SQL para crear estos usuarios
- `verify-users.ps1` - Script PowerShell para verificar usuarios

