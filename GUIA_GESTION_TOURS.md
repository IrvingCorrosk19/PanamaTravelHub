# Guía de Gestión de Tours

Esta guía explica cómo gestionar tours en la aplicación PanamaTravelHub.

## 📋 Opciones para Gestionar Tours

### 1. **Panel de Administración Web** (Recomendado) ⭐

La forma más fácil y visual de gestionar tours es a través del panel de administración.

#### Acceso:
1. Inicia sesión en la aplicación
2. Ve a `/admin.html` o haz clic en "Admin" en el menú de navegación

#### Funcionalidades:

**Crear un Nuevo Tour:**
1. En el panel admin, haz clic en "+ Nuevo Tour"
2. Completa el formulario:
   - **Nombre del Tour**: Nombre descriptivo
   - **Descripción**: Descripción detallada del tour
   - **Itinerario**: Pasos o actividades del tour (opcional)
   - **Precio**: Precio en USD
   - **Capacidad Máxima**: Número máximo de participantes
   - **Duración**: Horas que dura el tour
   - **Ubicación**: Lugar del tour
   - **Estado**: Activo/Inactivo
   - **Imágenes**: URLs de imágenes (una por línea)
     - La primera URL será la imagen principal
     - Ejemplo:
       ```
       https://ejemplo.com/imagen1.jpg
       https://ejemplo.com/imagen2.jpg
       https://ejemplo.com/imagen3.jpg
       ```

**Editar un Tour:**
1. En la tabla de tours, haz clic en "Editar"
2. Modifica los campos necesarios
3. Haz clic en "Guardar"

**Eliminar/Desactivar un Tour:**
1. En la tabla de tours, haz clic en "Eliminar"
2. Confirma la acción
3. El tour se desactivará (soft delete) si tiene reservas activas

**Ver Reservas:**
- Haz clic en la pestaña "Reservas" para ver todas las reservas
- Verás información del cliente, tour, participantes, total y estado

**Ver Estadísticas:**
- Haz clic en la pestaña "Estadísticas"
- Verás métricas como:
  - Tours totales y activos
  - Reservas totales
  - Ingresos totales
  - Usuarios registrados

---

### 2. **Directamente en la Base de Datos** (Avanzado)

Si prefieres trabajar directamente con SQL:

#### Conectar a la Base de Datos:

**Local:**
```bash
psql -h localhost -U postgres -d PanamaTravelHub
```

**Render (Producción):**
```bash
PGPASSWORD=YFxc28DdPtabZS11XfVxywP5SnS53yZP psql -h dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com -U panamatravelhub_user -d panamatravelhub
```

#### Ejemplos de Consultas:

**Crear un Tour:**
```sql
INSERT INTO tours (name, description, price, max_capacity, duration_hours, location, is_active, available_spots)
VALUES (
  'Tour del Canal de Panamá',
  'Descubre la maravilla de la ingeniería mundial...',
  75.00,
  20,
  4,
  'Ciudad de Panamá',
  true,
  20
);

-- Agregar imagen
INSERT INTO tour_images (tour_id, image_url, is_primary)
VALUES (
  (SELECT id FROM tours WHERE name = 'Tour del Canal de Panamá'),
  'https://ejemplo.com/canal-panama.jpg',
  true
);
```

**Actualizar un Tour:**
```sql
UPDATE tours
SET 
  name = 'Nuevo Nombre',
  price = 80.00,
  description = 'Nueva descripción'
WHERE id = 'uuid-del-tour';
```

**Agregar Imágenes a un Tour:**
```sql
INSERT INTO tour_images (tour_id, image_url, is_primary, display_order)
VALUES 
  ('uuid-del-tour', 'https://ejemplo.com/imagen1.jpg', true, 1),
  ('uuid-del-tour', 'https://ejemplo.com/imagen2.jpg', false, 2);
```

**Desactivar un Tour:**
```sql
UPDATE tours
SET is_active = false
WHERE id = 'uuid-del-tour';
```

