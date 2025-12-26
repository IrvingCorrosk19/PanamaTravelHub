/**
 * Sistema de Notificaciones Profesional
 * Reemplaza los alert() con notificaciones elegantes
 */

class NotificationManager {
  constructor() {
    this.container = null;
    this.init();
  }

  init() {
    // Esperar a que el DOM esté listo
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => this.createContainer());
    } else {
      this.createContainer();
    }
  }

  createContainer() {
    // Crear contenedor de notificaciones si no existe
    if (!document.getElementById('notification-container')) {
      this.container = document.createElement('div');
      this.container.id = 'notification-container';
      this.container.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 10000;
        display: flex;
        flex-direction: column;
        gap: 12px;
        max-width: 400px;
        pointer-events: none;
      `;
      if (document.body) {
        document.body.appendChild(this.container);
      } else {
        // Si body no existe aún, esperar
        setTimeout(() => {
          if (document.body) {
            document.body.appendChild(this.container);
          }
        }, 100);
      }
    } else {
      this.container = document.getElementById('notification-container');
    }
  }

  show(message, type = 'info', duration = 5000) {
    const notification = document.createElement('div');
    const id = 'notification-' + Date.now();
    notification.id = id;
    
    const icons = {
      success: '✅',
      error: '❌',
      warning: '⚠️',
      info: 'ℹ️'
    };

    const colors = {
      success: {
        bg: 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
        border: '#10b981'
      },
      error: {
        bg: 'linear-gradient(135deg, #ef4444 0%, #dc2626 100%)',
        border: '#ef4444'
      },
      warning: {
        bg: 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)',
        border: '#f59e0b'
      },
      info: {
        bg: 'linear-gradient(135deg, #0ea5e9 0%, #0284c7 100%)',
        border: '#0ea5e9'
      }
    };

    const color = colors[type] || colors.info;
    
    notification.style.cssText = `
      background: ${color.bg};
      color: white;
      padding: 16px 20px;
      border-radius: 12px;
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2), 0 4px 12px rgba(0, 0, 0, 0.1);
      border-left: 4px solid ${color.border};
      display: flex;
      align-items: center;
      gap: 12px;
      font-size: 0.9375rem;
      font-weight: 500;
      line-height: 1.5;
      pointer-events: auto;
      cursor: pointer;
      transform: translateX(400px);
      opacity: 0;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      animation: slideInNotification 0.3s ease-out forwards;
    `;

    notification.innerHTML = `
      <span style="font-size: 1.25rem; flex-shrink: 0;">${icons[type] || icons.info}</span>
      <span style="flex: 1;">${message}</span>
      <button onclick="notificationManager.remove('${id}')" style="
        background: rgba(255, 255, 255, 0.2);
        border: none;
        color: white;
        width: 24px;
        height: 24px;
        border-radius: 50%;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 18px;
        line-height: 1;
        flex-shrink: 0;
        transition: background 0.2s;
      " onmouseover="this.style.background='rgba(255,255,255,0.3)'" onmouseout="this.style.background='rgba(255,255,255,0.2)'">×</button>
    `;

    // Agregar animación CSS si no existe
    if (!document.getElementById('notification-styles')) {
      const style = document.createElement('style');
      style.id = 'notification-styles';
      style.textContent = `
        @keyframes slideInNotification {
          from {
            transform: translateX(400px);
            opacity: 0;
          }
          to {
            transform: translateX(0);
            opacity: 1;
          }
        }
        @keyframes slideOutNotification {
          from {
            transform: translateX(0);
            opacity: 1;
          }
          to {
            transform: translateX(400px);
            opacity: 0;
          }
        }
      `;
      document.head.appendChild(style);
    }

    this.container.appendChild(notification);

    // Auto-remover después de la duración
    if (duration > 0) {
      setTimeout(() => {
        this.remove(id);
      }, duration);
    }

    // Click para cerrar
    notification.addEventListener('click', (e) => {
      if (e.target === notification || e.target.closest('button')) {
        this.remove(id);
      }
    });

    return id;
  }

  remove(id) {
    const notification = document.getElementById(id);
    if (notification) {
      notification.style.animation = 'slideOutNotification 0.3s ease-out forwards';
      setTimeout(() => {
        if (notification.parentNode) {
          notification.parentNode.removeChild(notification);
        }
      }, 300);
    }
  }

  success(message, duration = 5000) {
    return this.show(message, 'success', duration);
  }

  error(message, duration = 7000) {
    return this.show(message, 'error', duration);
  }

  warning(message, duration = 6000) {
    return this.show(message, 'warning', duration);
  }

  info(message, duration = 5000) {
    return this.show(message, 'info', duration);
  }
}

// Inicializar el gestor de notificaciones de forma segura
let notificationManager = null;

// Función para obtener o crear el notificationManager
function getNotificationManager() {
  if (!notificationManager) {
    notificationManager = new NotificationManager();
  }
  return notificationManager;
}

// Inicializar cuando el DOM esté listo
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    notificationManager = new NotificationManager();
  });
} else {
  notificationManager = new NotificationManager();
}

// Función global para compatibilidad
function showNotification(message, type = 'info', duration = 5000) {
  const manager = getNotificationManager();
  return manager.show(message, type, duration);
}

// Asegurar que notificationManager esté disponible globalmente
window.notificationManager = getNotificationManager();

