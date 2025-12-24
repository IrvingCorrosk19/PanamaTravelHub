// Sistema de logging mejorado para debugging
class Logger {
  constructor() {
    this.enabled = true;
    this.logLevel = 'debug'; // 'debug', 'info', 'warn', 'error'
  }

  formatError(error, context = {}) {
    const timestamp = new Date().toISOString();
    const errorInfo = {
      timestamp,
      message: error.message || 'Error desconocido',
      name: error.name || 'Error',
      stack: error.stack,
      ...context
    };

    return errorInfo;
  }

  log(level, message, data = {}) {
    if (!this.enabled) return;

    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      level,
      message,
      ...data
    };

    const emoji = {
      debug: '🔍',
      info: 'ℹ️',
      warn: '⚠️',
      error: '❌',
      success: '✅'
    }[level] || '📝';

    const consoleMethod = {
      debug: console.debug,
      info: console.info,
      warn: console.warn,
      error: console.error
    }[level] || console.log;

    // Mostrar en consola con formato legible
    console.group(`${emoji} [${level.toUpperCase()}] ${message}`);
    console.log('Timestamp:', timestamp);
    
    if (Object.keys(data).length > 0) {
      console.log('Data:', data);
    }
    
    console.groupEnd();

    // También mostrar el objeto completo para copiar/pegar
    console.log(`${emoji} [${level.toUpperCase()}] Full Object:`, logEntry);
  }

  debug(message, data = {}) {
    if (this.logLevel === 'debug') {
      this.log('debug', message, data);
    }
  }

  info(message, data = {}) {
    this.log('info', message, data);
  }

  warn(message, data = {}) {
    this.log('warn', message, data);
  }

  error(message, error = null, context = {}) {
    const errorData = error 
      ? this.formatError(error, context)
      : { ...context, message };

    this.log('error', message, errorData);

    // Para errores, también mostrar el stack trace si está disponible
    if (error && error.stack) {
      console.error('Stack Trace:', error.stack);
    }
  }

  success(message, data = {}) {
    this.log('success', message, data);
  }

  // Método para loggear requests HTTP
  logRequest(method, url, options = {}) {
    this.debug('API Request', {
      method,
      url,
      headers: options.headers || {},
      hasBody: !!options.body,
      body: options.body ? (typeof options.body === 'string' ? JSON.parse(options.body) : options.body) : null
    });
  }

  // Método para loggear responses HTTP
  logResponse(response, data = null) {
    this.debug('API Response', {
      status: response.status,
      statusText: response.statusText,
      ok: response.ok,
      headers: Object.fromEntries(response.headers.entries()),
      data
    });
  }

  // Método para loggear errores HTTP
  logHttpError(response, errorData = null) {
    const errorInfo = {
      status: response.status,
      statusText: response.statusText,
      url: response.url,
      headers: Object.fromEntries(response.headers.entries()),
      error: errorData
    };

    this.error(`HTTP Error ${response.status}: ${response.statusText}`, null, errorInfo);

    // Mostrar detalles del error de forma estructurada
    console.group('🔴 HTTP Error Details');
    console.error('Status:', response.status);
    console.error('Status Text:', response.statusText);
    console.error('URL:', response.url);
    
    if (errorData) {
      console.error('Error Data:', errorData);
      
      // Si hay errores de validación, mostrarlos de forma clara
      if (errorData.errors && typeof errorData.errors === 'object') {
        console.group('📋 Validation Errors:');
        Object.keys(errorData.errors).forEach(field => {
          const fieldErrors = errorData.errors[field];
          if (Array.isArray(fieldErrors)) {
            fieldErrors.forEach(err => {
              console.error(`  • ${field}: ${err}`);
            });
          }
        });
        console.groupEnd();
      }
    }
    
    console.groupEnd();
  }
}

// Crear instancia global
const logger = new Logger();

// Capturar errores globales no manejados
window.addEventListener('error', (event) => {
  logger.error('Unhandled Error', event.error, {
    message: event.message,
    filename: event.filename,
    lineno: event.lineno,
    colno: event.colno,
    error: event.error
  });
});

// Capturar promesas rechazadas no manejadas
window.addEventListener('unhandledrejection', (event) => {
  logger.error('Unhandled Promise Rejection', event.reason, {
    promise: event.promise,
    reason: event.reason
  });
});

// Exportar para uso global
window.logger = logger;

