// API Client para ToursPanama
const API_BASE_URL = window.location.origin;

// Asegurar que logger esté disponible
if (typeof logger === 'undefined') {
  // Si logger.js no se ha cargado, crear un logger básico
  window.logger = {
    debug: (...args) => console.debug(...args),
    info: (...args) => console.info(...args),
    warn: (...args) => console.warn(...args),
    error: (msg, err, ctx) => {
      console.error('❌', msg, err || ctx);
      if (err && err.stack) console.error('Stack:', err.stack);
    },
    success: (...args) => console.log('✅', ...args),
    logRequest: (method, url, opts) => console.log('🌐', method, url, opts),
    logResponse: (res, data) => console.log('📥', res.status, data),
    logHttpError: (res, err) => console.error('❌ HTTP', res.status, err)
  };
}

class ApiClient {
  constructor() {
    this.baseUrl = API_BASE_URL;
    this.accessToken = localStorage.getItem('accessToken');
    this.refreshToken = localStorage.getItem('refreshToken');
    this.isRefreshing = false;
    this.failedQueue = [];
  }

    async request(endpoint, options = {}) {
      const url = `${this.baseUrl}${endpoint}`;
      const method = options.method || 'GET';
      
      logger.logRequest(method, url, options);

      const config = {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          ...options.headers,
        },
      };

      // Actualizar token antes de cada request
      this.accessToken = localStorage.getItem('accessToken');
      
      if (this.accessToken) {
        config.headers['Authorization'] = `Bearer ${this.accessToken}`;
        logger.debug('Token incluido en request');
      } else {
        logger.debug('No hay token disponible');
      }

