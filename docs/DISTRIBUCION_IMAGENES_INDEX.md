# 📸 Distribución de Imágenes en el Index/Home

## 🎯 Vista General

En la página principal (`index.html`), los tours se muestran en un **grid responsivo** con tarjetas (cards) que incluyen una imagen principal para cada tour.

## 📐 Layout del Grid

### Sistema de Grid CSS

```css
.tours-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: var(--space-xl);  /* 40px de separación */
  margin-top: var(--space-xl);
}
```

### Distribución Visual

```
┌─────────────────────────────────────────────────────────┐
│                    HERO SECTION                         │
│              (Banner principal con búsqueda)            │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│              Tours Disponibles (Título)                 │
└─────────────────────────────────────────────────────────┘

┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│  TOUR 1     │  │  TOUR 2     │  │  TOUR 3     │
│  [Imagen]   │  │  [Imagen]   │  │  [Imagen]   │
│  Título     │  │  Título     │  │  Título     │
│  Descripción│  │  Descripción│  │  Descripción│
│  $XXX       │  │  $XXX       │  │  $XXX       │
└─────────────┘  └─────────────┘  └─────────────┘

┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│  TOUR 4     │  │  TOUR 5     │  │  TOUR 6     │
│  [Imagen]   │  │  [Imagen]   │  │  [Imagen]   │
│  ...        │  │  ...        │  │  ...        │
└─────────────┘  └─────────────┘  └─────────────┘
```

### Responsive Breakpoints

- **Desktop (>768px)**: 3 columnas (mínimo 340px por tarjeta)
- **Tablet (768px)**: 2 columnas
- **Mobile (<768px)**: 1 columna (full width)

```css
@media (max-width: 768px) {
  .tours-grid {
    grid-template-columns: 1fr;  /* Una sola columna en móvil */
  }
}
```

## 🖼️ Estructura de la Tarjeta de Tour

Cada tarjeta tiene esta estructura:

```
┌─────────────────────────────────┐
│  [Badge: Disponible/Agotado]    │ ← Badge flotante (top-right)
│                                 │
│  ┌───────────────────────────┐  │
│  │                           │  │
│  │     IMAGEN PRINCIPAL      │  │ ← Altura: 240px
│  │     (objeto-fit: cover)   │  │ ← Ancho: 100%
│  │                           │  │
│  └───────────────────────────┘  │
│                                 │
│  📝 Título del Tour             │
│  📄 Descripción (2 líneas max)  │
│                                 │
│  ─────────────────────────────  │
│  💰 $XXX   ⏱ Xh  📍 Ubicación  │
└─────────────────────────────────┘
```

## 🎨 Propiedades de la Imagen

### Tamaño y Posicionamiento

```css
.tour-card-image {
  width: 100%;           /* Ocupa todo el ancho de la tarjeta */
  height: 240px;         /* Altura fija */
  object-fit: cover;     /* Cubre todo el área, recortando si es necesario */
  background: gradient;  /* Fondo degradado mientras carga */
}
```

### Efectos de Hover

```css
.tour-card:hover .tour-card-image {
  transform: scale(1.1);  /* Zoom 10% al pasar el mouse */
}
```

### Carga Optimizada

- **Lazy Loading**: Las imágenes se cargan solo cuando son visibles
- **Fallback**: Si la imagen falla, se usa una imagen de referencia

```html
<img 
  src="${imageUrl}" 
  alt="${tourName}" 
  class="tour-card-image" 
  loading="lazy"  <!-- Carga diferida -->
  onerror="this.src='${defaultImage}'"  <!-- Fallback si falla -->
/>
```

## 🔄 Prioridad de Selección de Imagen

El sistema busca la imagen en este orden:

1. **`tourImages[0].imageUrl`** 
   - Primera imagen del array de imágenes del tour
   - Esta es la imagen principal marcada con `IsPrimary = true`

2. **`tour.imageUrl`** 
   - Imagen principal del tour (fallback)

3. **`getDefaultTourImage(tourId)`**
   - Imagen de referencia basada en el ID del tour
   - Selección determinista (siempre la misma para el mismo ID)

