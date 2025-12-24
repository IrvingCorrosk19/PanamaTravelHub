// Sistema de Loading Global para ToursPanama

class LoadingManager {
  constructor() {
    this.activeLoaders = new Set();
    this.globalLoader = null;
  }

  /**
   * Muestra un loader global
   */
  showGlobal(message = 'Cargando...') {
    if (this.globalLoader) {
      return;
    }

    const loader = document.createElement('div');
    loader.id = 'global-loader';
    loader.className = 'global-loader';
    loader.innerHTML = `
      <div class="loader-overlay"></div>
      <div class="loader-content">
        <div class="loader-spinner"></div>
        <p class="loader-message">${message}</p>
      </div>
    `;
    document.body.appendChild(loader);
    this.globalLoader = loader;
    
    // Animación de entrada
    setTimeout(() => loader.classList.add('active'), 10);
  }

  /**
   * Oculta el loader global
   */
  hideGlobal() {
    if (this.globalLoader) {
      this.globalLoader.classList.remove('active');
      setTimeout(() => {
        if (this.globalLoader && this.globalLoader.parentNode) {
          this.globalLoader.parentNode.removeChild(this.globalLoader);
        }
        this.globalLoader = null;
      }, 300);
    }
  }

  /**
   * Muestra un loader en un elemento específico
   */
  showInElement(element, message = 'Cargando...') {
    if (!element) return null;

    const loaderId = `loader-${Date.now()}-${Math.random()}`;
    const loader = document.createElement('div');
    loader.className = 'element-loader';
    loader.id = loaderId;
    loader.innerHTML = `
      <div class="loader-spinner-small"></div>
      ${message ? `<span class="loader-text">${message}</span>` : ''}
    `;
    
    // Estilo del contenedor
    const container = element;
    const originalPosition = window.getComputedStyle(container).position;
    if (originalPosition === 'static') {
      container.style.position = 'relative';
    }
    
    container.appendChild(loader);
    this.activeLoaders.add(loaderId);
    
    return loaderId;
  }

  /**
   * Oculta el loader de un elemento específico
   */
  hideInElement(loaderId) {
    if (!loaderId) return;
    
    const loader = document.getElementById(loaderId);
    if (loader && loader.parentNode) {
      loader.parentNode.removeChild(loader);
      this.activeLoaders.delete(loaderId);
    }
  }

  /**
   * Muestra un loader en un botón
   */
  showInButton(button, text = null) {
    if (!button) return null;
    
    const originalText = button.textContent || button.innerHTML;
    const loaderId = `btn-loader-${Date.now()}`;
    
    button.disabled = true;
    button.dataset.loaderId = loaderId;
    button.dataset.originalText = originalText;
    
    const spinner = document.createElement('span');
    spinner.className = 'btn-spinner';
    spinner.innerHTML = '<span class="spinner-dot"></span><span class="spinner-dot"></span><span class="spinner-dot"></span>';
    
    if (text) {
      button.innerHTML = spinner.outerHTML + ' ' + text;
    } else {
      button.innerHTML = spinner.outerHTML + ' ' + originalText;
    }
    
    button.classList.add('btn-loading');
    this.activeLoaders.add(loaderId);
    
    return loaderId;
  }

  /**
   * Oculta el loader de un botón
   */
  hideInButton(button) {
    if (!button) return;
    
    const loaderId = button.dataset.loaderId;
    if (loaderId) {
      const originalText = button.dataset.originalText || 'Enviar';
      button.innerHTML = originalText;
      button.disabled = false;
      button.classList.remove('btn-loading');
      delete button.dataset.loaderId;
      delete button.dataset.originalText;
      this.activeLoaders.delete(loaderId);
    }
  }

  /**
   * Muestra un loader inline (para tablas, listas, etc.)
   */
  showInline(container, message = 'Cargando...') {
    if (!container) return null;
    
    const loaderId = `inline-loader-${Date.now()}`;
    const loader = document.createElement('div');
    loader.className = 'inline-loader';
    loader.id = loaderId;
    loader.innerHTML = `
      <div class="inline-spinner"></div>
      <span>${message}</span>
    `;
    
    container.innerHTML = '';
    container.appendChild(loader);
    this.activeLoaders.add(loaderId);
    
    return loaderId;
  }

  /**
   * Oculta el loader inline
   */
  hideInline(container) {
    if (!container) return;
    
    const loader = container.querySelector('.inline-loader');
    if (loader) {
      loader.remove();
    }
  }
}

// Instancia global
const loadingManager = new LoadingManager();

// Interceptar fetch para mostrar loading automático (opcional)
const originalFetch = window.fetch;
let fetchCount = 0;

window.fetch = function(...args) {
  fetchCount++;
  
  // Solo mostrar loading global si no hay otros loaders activos
  if (fetchCount === 1 && loadingManager.activeLoaders.size === 0) {
    // No mostrar automáticamente para evitar spam
    // loadingManager.showGlobal();
  }
  
  return originalFetch.apply(this, args)
    .finally(() => {
      fetchCount--;
      if (fetchCount === 0 && loadingManager.activeLoaders.size === 0) {
        // loadingManager.hideGlobal();
      }
    });
};

// Exportar para uso global
window.loadingManager = loadingManager;