      try {
        logger.debug('Enviando request...');
        const response = await fetch(url, config);
        
        logger.logResponse(response);
        
        if (!response.ok) {
          // Si es 401 (Unauthorized), intentar refresh token
          if (response.status === 401 && this.refreshToken && !endpoint.includes('/api/auth/refresh') && !endpoint.includes('/api/auth/login')) {
            logger.info('Token expirado, intentando refresh...');
            const refreshed = await this.refreshAccessToken();
            if (refreshed) {
              // Reintentar request con nuevo token
              config.headers['Authorization'] = `Bearer ${this.accessToken}`;
              logger.debug('Reintentando request con nuevo token');
              const retryResponse = await fetch(url, config);
              if (retryResponse.ok) {
                const data = await retryResponse.json();
                logger.success('Request exitoso después de refresh');
                return data;
              } else {
                logger.logHttpError(retryResponse);
              }
            }
          }

          // Intentar parsear el error
          let errorData = null;
          try {
            const errorText = await response.text();
            try {
              errorData = JSON.parse(errorText);
            } catch {
              errorData = { 
                title: 'Error desconocido',
                detail: errorText || 'Ocurrió un error al procesar la solicitud',
                status: response.status
              };
            }
          } catch (parseError) {
            logger.error('Error al parsear respuesta de error', parseError);
            errorData = { 
              title: 'Error desconocido',
              detail: 'Ocurrió un error al procesar la solicitud',
              status: response.status
            };
          }
          
          // Loggear el error HTTP
          logger.logHttpError(response, errorData);
          
          // Manejar errores de validación (ProblemDetails)
          if (errorData.errors && typeof errorData.errors === 'object') {
            // FluentValidation devuelve errores en formato { "PropertyName": ["Error1", "Error2"] }
            const validationErrors = [];
            
            // Mapear errores a mensajes más descriptivos
            const fieldNames = {
              'Email': 'Correo electrónico',
              'Password': 'Contraseña',
              'ConfirmPassword': 'Confirmación de contraseña',
              'FirstName': 'Nombre',
              'LastName': 'Apellido'
            };
            
            Object.keys(errorData.errors).forEach(field => {
              const fieldErrors = errorData.errors[field];
              if (Array.isArray(fieldErrors)) {
                fieldErrors.forEach(err => {
                  if (typeof err === 'string') {
                    const fieldName = fieldNames[field] || field;
                    validationErrors.push(`${fieldName}: ${err}`);
                  }
                });
              }
            });
            
            if (validationErrors.length > 0) {
              logger.error('Errores de validación detectados', null, { validationErrors });
              throw new Error(validationErrors.join('\n'));
            }
          }
          
          // Manejar errores específicos del backend
          let errorMessage = errorData.detail || errorData.message || errorData.title;
          
          // Mensajes más descriptivos para errores comunes
          if (errorMessage && errorMessage.includes('EMAIL_ALREADY_EXISTS')) {
            errorMessage = 'Este correo electrónico ya está registrado. Por favor, inicia sesión o usa otro correo.';
          } else if (errorMessage && errorMessage.includes('email ya está registrado')) {
            errorMessage = 'Este correo electrónico ya está registrado. Por favor, inicia sesión o usa otro correo.';
          } else if (errorMessage && errorMessage.includes('Invalid credentials')) {
            errorMessage = 'Correo electrónico o contraseña incorrectos. Por favor, verifica tus datos.';
          } else if (errorMessage && errorMessage.includes('Account locked')) {
            errorMessage = 'Tu cuenta ha sido bloqueada temporalmente por múltiples intentos fallidos. Contacta al soporte.';
          } else if (!errorMessage) {
            // Mensajes según el código de estado
            switch (response.status) {
              case 400:
                errorMessage = 'Los datos proporcionados no son válidos. Por favor, revisa el formulario.';
                break;
              case 401:
                errorMessage = 'No autorizado. Por favor, verifica tus credenciales.';
                break;
              case 403:
                errorMessage = 'No tienes permiso para realizar esta acción.';
                break;
              case 404:
                errorMessage = 'El recurso solicitado no fue encontrado.';
                break;
              case 409:
                errorMessage = 'Este correo electrónico ya está registrado. Por favor, inicia sesión.';
                break;
              case 422:
                errorMessage = 'Los datos proporcionados no cumplen con los requisitos. Por favor, revisa el formulario.';
                break;
              case 500:
                errorMessage = 'Error interno del servidor. Por favor, intenta nuevamente más tarde.';
                break;
              case 503:
                errorMessage = 'El servicio no está disponible temporalmente. Por favor, intenta más tarde.';
                break;
              default:
                errorMessage = `Error ${response.status}: ${response.statusText || 'Error desconocido'}`;
            }
          }
          
          logger.error('Error procesado', null, {
            errorMessage,
            status: response.status,
            traceId: errorData.traceId,
            instance: errorData.instance,
            type: errorData.type
          });
          
          // Crear error con información del status code y detalles
          const error = new Error(errorMessage);
          error.status = response.status;
          error.statusCode = response.status;
          error.errors = errorData.errors;
          error.response = errorData;
          throw error;
        }

        const data = await response.json();
        logger.success('Response exitoso', { data });
        return data;
      } catch (error) {
        logger.error('Error en API request', error, {
          endpoint,
          method: options.method || 'GET',
          url: `${this.baseUrl}${endpoint}`
        });
        throw error;
      }
    }

  // Tours
  async getTours() {
    return this.request('/api/tours');
  }

  async getTour(id) {
    return this.request(`/api/tours/${id}`);
  }

  // Auth
  async login(email, password) {
    logger.info('Iniciando login', { email, passwordLength: password?.length });
    try {
      const response = await this.request('/api/auth/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
      });
      logger.success('Login exitoso', { userId: response.user?.id });
      
      // Guardar accessToken y refreshToken
      if (response.accessToken && response.refreshToken) {
        this.accessToken = response.accessToken;
        this.refreshToken = response.refreshToken;
        localStorage.setItem('accessToken', response.accessToken);
        localStorage.setItem('refreshToken', response.refreshToken);
        // Mantener compatibilidad con código antiguo
        localStorage.setItem('authToken', response.accessToken);
        logger.debug('Tokens guardados en localStorage');
      }
      
      // Guardar userId para usar en reservas
      if (response.user && response.user.id) {
        localStorage.setItem('userId', response.user.id);
        logger.debug('UserId guardado', { userId: response.user.id });
      }
      
      // Guardar roles del usuario
      if (response.user && response.user.roles) {
        localStorage.setItem('userRoles', JSON.stringify(response.user.roles));
        logger.debug('Roles guardados', { roles: response.user.roles });
      }
      
      return response;
    } catch (error) {
      logger.error('Error en login', error);
      throw error;
    }
  }

  // Refresh access token
  async refreshAccessToken() {
    if (this.isRefreshing) {
      // Si ya hay un refresh en proceso, esperar
      return new Promise((resolve) => {
        this.failedQueue.push(resolve);
      });
    }

    this.isRefreshing = true;
    const currentRefreshToken = localStorage.getItem('refreshToken');

    if (!currentRefreshToken) {
      logger.warn('No hay refresh token disponible');
      this.isRefreshing = false;
      this.handleAuthFailure();
      return false;
    }

    try {
      logger.info('Refrescando access token...');
      const response = await fetch(`${this.baseUrl}/api/auth/refresh`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ refreshToken: currentRefreshToken }),
      });

      if (!response.ok) {
        throw new Error('Refresh token inválido o expirado');
      }

      const data = await response.json();
      
      if (data.accessToken && data.refreshToken) {
        this.accessToken = data.accessToken;
        this.refreshToken = data.refreshToken;
        localStorage.setItem('accessToken', data.accessToken);
        localStorage.setItem('refreshToken', data.refreshToken);
        localStorage.setItem('authToken', data.accessToken); // Compatibilidad
        logger.success('Access token refrescado exitosamente');
        
        // Resolver todas las peticiones en cola
        this.failedQueue.forEach(resolve => resolve(true));
        this.failedQueue = [];
        this.isRefreshing = false;
        
        return true;
      }

      throw new Error('No se recibieron tokens en la respuesta');
    } catch (error) {
      logger.error('Error al refrescar token', error);
      this.isRefreshing = false;
      this.failedQueue.forEach(resolve => resolve(false));
      this.failedQueue = [];
      this.handleAuthFailure();
      return false;
    }
  }

  // Manejar fallo de autenticación
  handleAuthFailure() {
    logger.warn('Sesión expirada, cerrando sesión...');
    this.logout();
    // Redirigir a login si no estamos ya ahí
    if (!window.location.pathname.includes('login.html')) {
      window.location.href = '/login.html';
    }
  }

  async register(userData) {
    logger.info('Iniciando registro', { email: userData.email?.substring(0, 5) + '***' });
    
    // Asegurar que confirmPassword esté incluido
    const registerData = {
      email: userData.email?.trim(),
      password: userData.password?.trim(),
      confirmPassword: userData.confirmPassword?.trim() || userData.password?.trim(),
      firstName: userData.firstName?.trim(),
      lastName: userData.lastName?.trim()
    };

    try {
      const response = await this.request('/api/auth/register', {
        method: 'POST',
        body: JSON.stringify(registerData),
      });
      
      logger.success('Registro exitoso', { userId: response.user?.id });
      
      // Guardar accessToken y refreshToken
      if (response.accessToken && response.refreshToken) {
        this.accessToken = response.accessToken;
        this.refreshToken = response.refreshToken;
        localStorage.setItem('accessToken', response.accessToken);
        localStorage.setItem('refreshToken', response.refreshToken);
        localStorage.setItem('authToken', response.accessToken); // Compatibilidad
        logger.debug('Tokens guardados en localStorage');
      }
      
      // Guardar userId para usar en reservas
      if (response.user && response.user.id) {
        localStorage.setItem('userId', response.user.id);
        logger.debug('UserId guardado', { userId: response.user.id });
      }
      
      // Guardar roles del usuario
      if (response.user && response.user.roles) {
        localStorage.setItem('userRoles', JSON.stringify(response.user.roles));
        logger.debug('Roles guardados', { roles: response.user.roles });
      }
      
      return response;
    } catch (error) {
      // Preservar status code del error para manejo específico en login.html
      logger.error('Error en registro', error);
      throw error;
    }
  }

  // Logout con revocación de refresh token
  async logout() {
    const refreshToken = localStorage.getItem('refreshToken');
    
    if (refreshToken) {
      try {
        await this.request('/api/auth/logout', {
          method: 'POST',
          body: JSON.stringify({ refreshToken }),
        });
        logger.success('Logout exitoso, refresh token revocado');
      } catch (error) {
        logger.warn('Error al revocar refresh token', error);
        // Continuar con logout local aunque falle el servidor
      }
    }
    
    // Limpiar tokens locales
    this.accessToken = null;
    this.refreshToken = null;
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('authToken');
    localStorage.removeItem('userId');
    localStorage.removeItem('userRoles');
    logger.debug('Tokens eliminados de localStorage');
  }

  // Obtener información del usuario actual
  async getCurrentUser() {
    return this.request('/api/auth/me');
  }

  // Verificar si un email está registrado
  async checkEmail(email) {
    logger.debug('Verificando disponibilidad de email', { email: email?.substring(0, 5) + '***' });
    try {
      const response = await this.request(`/api/auth/check-email?email=${encodeURIComponent(email)}`, {
        method: 'GET'
      });
      // La API devuelve un booleano directamente
      return response === true || response === 'true' || response === true;
    } catch (error) {
      logger.error('Error al verificar email', error);
      // Si hay error, retornar false para no bloquear la UI
      return false;
    }
  }

  // Solicitar recuperación de contraseña
  async forgotPassword(email) {
    logger.info('Solicitando recuperación de contraseña', { email: email?.substring(0, 5) + '***' });
    try {
      const response = await this.request('/api/auth/forgot-password', {
        method: 'POST',
        body: JSON.stringify({ email }),
      });
      logger.success('Solicitud de recuperación enviada');
      return response;
    } catch (error) {
      logger.error('Error al solicitar recuperación de contraseña', error);
      throw error;
    }
  }

  // Resetear contraseña con token
  async resetPassword(token, newPassword, confirmPassword) {
    logger.info('Reseteando contraseña');
    try {
      const response = await this.request('/api/auth/reset-password', {
        method: 'POST',
        body: JSON.stringify({ token, newPassword, confirmPassword }),
      });
      logger.success('Contraseña reseteada exitosamente');
      return response;
    } catch (error) {
      logger.error('Error al resetear contraseña', error);
      throw error;
    }
  }


  // Bookings
  async getMyBookings() {
    const userId = localStorage.getItem('userId');
    const url = userId ? `/api/bookings/my?userId=${userId}` : '/api/bookings/my';
    return this.request(url);
  }

  async createBooking(bookingData) {
    // Agregar userId desde localStorage
    const userId = localStorage.getItem('userId');
    if (userId) {
      bookingData.userId = userId;
    }
    
    const response = await this.request('/api/bookings', {
      method: 'POST',
      body: JSON.stringify(bookingData),
    });
    return response;
  }

  // Admin
  async getAdminTours() {
    return this.request('/api/admin/tours');
  }

  async createTour(tourData) {
    return this.request('/api/admin/tours', {
      method: 'POST',
      body: JSON.stringify(tourData),
    });
  }

  async updateTour(id, tourData) {
    return this.request(`/api/admin/tours/${id}`, {
      method: 'PUT',
      body: JSON.stringify(tourData),
    });
  }

  async deleteTour(id) {
    return this.request(`/api/admin/tours/${id}`, {
      method: 'DELETE',
    });
  }

  async getAdminBookings() {
    return this.request('/api/admin/bookings');
  }

  // Payments
  async createPayment(bookingId, currency = 'USD', provider = 'stripe') {
    const providerMap = {
      'stripe': 1,
      'paypal': 2,
      'yappy': 3
    };
    
    const requestBody = {
      bookingId: bookingId,
      currency: currency,
      provider: providerMap[provider.toLowerCase()] || 1
    };
    
    return this.request('/api/payments/create', {
      method: 'POST',
      body: JSON.stringify(requestBody),
      headers: { 'Content-Type': 'application/json' }
    });
  }

  async confirmPayment(paymentIntentId) {
    return this.request('/api/payments/confirm', {
      method: 'POST',
      body: JSON.stringify({ paymentIntentId }),
      headers: { 'Content-Type': 'application/json' }
    });
  }

  async getStripeConfig() {
    return this.request('/api/payments/stripe/config');
  }

  // Tour Dates
  async getCountries() {
    return this.request('/api/tours/countries', { method: 'GET' });
  }

  async getTourDates(tourId) {
    return this.request(`/api/tours/${tourId}/dates`);
  }

  // Admin Users
  async getAdminUsers(search = '', isActive = null, role = '') {
    const params = new URLSearchParams();
    if (search) params.append('search', search);
    if (isActive !== null) params.append('isActive', isActive);
    if (role) params.append('role', role);
    
    const queryString = params.toString();
    return this.request(`/api/admin/users${queryString ? '?' + queryString : ''}`);
  }

  async getAdminUser(userId) {
    return this.request(`/api/admin/users/${userId}`);
  }

  async updateAdminUser(userId, userData) {
    return this.request(`/api/admin/users/${userId}`, {
      method: 'PUT',
      body: JSON.stringify(userData),
    });
  }

  async unlockAdminUser(userId) {
    return this.request(`/api/admin/users/${userId}/unlock`, {
      method: 'POST',
    });
  }

  async getAdminRoles() {
    return this.request('/api/admin/roles');
  }

  async getAdminStats() {
    return this.request('/api/admin/stats');
  }

  // Homepage Content (público)
  async getHomePageContent() {
    return this.request('/api/tours/homepage-content');
  }
}

// Export singleton instance
const api = new ApiClient();