4. **Placeholder genérico**
   - URL: `https://via.placeholder.com/400x220?text=Tour+Image`
   - Solo si no hay ninguna imagen disponible

### Código JavaScript

```javascript
const imageUrl = tourImages?.[0]?.imageUrl || tourImages?.[0]?.ImageUrl
  || tour.imageUrl || tour.ImageUrl
  || getDefaultTourImage(tourId)
  || 'https://via.placeholder.com/400x220?text=Tour+Image';
```

## 📊 Ejemplo de Datos del Backend

El backend retorna las imágenes así:

```json
{
  "id": "uuid-del-tour",
  "name": "Tour del Canal",
  "tourImages": [
    {
      "imageUrl": "/uploads/tours/imagen-principal.jpg",
      "isPrimary": true,
      "displayOrder": 0
    },
    {
      "imageUrl": "/uploads/tours/imagen-2.jpg",
      "isPrimary": false,
      "displayOrder": 1
    }
  ],
  "imageUrl": "/uploads/tours/imagen-principal.jpg"  // Redundante pero útil
}
```

**En el index solo se muestra la primera imagen** (`tourImages[0]`), que es la principal.

## 🎯 Características del Grid

### Ventajas del Sistema Actual

1. **Responsive**: Se adapta automáticamente al tamaño de pantalla
2. **Flexible**: `auto-fill` permite que las columnas se ajusten
3. **Uniforme**: Todas las tarjetas tienen el mismo tamaño
4. **Performance**: Lazy loading de imágenes
5. **Accesible**: Alt text en todas las imágenes

### Espaciado

- **Gap entre tarjetas**: 40px (`--space-xl`)
- **Padding interno**: 28px (`--space-lg`)
- **Border radius**: 24px (`--radius-lg`)

## 📱 Comportamiento Responsive

### Desktop (1920px)
```
[Tour 1] [Tour 2] [Tour 3] [Tour 4] [Tour 5]
```

### Tablet (1024px)
```
[Tour 1] [Tour 2] [Tour 3]
[Tour 4] [Tour 5] [Tour 6]
```

### Mobile (375px)
```
[Tour 1]
[Tour 2]
[Tour 3]
[Tour 4]
```

## 💡 Recomendaciones para Imágenes

### Tamaño Recomendado
- **Ancho**: 1200px mínimo
- **Alto**: 800px mínimo
- **Ratio**: 3:2 o 16:9 (horizontal)
- **Formato**: JPG, PNG, WEBP
- **Peso**: < 500KB (optimizado)

### Tamaño Mínimo para Calidad
- **Ancho mínimo**: 680px (340px × 2 para retina)
- **Alto mínimo**: 480px (240px × 2 para retina)

### Proporción en Tarjeta
- **Ancho**: 100% del contenedor (340px-500px típicamente)
- **Alto**: 240px fijo
- **Recorte**: `object-fit: cover` recorta los lados si es necesario

## 🔍 Debugging

Si las imágenes no se muestran, verifica:

1. **Consola del navegador**: Revisa errores 404
2. **Network tab**: Verifica que las imágenes se carguen
3. **Estructura de datos**: Confirma que `tourImages[0].imageUrl` existe
4. **Fallback**: Verifica que `getDefaultTourImage()` funcione

### Logs de Debug

El código incluye logs detallados:
```javascript
console.log('🎴 [createTourCard] === INICIO ===', { tour });
console.log('📋 [createTourCard] Propiedades normalizadas:', {
  tourId,
  tourName,
  tourImagesCount: tourImages.length
});
```

## 📝 Notas Importantes

1. **Solo se muestra 1 imagen por tour** en el index
2. **Para ver todas las imágenes**, el usuario debe hacer clic en la tarjeta y ver el detalle
3. **La imagen principal** (`IsPrimary = true`) es siempre la primera en el array
4. **El orden** viene del campo `DisplayOrder` en la base de datos
5. **Las imágenes se optimizan** automáticamente con `object-fit: cover`

