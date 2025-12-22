// API Client para ToursPanama
const API_BASE_URL = window.location.origin;

class ApiClient {
  constructor() {
    this.baseUrl = API_BASE_URL;
    this.token = localStorage.getItem('authToken');
  }

  async request(endpoint, options = {}) {
    const url = `${this.baseUrl}${endpoint}`;
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
      const response = await fetch(url, config);
      
      if (!response.ok) {
        const error = await response.json().catch(() => ({ message: 'Error desconocido' }));
        throw new Error(error.message || `Error ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error('API Error:', error);
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
    const response = await this.request('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
    
    if (response.token) {
      this.token = response.token;
      localStorage.setItem('authToken', response.token);
    }
    
    return response;
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
    }
    
    return response;
  }

  logout() {
    this.token = null;
    localStorage.removeItem('authToken');
  }

  // Bookings
  async getMyBookings() {
    return this.request('/api/bookings/my');
  }

  async createBooking(bookingData) {
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
}

// Export singleton instance
const api = new ApiClient();