**Ver Tours:**
```sql
SELECT t.*, 
       (SELECT image_url FROM tour_images WHERE tour_id = t.id AND is_primary = true LIMIT 1) as primary_image
FROM tours t
ORDER BY created_at DESC;
```

---

### 3. **API REST** (Para Desarrolladores)

Puedes usar los endpoints de la API directamente:

#### Endpoints Disponibles:

**Obtener todos los tours (Admin):**
```http
GET /api/admin/tours
Authorization: Bearer {token}
```

**Crear un tour:**
```http
POST /api/admin/tours
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Tour del Canal",
  "description": "Descripción del tour",
  "itinerary": "Itinerario detallado",
  "price": 75.00,
  "maxCapacity": 20,
  "durationHours": 4,
  "location": "Ciudad de Panamá",
  "isActive": true,
  "images": [
    "https://ejemplo.com/imagen1.jpg",
    "https://ejemplo.com/imagen2.jpg"
  ]
}
```

**Actualizar un tour:**
```http
PUT /api/admin/tours/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Nuevo Nombre",
  "price": 80.00
}
```

**Eliminar un tour:**
```http
DELETE /api/admin/tours/{id}
Authorization: Bearer {token}
```

**Obtener un tour específico:**
```http
GET /api/admin/tours/{id}
Authorization: Bearer {token}
```

---

## 📸 Gestión de Imágenes

### Opciones para Imágenes:

1. **URLs Externas** (Recomendado):
   - Sube imágenes a servicios como:
     - [Cloudinary](https://cloudinary.com)
     - [Imgur](https://imgur.com)
     - [Unsplash](https://unsplash.com)
     - [AWS S3](https://aws.amazon.com/s3/)
   - Usa las URLs en el campo "Imágenes" del formulario

2. **Almacenamiento Local** (Futuro):
   - Actualmente no está implementado
   - Se puede agregar funcionalidad de subida de archivos

### Mejores Prácticas:

- **Imagen Principal**: La primera URL será la imagen principal
- **Tamaño Recomendado**: 1200x800px para mejor calidad
- **Formato**: JPG o PNG
- **Peso**: Menos de 2MB por imagen
- **Múltiples Imágenes**: Puedes agregar varias imágenes, una por línea

---

## 🔐 Autenticación

**Nota Importante**: Actualmente la autenticación está en modo mock. Para usar el panel admin:

1. Inicia sesión con cualquier email/password (se acepta cualquier credencial)
2. El token se guarda en `localStorage`
3. El panel admin verifica que exista un token

**En Producción**: Se implementará autenticación JWT real con roles de administrador.

---

## 📝 Campos del Tour

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| name | string | Sí | Nombre del tour (máx. 200 caracteres) |
| description | text | Sí | Descripción detallada |
| itinerary | text | No | Itinerario paso a paso |
| price | decimal | Sí | Precio en USD (mín. 0) |
| maxCapacity | integer | Sí | Capacidad máxima (mín. 1) |
| durationHours | integer | Sí | Duración en horas (mín. 1) |
| location | string | No | Ubicación del tour |
| isActive | boolean | Sí | Activo/Inactivo |
| images | array | No | URLs de imágenes |

---

## 🚀 Próximas Mejoras

- [ ] Subida de archivos de imágenes directamente
- [ ] Editor de texto enriquecido para descripciones
- [ ] Gestión de fechas disponibles para tours
- [ ] Exportar tours a CSV/Excel
- [ ] Duplicar tours existentes
- [ ] Vista previa de tours antes de publicar
- [ ] Historial de cambios en tours

---

## 💡 Consejos

1. **Usa el Panel Admin**: Es la forma más fácil y segura
2. **Guarda URLs de Imágenes**: Usa servicios de hosting de imágenes
3. **Revisa Antes de Publicar**: Verifica que toda la información esté correcta
4. **Mantén Tours Activos**: Solo activa tours que estén disponibles
5. **Actualiza Disponibilidad**: Ajusta `availableSpots` según las reservas

---

¿Necesitas ayuda? Revisa la documentación de la API o contacta al equipo de desarrollo.

