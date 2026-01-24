# Design System Mínimo — Premium (v1)

## 🎯 Principios Fundamentales

1. **Menos componentes, mejor usados**
2. **Un solo botón principal**
3. **Todo debe sentirse igual en cualquier página**
4. **El sistema acompaña, no distrae**
5. **Premium ≠ recargado**

## 📦 Uso Rápido

### Importar el Design System

```html
<link rel="stylesheet" href="/css/design-system.css" />
```

**Importante:** Incluir después de `main.css` y antes de estilos específicos para permitir sobrescritura cuando sea necesario.

## 🎨 Tokens Fundamentales

### Colores

```css
/* Primarios */
--color-primary: #0d6efd;
--color-primary-hover: #0b5ed7;

/* Texto */
--color-text: #1f2937;
--color-text-muted: #6b7280;

/* Fondos */
--color-bg: #ffffff;
--color-bg-soft: #f9fafb;

/* Estados */
--color-success: #16a34a;
--color-warning: #f59e0b;
--color-danger: #dc2626;
```

### Espaciado (múltiplos de 8)

```css
--space-xs: 4px;
--space-sm: 8px;
--space-md: 16px;
--space-lg: 24px;
--space-xl: 32px;
--space-2xl: 48px;
```

### Radios

```css
--radius-sm: 6px;
--radius-md: 12px;
--radius-lg: 16px;
--radius-full: 999px;
```

## 🔘 Botones

### Botón Primario (UNO SOLO)

**Se usa solo para:**
- Reservar
- Confirmar
- Guardar
- Acciones principales

```html
<button class="btn-primary">Reservar Ahora</button>
<a href="#" class="btn-primary">Confirmar</a>
```

### Botón Secundario

```html
<button class="btn-secondary">Cancelar</button>
<a href="#" class="btn-secondary">Ver más</a>
```

### Tamaños

```html
<button class="btn-primary btn-sm">Pequeño</button>
<button class="btn-primary">Normal</button>
<button class="btn-primary btn-lg">Grande</button>
```

## 📝 Inputs

```html
<label class="label">Email</label>
<input type="email" class="input" placeholder="tu@email.com" />

<label class="label label-required">Nombre</label>
<input type="text" class="input" />

<!-- Error -->
<input type="text" class="input input-error" />
<span class="input-error-message">Este campo es requerido</span>
```

## 🃏 Cards

```html
<div class="card">
  <div class="card-header">
    <h3 class="card-title">Título</h3>
  </div>
  <div class="card-body">
    Contenido de la card
  </div>
  <div class="card-footer">
    Footer opcional
  </div>
</div>
```

### Variantes

```html
<!-- Con más elevación -->
<div class="card card-elevated">...</div>

<!-- Solo borde -->
<div class="card card-bordered">...</div>
```

## 🏷️ Badges

```html
<span class="badge badge-primary">Nuevo</span>
<span class="badge badge-success">Activo</span>
<span class="badge badge-warning">Pendiente</span>
<span class="badge badge-danger">Urgente</span>
<span class="badge badge-info">Info</span>
<span class="badge badge-muted">Secundario</span>
```

**Regla:** El badge resalta, no decora. No abusar.

## 🎯 Utilidades

### Espaciado

```html
<div class="mt-lg mb-md">Margen superior grande, inferior mediano</div>
<div class="p-xl">Padding extra grande</div>
```

### Texto

```html
<p class="text-center text-muted">Texto centrado y muted</p>
<p class="text-primary">Texto en color primario</p>
```

### Display

```html
<div class="flex flex-between gap-md">
  <span>Izquierda</span>
  <span>Derecha</span>
</div>

<div class="flex flex-center gap-lg">
  <button>Botón 1</button>
  <button>Botón 2</button>
</div>
```

## 📱 Responsive

El Design System es responsive por defecto. En móviles:

- Botones se vuelven full-width
- Cards reducen padding
- Tipografía se ajusta automáticamente

## 🔄 Compatibilidad

El Design System mantiene compatibilidad con variables existentes:

```css
/* Variables antiguas → nuevas */
--primary → --color-primary
--text → --color-text
--text-secondary → --color-text-muted
--bg → --color-bg
--border → --color-border
```

## ✅ Checklist de Aplicación

- [ ] Importar `design-system.css` después de `main.css`
- [ ] Usar solo `.btn-primary` para acciones principales
- [ ] Usar tokens de espaciado (múltiplos de 8)
- [ ] Aplicar `.card` a contenedores principales
- [ ] Usar badges solo cuando resaltan información importante
- [ ] Mantener tipografía consistente (h1, h2, p, small)

## 🚫 Qué NO hacer

- ❌ Crear nuevos colores fuera del sistema
- ❌ Usar múltiples botones primarios en la misma vista
- ❌ Mezclar espaciados arbitrarios (usar tokens)
- ❌ Abusar de badges
- ❌ Crear componentes nuevos sin consultar el sistema

## 📚 Ejemplos de Uso

### Formulario Premium

```html
<div class="card">
  <h2 class="card-title">Reservar Tour</h2>
  
  <label class="label label-required">Fecha</label>
  <input type="date" class="input" />
  
  <label class="label label-required">Personas</label>
  <select class="input">
    <option>1 persona</option>
    <option>2 personas</option>
  </select>
  
  <button class="btn-primary mt-lg">Confirmar Reserva</button>
</div>
```

### Card de Tour

```html
<div class="card">
  <div class="card-header">
    <h3 class="card-title">Tour del Canal</h3>
    <span class="badge badge-success">Disponible</span>
  </div>
  <div class="card-body">
    <p>Descripción del tour...</p>
    <div class="flex flex-between mt-md">
      <span class="text-muted">$75.00</span>
      <button class="btn-primary">Reservar</button>
    </div>
  </div>
</div>
```

---

**Recuerda:** El Design System acompaña, no distrae. Menos es más. Premium es simplicidad ejecutada perfectamente.
