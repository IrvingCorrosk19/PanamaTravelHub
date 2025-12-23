// API Client para ToursPanama
const API_BASE_URL = window.location.origin;

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
      console.log('🌐 API Request:', {
        method: options.method || 'GET',
        url: url,
        hasBody: !!options.body,
        hasToken: !!this.token
      });

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
      }

      try {
        console.log('📤 Enviando request...');
        const response = await fetch(url, config);
        console.log('📥 Response recibido:', {
          status: response.status,
          statusText: response.statusText,
          ok: response.ok,
          headers: Object.fromEntries(response.headers.entries())
        });
        
        if (!response.ok) {
          // Si es 401 (Unauthorized), intentar refresh token
          if (response.status === 401 && this.refreshToken && !endpoint.includes('/api/auth/refresh') && !endpoint.includes('/api/auth/login')) {
            console.log('🔄 Token expirado, intentando refresh...');
            const refreshed = await this.refreshAccessToken();
            if (refreshed) {
              // Reintentar request con nuevo token
              config.headers['Authorization'] = `Bearer ${this.accessToken}`;
              const retryResponse = await fetch(url, config);
              if (retryResponse.ok) {
                const data = await retryResponse.json();
                console.log('✅ Request exitoso después de refresh');
                return data;
              }
            }
          }

          console.error('❌ Response no OK. Status:', response.status);
          const error = await response.json().catch((parseError) => {
            console.error('❌ Error al parsear JSON del error:', parseError);
            return { 
              title: 'Error desconocido',
              detail: 'Ocurrió un error al procesar la solicitud',
              status: response.status
            };
          });
          
          console.error('❌ Error completo:', error);
          
          // Manejar errores de validación (ProblemDetails)
          if (error.errors && typeof error.errors === 'object') {
            // FluentValidation devuelve errores en formato { "PropertyName": ["Error1", "Error2"] }
            const validationErrors = Object.values(error.errors)
              .flat()
              .filter(err => typeof err === 'string');
            
            if (validationErrors.length > 0) {
              console.error('❌ Errores de validación:', validationErrors);
              throw new Error(validationErrors.join('. '));
            }
          }
          
          // Manejar otros errores
          const errorMessage = error.detail || error.message || error.title || `Error ${response.status}`;
          console.error('❌ Error message:', errorMessage);
          console.error('❌ Error traceId:', error.traceId);
          throw new Error(errorMessage);
        }

        const data = await response.json();
        console.log('✅ Response exitoso:', data);
        return data;
      } catch (error) {
        console.error('❌ API Error completo:', {
          message: error.message,
          stack: error.stack,
          name: error.name
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
    console.log('🔐 Iniciando login:', { email, passwordLength: password?.length });
    try {
      const response = await this.request('/api/auth/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
      });
      console.log('✅ Login exitoso:', response);
      
      // Guardar accessToken y refreshToken
      if (response.accessToken && response.refreshToken) {
        this.accessToken = response.accessToken;
        this.refreshToken = response.refreshToken;
        localStorage.setItem('accessToken', response.accessToken);
        localStorage.setItem('refreshToken', response.refreshToken);
        // Mantener compatibilidad con código antiguo
        localStorage.setItem('authToken', response.accessToken);
        console.log('💾 Tokens guardados en localStorage');
      }
      
      // Guardar userId para usar en reservas
      if (response.user && response.user.id) {
        localStorage.setItem('userId', response.user.id);
        console.log('💾 UserId guardado:', response.user.id);
      }
      
      // Guardar roles del usuario
      if (response.user && response.user.roles) {
        localStorage.setItem('userRoles', JSON.stringify(response.user.roles));
        console.log('💾 Roles guardados:', response.user.roles);
      }
      
      return response;
    } catch (error) {
      console.error('❌ Error en login:', error);
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
      console.log('❌ No hay refresh token disponible');
      this.isRefreshing = false;
      this.handleAuthFailure();
      return false;
    }

    try {
      console.log('🔄 Refrescando access token...');
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
        console.log('✅ Access token refrescado exitosamente');
        
        // Resolver todas las peticiones en cola
        this.failedQueue.forEach(resolve => resolve(true));
        this.failedQueue = [];
        this.isRefreshing = false;
        
        return true;
      }

      throw new Error('No se recibieron tokens en la respuesta');
    } catch (error) {
      console.error('❌ Error al refrescar token:', error);
      this.isRefreshing = false;
      this.failedQueue.forEach(resolve => resolve(false));
      this.failedQueue = [];
      this.handleAuthFailure();
      return false;
    }
  }

  // Manejar fallo de autenticación
  handleAuthFailure() {
    console.log('🚪 Sesión expirada, cerrando sesión...');
    this.logout();
    // Redirigir a login si no estamos ya ahí
    if (!window.location.pathname.includes('login.html')) {
      window.location.href = '/login.html';
    }
  }

  async register(userData) {
    // Asegurar que confirmPassword esté incluido
    const registerData = {
      email: userData.email?.trim(),
      password: userData.password?.trim(),
      confirmPassword: userData.confirmPassword?.trim() || userData.password?.trim(),
      firstName: userData.firstName?.trim(),
      lastName: userData.lastName?.trim()
    };

    const response = await this.request('/api/auth/register', {
      method: 'POST',
      body: JSON.stringify(registerData),
    });
    
    // Guardar accessToken y refreshToken
    if (response.accessToken && response.refreshToken) {
      this.accessToken = response.accessToken;
      this.refreshToken = response.refreshToken;
      localStorage.setItem('accessToken', response.accessToken);
      localStorage.setItem('refreshToken', response.refreshToken);
      localStorage.setItem('authToken', response.accessToken); // Compatibilidad
      console.log('💾 Tokens guardados en localStorage');
    }
    
    // Guardar userId para usar en reservas
    if (response.user && response.user.id) {
      localStorage.setItem('userId', response.user.id);
      console.log('💾 UserId guardado:', response.user.id);
    }
    
    // Guardar roles del usuario
    if (response.user && response.user.roles) {
      localStorage.setItem('userRoles', JSON.stringify(response.user.roles));
      console.log('💾 Roles guardados:', response.user.roles);
    }
    
    return response;
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
        console.log('✅ Logout exitoso, refresh token revocado');
      } catch (error) {
        console.error('⚠️ Error al revocar refresh token:', error);
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
    console.log('💾 Tokens eliminados de localStorage');
  }

  // Obtener información del usuario actual
  async getCurrentUser() {
    return this.request('/api/auth/me');
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
