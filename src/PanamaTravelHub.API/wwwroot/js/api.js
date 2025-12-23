// API Client para ToursPanama
const API_BASE_URL = window.location.origin;

class ApiClient {
  constructor() {
    this.baseUrl = API_BASE_URL;
    this.token = localStorage.getItem('authToken');
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

      if (this.token) {
        config.headers['Authorization'] = `Bearer ${this.token}`;
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
      
      if (response.token) {
        this.token = response.token;
        localStorage.setItem('authToken', response.token);
        console.log('💾 Token guardado en localStorage');
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
      }
      
      return response;
    } catch (error) {
      console.error('❌ Error en login:', error);
      throw error;
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
    
    if (response.token) {
      this.token = response.token;
      localStorage.setItem('authToken', response.token);
      console.log('💾 Token guardado en localStorage');
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
    }
    
    return response;
  }

  logout() {
    this.token = null;
    localStorage.removeItem('authToken');
    localStorage.removeItem('userId');
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
