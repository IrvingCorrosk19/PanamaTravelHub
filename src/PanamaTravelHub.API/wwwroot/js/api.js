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
          ...options.headers,
        },
      };

      // Solo agregar Content-Type si no es FormData
      if (!(options.body instanceof FormData)) {
        config.headers['Content-Type'] = 'application/json';
      }

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
          
          // Mensajes más descriptivos y humanos para errores comunes
          if (response.status === 401) {
            errorMessage = 'Tu sesión expiró. Por favor, inicia sesión nuevamente.';
          } else if (response.status === 403) {
            errorMessage = 'No tienes permiso para realizar esta acción.';
          } else if (response.status === 404) {
            errorMessage = 'No se encontró el recurso solicitado.';
          } else if (response.status === 500) {
            errorMessage = 'Algo salió mal en el servidor. Inténtalo de nuevo en unos segundos.';
          } else if (response.status >= 500) {
            errorMessage = 'Algo salió mal. Inténtalo de nuevo en unos segundos.';
          } else if (errorMessage && errorMessage.includes('EMAIL_ALREADY_EXISTS')) {
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
                errorMessage = 'Tu sesión expiró. Por favor, inicia sesión nuevamente.';
                break;
              case 403:
                errorMessage = 'No tienes permiso para realizar esta acción.';
                break;
              case 404:
                errorMessage = 'No se encontró el recurso solicitado.';
                break;
              case 409:
                errorMessage = 'Este correo electrónico ya está registrado. Por favor, inicia sesión.';
                break;
              case 422:
                errorMessage = 'Los datos proporcionados no cumplen con los requisitos. Por favor, revisa el formulario.';
                break;
              case 500:
                errorMessage = 'Algo salió mal en el servidor. Inténtalo de nuevo en unos segundos.';
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

        const contentType = response.headers.get('Content-Type') || '';
        const isJson = contentType.includes('application/json');
        if (response.status === 204 || response.status === 205 || !isJson) {
          logger.success('Response exitoso (sin cuerpo)');
          return {};
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
      // ASP.NET Core puede serializar en PascalCase o camelCase dependiendo de la configuración
      const accessToken = response.accessToken || response.AccessToken;
      const refreshToken = response.refreshToken || response.RefreshToken;
      
      console.log('🔐 [login] Response keys:', Object.keys(response));
      console.log('🔐 [login] accessToken:', !!response.accessToken, 'AccessToken:', !!response.AccessToken);
      console.log('🔐 [login] refreshToken:', !!response.refreshToken, 'RefreshToken:', !!response.RefreshToken);
      
      if (accessToken && refreshToken) {
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
        localStorage.setItem('accessToken', accessToken);
        localStorage.setItem('refreshToken', refreshToken);
        // Mantener compatibilidad con código antiguo
        localStorage.setItem('authToken', accessToken);
        logger.debug('Tokens guardados en localStorage');
        console.log('✅ [login] Tokens guardados correctamente');
      } else {
        console.error('❌ [login] No se encontraron tokens en la respuesta:', response);
      }
      
      // Guardar userId para usar en reservas (manejar tanto PascalCase como camelCase)
      const userId = response.user?.Id || response.user?.id;
      if (userId) {
        localStorage.setItem('userId', userId);
        logger.debug('UserId guardado', { userId });
      } else {
        logger.warn('No se encontró userId en la respuesta del login', { user: response.user });
      }
      
      // Guardar nombre del usuario (manejar tanto PascalCase como camelCase)
      const firstName = response.user?.FirstName || response.user?.firstName || '';
      const lastName = response.user?.LastName || response.user?.lastName || '';
      const userName = `${firstName} ${lastName}`.trim();
      if (userName) {
        localStorage.setItem('userName', userName);
        logger.debug('Nombre de usuario guardado', { userName });
      }
      
      // Guardar roles del usuario (manejar tanto PascalCase como camelCase)
      const userRoles = response.user?.Roles || response.user?.roles;
      if (userRoles) {
        localStorage.setItem('userRoles', JSON.stringify(userRoles));
        logger.debug('Roles guardados', { roles: userRoles });
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
    logger.info('[REGISTER] Iniciando registro', {
      emailPreview: userData.email ? userData.email.substring(0, 5) + '***' : '(vacío)',
      hasFirstName: !!userData.firstName?.trim(),
      hasLastName: !!userData.lastName?.trim(),
      hasPassword: !!userData.password,
      hasConfirmPassword: !!userData.confirmPassword
    });

    // Asegurar que confirmPassword esté incluido
    const registerData = {
      email: userData.email?.trim(),
      password: userData.password?.trim(),
      confirmPassword: userData.confirmPassword?.trim() || userData.password?.trim(),
      firstName: userData.firstName?.trim(),
      lastName: userData.lastName?.trim()
    };

    logger.info('[REGISTER] Payload a enviar', {
      email: registerData.email ? registerData.email.substring(0, 5) + '***' : '(vacío)',
      firstNameLen: registerData.firstName?.length ?? 0,
      lastNameLen: registerData.lastName?.length ?? 0,
      passwordLen: registerData.password?.length ?? 0,
      confirmPasswordLen: registerData.confirmPassword?.length ?? 0
    });

    try {
      const response = await this.request('/api/auth/register', {
        method: 'POST',
        body: JSON.stringify(registerData),
      });

      logger.success('[REGISTER] Respuesta 201 recibida', {
        userId: response.user?.id || response.user?.Id,
        hasAccessToken: !!(response.accessToken || response.AccessToken),
        redirectUrl: response.redirectUrl || response.RedirectUrl
      });
      
      // Guardar accessToken y refreshToken
      if (response.accessToken && response.refreshToken) {
        this.accessToken = response.accessToken;
        this.refreshToken = response.refreshToken;
        localStorage.setItem('accessToken', response.accessToken);
        localStorage.setItem('refreshToken', response.refreshToken);
        localStorage.setItem('authToken', response.accessToken); // Compatibilidad
        logger.debug('Tokens guardados en localStorage');
      }
      
      // Guardar userId para usar en reservas (manejar tanto PascalCase como camelCase)
      const userId = response.user?.Id || response.user?.id;
      if (userId) {
        localStorage.setItem('userId', userId);
        logger.debug('UserId guardado', { userId });
      } else {
        logger.warn('No se encontró userId en la respuesta del registro', { user: response.user });
      }
      
      // Guardar nombre del usuario (manejar tanto PascalCase como camelCase)
      const firstName = response.user?.FirstName || response.user?.firstName || '';
      const lastName = response.user?.LastName || response.user?.lastName || '';
      const userName = `${firstName} ${lastName}`.trim();
      if (userName) {
        localStorage.setItem('userName', userName);
        logger.debug('Nombre de usuario guardado', { userName });
      }
      
      // Guardar roles del usuario (manejar tanto PascalCase como camelCase)
      const userRoles = response.user?.Roles || response.user?.roles;
      if (userRoles) {
        localStorage.setItem('userRoles', JSON.stringify(userRoles));
        logger.debug('Roles guardados', { roles: userRoles });
      }
      
      return response;
    } catch (error) {
      logger.error('[REGISTER] Error en registro', error, {
        status: error.status ?? error.statusCode,
        message: error.message,
        hasErrors: !!(error.errors || error.response?.errors)
      });
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
    localStorage.removeItem('userName'); // Limpiar nombre del usuario
    logger.debug('Tokens eliminados de localStorage');
  }

  // Obtener información del usuario actual
  async getCurrentUser() {
    return this.request('/api/auth/me');
  }

  // Actualizar perfil del usuario
  async updateProfile(profileData) {
    return this.request('/api/users/me', {
      method: 'PUT',
      body: JSON.stringify(profileData),
    });
  }

  // Cambiar contraseña
  async changePassword(currentPassword, newPassword, confirmPassword) {
    return this.request('/api/auth/change-password', {
      method: 'POST',
      body: JSON.stringify({ currentPassword, newPassword, confirmPassword }),
    });
  }

  // Obtener historial de logins
  async getLoginHistory(limit = 20) {
    return this.request(`/api/auth/login-history?limit=${limit}`);
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

  // Invoices
  async getMyInvoices() {
    return this.request('/api/invoices/my');
  }

  async downloadInvoicePdf(invoiceId) {
    const token = this.accessToken || localStorage.getItem('accessToken');
    const url = `${this.baseUrl}/api/invoices/${invoiceId}/pdf`;
    
    try {
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      });

      if (!response.ok) {
        if (response.status === 401) {
          await this.refreshAccessToken();
          return this.downloadInvoicePdf(invoiceId);
        }
        throw new Error(`Error ${response.status}: ${response.statusText}`);
      }

      const blob = await response.blob();
      return blob;
    } catch (error) {
      logger.error('Error descargando PDF de factura', error);
      throw error;
    }
  }

  async getBooking(bookingId) {
    return this.request(`/api/bookings/${bookingId}`);
  }

  async updateBookingParticipants(bookingId, participants) {
    return this.request(`/api/bookings/${bookingId}`, {
      method: 'PUT',
      body: JSON.stringify({
        participants: participants
      })
    });
  }

  async updateBooking(bookingId, bookingData) {
    return this.request(`/api/bookings/${bookingId}`, {
      method: 'PUT',
      body: JSON.stringify(bookingData),
    });
  }

  async cancelBooking(bookingId) {
    return this.request(`/api/bookings/${bookingId}/cancel`, {
      method: 'POST',
    });
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
    // 🔍 LOG DE PROTECCIÓN: Validar bookingId antes de enviar
    if (!bookingId) {
      const error = new Error('bookingId es requerido para crear un pago');
      logger.error('Error en createPayment: bookingId faltante', error);
      throw error;
    }
    
    console.log('💳 [createPayment] Creando pago:', {
      bookingId,
      bookingIdType: typeof bookingId,
      currency,
      provider
    });
    
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
    
    console.log('💳 [createPayment] Payload a enviar:', requestBody);
    
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
    return this.request(`/api/admin/users?${params}`);
  }

  // ========== CUPONES (Admin) ==========
  async getCoupons(isActive = null, page = 1, pageSize = 50) {
    const params = new URLSearchParams({ page, pageSize });
    if (isActive !== null) params.append('isActive', isActive);
    return this.request(`/api/coupons?${params}`);
  }

  // ========== WAITLIST (Admin) ==========
  async getWaitlist(tourId = null, isActive = null) {
    const params = new URLSearchParams();
    if (tourId) params.append('tourId', tourId);
    if (isActive !== null) params.append('isActive', isActive);
    return this.request(`/api/waitlist?${params}`);
  }

  // ========== REVIEWS (Admin) ==========
  async getAllReviews(page = 1, pageSize = 50, isApproved = null, tourId = null) {
    const params = new URLSearchParams({ page, pageSize });
    if (isApproved !== null) params.append('isApproved', isApproved);
    if (tourId) params.append('tourId', tourId);
    // Usar la ruta admin que no requiere tourId en la ruta
    return this.request(`/api/admin/reviews?${params}`);
  }

  async approveReview(reviewId, tourId) {
    return this.request(`/api/tours/${tourId}/reviews/${reviewId}/approve`, { method: 'POST' });
  }

  async rejectReview(reviewId, tourId) {
    return this.request(`/api/tours/${tourId}/reviews/${reviewId}/reject`, { method: 'POST' });
  }

  // Admin Users (método completo)
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

  async createAdminUser(data) {
    return this.request('/api/admin/users', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async deleteAdminUser(userId) {
    return this.request(`/api/admin/users/${userId}`, {
      method: 'DELETE',
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

  // Admin CMS
  async getAdminHomePageContent() {
    return this.request('/api/admin/homepage-content');
  }

  async updateAdminHomePageContent(contentData) {
    return this.request('/api/admin/homepage-content', {
      method: 'PUT',
      body: JSON.stringify(contentData),
    });
  }

  async getAdminEmailSettings() {
    return this.request('/api/admin/email-settings');
  }

  async updateAdminEmailSettings(data) {
    return this.request('/api/admin/email-settings', {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async getAdminChatbotSettings() {
    return this.request('/api/admin/chatbot-settings');
  }

  async updateAdminChatbotSettings(data) {
    return this.request('/api/admin/chatbot-settings', {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async testChatbotConnection() {
    return this.request('/api/admin/chatbot-settings/test', {
      method: 'POST',
    });
  }

  // Admin Media
  async getAdminMedia(category = null, isImage = null, page = 1, pageSize = 50) {
    const params = new URLSearchParams();
    if (category) params.append('category', category);
    if (isImage !== null) params.append('isImage', isImage);
    params.append('page', page);
    params.append('pageSize', pageSize);
    return this.request(`/api/admin/media?${params.toString()}`);
  }

  async uploadMediaFile(file, altText = null, description = null, category = null) {
    const formData = new FormData();
    formData.append('file', file);
    if (altText) formData.append('altText', altText);
    if (description) formData.append('description', description);
    if (category) formData.append('category', category);
    
    return this.request('/api/admin/media', {
      method: 'POST',
      body: formData,
      // No incluir Content-Type, el navegador lo hace automáticamente para FormData
      headers: {}
    });
  }

  async deleteMediaFile(mediaId) {
    return this.request(`/api/admin/media/${mediaId}`, {
      method: 'DELETE',
    });
  }

  // 2FA (Two Factor Authentication)
  async enable2FA() {
    return this.request('/api/auth/2fa/enable', { method: 'POST' });
  }

  async verify2FA(code) {
    return this.request('/api/auth/2fa/verify', {
      method: 'POST',
      body: JSON.stringify({ code }),
    });
  }

  async verifyLogin2FA(email, code, backupCode = null) {
    return this.request('/api/auth/2fa/verify-login', {
      method: 'POST',
      body: JSON.stringify({ email, code, backupCode }),
    });
  }

  async disable2FA(code, backupCode = null) {
    return this.request('/api/auth/2fa/disable', {
      method: 'POST',
      body: JSON.stringify({ code, backupCode }),
    });
  }

  async get2FAStatus() {
    return this.request('/api/auth/2fa/status');
  }

  // Email Verification
  async sendVerificationEmail() {
    return this.request('/api/auth/email-verification/send', { method: 'POST' });
  }

  async verifyEmail(token) {
    return this.request('/api/auth/email-verification/verify', {
      method: 'POST',
      body: JSON.stringify({ token }),
    });
  }

  async getEmailVerificationStatus() {
    return this.request('/api/auth/email-verification/status');
  }

  // Sessions
  async getSessions() {
    return this.request('/api/auth/sessions');
  }

  async closeSession(tokenId) {
    return this.request(`/api/auth/sessions/${tokenId}`, { method: 'DELETE' });
  }

  async closeAllOtherSessions() {
    return this.request('/api/auth/sessions/close-all-others', { method: 'POST' });
  }

  // Reviews
  async getTourReviews(tourId, page = 1, pageSize = 10, minRating = null) {
    const params = new URLSearchParams();
    params.append('page', page);
    params.append('pageSize', pageSize);
    if (minRating) params.append('minRating', minRating);
    return this.request(`/api/tours/${tourId}/reviews?${params.toString()}`);
  }

  async createReview(tourId, rating, title = null, comment = null) {
    return this.request(`/api/tours/${tourId}/reviews`, {
      method: 'POST',
      body: JSON.stringify({ rating, title, comment }),
    });
  }

  async deleteReview(tourId, reviewId) {
    return this.request(`/api/tours/${tourId}/reviews/${reviewId}`, { method: 'DELETE' });
  }

  // Coupons
  async validateCoupon(code, purchaseAmount, tourId = null) {
    return this.request('/api/coupons/validate', {
      method: 'POST',
      body: JSON.stringify({ code, purchaseAmount, tourId }),
    });
  }

  // Wishlist/Favorites
  async addToFavorites(tourId) {
    return this.request(`/api/tours/${tourId}/favorite`, { method: 'POST' });
  }

  async removeFromFavorites(tourId) {
    return this.request(`/api/tours/${tourId}/favorite`, { method: 'DELETE' });
  }

  async getFavorites() {
    return this.request('/api/tours/favorites');
  }

  async checkFavorite(tourId) {
    return this.request(`/api/tours/${tourId}/favorite/check`);
  }

  // Waitlist
  async addToWaitlist(tourId, tourDateId = null, numberOfParticipants = 1) {
    return this.request('/api/waitlist', {
      method: 'POST',
      body: JSON.stringify({ tourId, tourDateId, numberOfParticipants }),
    });
  }

  async getMyWaitlist() {
    return this.request('/api/waitlist/my');
  }

  async removeFromWaitlist(waitlistId) {
    return this.request(`/api/waitlist/${waitlistId}`, { method: 'DELETE' });
  }

  // Advanced Search
  async searchTours(query = '', filters = {}, page = 1, pageSize = 20) {
    const params = new URLSearchParams();
    if (query) params.append('q', query);
    if (filters.minPrice !== null && filters.minPrice !== undefined) params.append('minPrice', filters.minPrice);
    if (filters.maxPrice !== null && filters.maxPrice !== undefined) params.append('maxPrice', filters.maxPrice);
    if (filters.minDuration !== null && filters.minDuration !== undefined) params.append('minDuration', filters.minDuration);
    if (filters.maxDuration !== null && filters.maxDuration !== undefined) params.append('maxDuration', filters.maxDuration);
    if (filters.location) params.append('location', filters.location);
    if (filters.sortBy) params.append('sortBy', filters.sortBy);
    if (filters.sortOrder) params.append('sortOrder', filters.sortOrder);
    params.append('page', page);
    params.append('pageSize', pageSize);
    const response = await this.request(`/api/tours/search?${params.toString()}`);
    // El backend puede retornar { tours: [...], totalCount: ... } o directamente un array
    return response.tours ? response : { tours: response, totalCount: response.length };
  }

  async getRelatedTours(tourId, limit = 4) {
    return this.request(`/api/tours/${tourId}/related?limit=${limit}`);
  }

  async getFeaturedTours(limit = 6) {
    return this.request(`/api/tours/featured?limit=${limit}`);
  }

  // ========== BLOG ==========
  
  /**
   * Obtiene posts de blog
   */
  async getBlogPosts(page = 1, pageSize = 10, search = null) {
    const params = new URLSearchParams({ page, pageSize });
    if (search) params.append('search', search);
    return this.request(`/api/blog?${params}`);
  }

  /**
   * Obtiene un post de blog por slug
   */
  async getBlogPost(slug) {
    return this.request(`/api/blog/${slug}`);
  }

  /**
   * Obtiene posts recientes
   */
  async getRecentBlogPosts(limit = 5) {
    return this.request(`/api/blog/recent?limit=${limit}`);
  }

  // ========== COMENTARIOS DE BLOG ==========
  
  /**
   * Obtiene comentarios de un post de blog
   */
  async getBlogComments(blogPostId, page = 1, pageSize = 20, parentCommentId = null) {
    const params = new URLSearchParams({ page, pageSize });
    if (parentCommentId) params.append('parentCommentId', parentCommentId);
    return this.request(`/api/blog/comments/post/${blogPostId}?${params}`);
  }

  /**
   * Crea un comentario en un post de blog
   */
  async createBlogComment(commentData) {
    return this.request('/api/blog/comments', {
      method: 'POST',
      body: JSON.stringify(commentData)
    });
  }

  /**
   * Actualiza un comentario de blog
   */
  async updateBlogComment(commentId, commentData) {
    return this.request(`/api/blog/comments/${commentId}`, {
      method: 'PUT',
      body: JSON.stringify(commentData)
    });
  }

  /**
   * Elimina un comentario de blog
   */
  async deleteBlogComment(commentId) {
    return this.request(`/api/blog/comments/${commentId}`, {
      method: 'DELETE'
    });
  }

  /**
   * Like/Dislike un comentario
   */
  async likeBlogComment(commentId, isLike = true) {
    return this.request(`/api/blog/comments/${commentId}/like`, {
      method: 'POST',
      body: JSON.stringify({ isLike })
    });
  }

  /**
   * Obtiene todos los comentarios (Admin)
   */
  async getAllBlogComments(page = 1, pageSize = 50, status = null, blogPostId = null) {
    const params = new URLSearchParams({ page, pageSize });
    if (status !== null) params.append('status', status);
    if (blogPostId) params.append('blogPostId', blogPostId);
    return this.request(`/api/blog/comments/admin?${params}`);
  }

  /**
   * Modera un comentario (Admin)
   */
  async moderateBlogComment(commentId, status, adminNotes = null) {
    return this.request(`/api/blog/comments/${commentId}/moderate`, {
      method: 'POST',
      body: JSON.stringify({ status, adminNotes })
    });
  }

  // ========== BLOG ==========
  
  /**
   * Obtiene posts de blog
   */
  async getBlogPosts(page = 1, pageSize = 10, search = null) {
    const params = new URLSearchParams({ page, pageSize });
    if (search) params.append('search', search);
    return this.request(`/api/blog?${params}`);
  }

  /**
   * Obtiene un post de blog por slug
   */
  async getBlogPost(slug) {
    return this.request(`/api/blog/${slug}`);
  }

  /**
   * Obtiene posts recientes
   */
  async getRecentBlogPosts(limit = 5) {
    return this.request(`/api/blog/recent?limit=${limit}`);
  }

  // ========== COMENTARIOS DE BLOG ==========
  
  /**
   * Obtiene comentarios de un post de blog
   */
  async getBlogComments(blogPostId, page = 1, pageSize = 20, parentCommentId = null) {
    const params = new URLSearchParams({ page, pageSize });
    if (parentCommentId) params.append('parentCommentId', parentCommentId);
    return this.request(`/api/blog/comments/post/${blogPostId}?${params}`);
  }

  /**
   * Crea un comentario en un post de blog
   */
  async createBlogComment(commentData) {
    return this.request('/api/blog/comments', {
      method: 'POST',
      body: JSON.stringify(commentData)
    });
  }

  /**
   * Actualiza un comentario de blog
   */
  async updateBlogComment(commentId, commentData) {
    return this.request(`/api/blog/comments/${commentId}`, {
      method: 'PUT',
      body: JSON.stringify(commentData)
    });
  }

  /**
   * Elimina un comentario de blog
   */
  async deleteBlogComment(commentId) {
    return this.request(`/api/blog/comments/${commentId}`, {
      method: 'DELETE'
    });
  }

  /**
   * Like/Dislike un comentario
   */
  async likeBlogComment(commentId, isLike = true) {
    return this.request(`/api/blog/comments/${commentId}/like`, {
      method: 'POST',
      body: JSON.stringify({ isLike })
    });
  }

  /**
   * Obtiene todos los comentarios (Admin)
   */
  async getAllBlogComments(page = 1, pageSize = 50, status = null, blogPostId = null) {
    const params = new URLSearchParams({ page, pageSize });
    if (status !== null) params.append('status', status);
    if (blogPostId) params.append('blogPostId', blogPostId);
    return this.request(`/api/blog/comments/admin?${params}`);
  }

  /**
   * Modera un comentario (Admin)
   */
  async moderateBlogComment(commentId, status, adminNotes = null) {
    return this.request(`/api/blog/comments/${commentId}/moderate`, {
      method: 'POST',
      body: JSON.stringify({ status, adminNotes })
    });
  }

  // ========== REPORTES (Admin) ==========
  async getReportsSummary(startDate = null, endDate = null) {
    const params = new URLSearchParams();
    if (startDate) params.append('startDate', startDate);
    if (endDate) params.append('endDate', endDate);
    return this.request(`/api/admin/reports/summary?${params.toString()}`);
  }

  async getToursReport(startDate = null, endDate = null, limit = 10) {
    const params = new URLSearchParams();
    if (startDate) params.append('startDate', startDate);
    if (endDate) params.append('endDate', endDate);
    params.append('limit', limit);
    return this.request(`/api/admin/reports/tours?${params.toString()}`);
  }

  async getTimeseriesReport(startDate = null, endDate = null, groupBy = 'day') {
    const params = new URLSearchParams();
    if (startDate) params.append('startDate', startDate);
    if (endDate) params.append('endDate', endDate);
    params.append('groupBy', groupBy);
    return this.request(`/api/admin/reports/timeseries?${params.toString()}`);
  }

  async getCustomersReport(startDate = null, endDate = null, limit = 10) {
    const params = new URLSearchParams();
    if (startDate) params.append('startDate', startDate);
    if (endDate) params.append('endDate', endDate);
    params.append('limit', limit);
    return this.request(`/api/admin/reports/customers?${params.toString()}`);
  }

  // Admin Pages
  async getAdminPages(isPublished = null, page = 1, pageSize = 50) {
    const params = new URLSearchParams();
    if (isPublished !== null) params.append('isPublished', isPublished);
    params.append('page', page);
    params.append('pageSize', pageSize);
    return this.request(`/api/admin/pages?${params.toString()}`);
  }

  async getAdminPage(pageId) {
    return this.request(`/api/admin/pages/${pageId}`);
  }

  async createPage(pageData) {
    return this.request('/api/admin/pages', {
      method: 'POST',
      body: JSON.stringify(pageData),
    });
  }

  async updatePage(pageId, pageData) {
    return this.request(`/api/admin/pages/${pageId}`, {
      method: 'PUT',
      body: JSON.stringify(pageData),
    });
  }

  async deletePage(pageId) {
    return this.request(`/api/admin/pages/${pageId}`, {
      method: 'DELETE',
    });
  }

  // Admin Tour Images
  async uploadTourImage(file) {
    const formData = new FormData();
    formData.append('file', file);
    
    return this.request('/api/admin/upload-image', {
      method: 'POST',
      body: formData,
      headers: {}
    });
  }

  async getAdminTour(tourId) {
    return this.request(`/api/admin/tours/${tourId}`);
  }

  // Admin Tour Dates
  async getAdminTourDates(tourId) {
    return this.request(`/api/admin/tours/${tourId}/dates`);
  }

  async createTourDate(tourId, dateData) {
    return this.request(`/api/admin/tours/${tourId}/dates`, {
      method: 'POST',
      body: JSON.stringify(dateData),
    });
  }

  async updateTourDate(dateId, dateData) {
    return this.request(`/api/admin/tours/dates/${dateId}`, {
      method: 'PUT',
      body: JSON.stringify(dateData),
    });
  }

  async deleteTourDate(dateId) {
    return this.request(`/api/admin/tours/dates/${dateId}`, {
      method: 'DELETE',
    });
  }

  // Analytics
  async trackEvent(event, data = {}) {
    try {
      // Obtener o crear sessionId
      let sessionId = localStorage.getItem('analytics_session_id');
      if (!sessionId) {
        sessionId = this.generateUUID();
        localStorage.setItem('analytics_session_id', sessionId);
      }

      const payload = {
        event,
        entityType: data.entityType,
        entityId: data.entityId,
        sessionId: sessionId,
        metadata: data.metadata || {},
        country: data.country,
        city: data.city
      };

      // Enviar de forma asíncrona (no bloquear UI)
      this.request('/api/analytics', {
        method: 'POST',
        body: JSON.stringify(payload),
      }).catch(err => {
        // Silenciar errores de analytics para no afectar UX
        logger.debug('Error en analytics (silenciado):', err);
      });

      return true;
    } catch (error) {
      // No fallar si analytics falla
      logger.debug('Error tracking event:', error);
      return false;
    }
  }

  generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = Math.random() * 16 | 0;
      const v = c === 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }

  // Analytics
  async getAnalyticsMetrics(startDate = null, endDate = null, tourId = null) {
    const params = new URLSearchParams();
    if (startDate) params.append('startDate', startDate);
    if (endDate) params.append('endDate', endDate);
    if (tourId) params.append('tourId', tourId);
    
    return this.request(`/api/analytics/metrics?${params.toString()}`);
  }

  async getAnalyticsFunnel(startDate = null, endDate = null) {
    const params = new URLSearchParams();
    if (startDate) params.append('startDate', startDate);
    if (endDate) params.append('endDate', endDate);
    
    return this.request(`/api/analytics/funnel?${params.toString()}`);
  }

  async getTopTours(startDate = null, endDate = null, limit = 10) {
    const params = new URLSearchParams();
    if (startDate) params.append('startDate', startDate);
    if (endDate) params.append('endDate', endDate);
    params.append('limit', limit.toString());
    
    return this.request(`/api/analytics/top-tours?${params.toString()}`);
  }

  async getUxImpact(startDate = null, endDate = null) {
    const params = new URLSearchParams();
    if (startDate) params.append('startDate', startDate);
    if (endDate) params.append('endDate', endDate);
    
    return this.request(`/api/analytics/ux-impact?${params.toString()}`);
  }

  // Blog
  async getBlogPosts({ page = 1, pageSize = 10, search = null } = {}) {
    const params = new URLSearchParams();
    if (page) params.append('page', page.toString());
    if (pageSize) params.append('pageSize', pageSize.toString());
    if (search) params.append('search', search);
    
    return this.request(`/api/blog?${params.toString()}`);
  }

  async getBlogPostBySlug(slug) {
    return this.request(`/api/blog/${slug}`);
  }

  async getBlogComments(postId, { page = 1, pageSize = 20, parentCommentId = null } = {}) {
    const params = new URLSearchParams();
    if (page) params.append('page', page.toString());
    if (pageSize) params.append('pageSize', pageSize.toString());
    if (parentCommentId) params.append('parentCommentId', parentCommentId);
    
    return this.request(`/api/blog/comments/post/${postId}?${params.toString()}`);
  }

  async createBlogComment(payload) {
    return this.request('/api/blog/comments', {
      method: 'POST',
      body: JSON.stringify(payload),
    });
  }

  async reactToComment(commentId, isLike) {
    return this.request(`/api/blog/comments/${commentId}/like`, {
      method: 'POST',
      body: JSON.stringify({ isLike }),
    });
  }
}

// Export singleton instance
const api = new ApiClient();

// Función global de tracking (vendor-agnostic)
window.track = function(event, data = {}) {
  return api.trackEvent(event, data);
};
