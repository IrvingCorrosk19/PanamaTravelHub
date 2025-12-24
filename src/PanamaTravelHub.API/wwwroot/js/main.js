// Main JavaScript para ToursPanama

// Check authentication on load
document.addEventListener('DOMContentLoaded', () => {
  checkAuth();
  loadHomePageContent();
  loadTours();
  initScrollEffects();
  initNavbarScroll();
});

// Load Homepage Content
async function loadHomePageContent() {
  try {
    const content = await api.getHomePageContent();
    
    // Actualizar navegación
    const navBrandText = document.getElementById('navBrandText');
    if (navBrandText) navBrandText.textContent = content.navBrandText || 'ToursPanama';
    
    const navToursLink = document.getElementById('navToursLink');
    if (navToursLink) navToursLink.textContent = content.navToursLink || 'Tours';
    
    const navBookingsLink = document.getElementById('navBookingsLink');
    if (navBookingsLink) navBookingsLink.textContent = content.navBookingsLink || 'Mis Reservas';
    
    const loginLink = document.getElementById('loginLink');
    if (loginLink) loginLink.textContent = content.navLoginLink || 'Iniciar Sesión';
    
    const logoutBtn = document.getElementById('logoutBtn');
    if (logoutBtn) logoutBtn.textContent = content.navLogoutButton || 'Cerrar Sesión';
    
    // Actualizar hero section
    const heroTitle = document.getElementById('heroTitle');
    if (heroTitle) heroTitle.textContent = content.heroTitle || 'Descubre Panamá';
    
    const heroSubtitle = document.getElementById('heroSubtitle');
    if (heroSubtitle) heroSubtitle.textContent = content.heroSubtitle || 'Explora los destinos más increíbles con nuestros tours exclusivos';
    
    const searchInput = document.getElementById('searchInput');
    if (searchInput) searchInput.placeholder = content.heroSearchPlaceholder || 'Buscar tours...';
    
    const searchButton = document.getElementById('searchButton');
    if (searchButton) searchButton.textContent = content.heroSearchButton || 'Buscar';
    
    // Actualizar título y meta description
    const pageTitle = document.getElementById('pageTitle');
    if (pageTitle) pageTitle.textContent = content.pageTitle || 'ToursPanama — Descubre los Mejores Tours en Panamá';
    
    const metaDescription = document.getElementById('metaDescription');
    if (metaDescription) metaDescription.setAttribute('content', content.metaDescription || 'Plataforma moderna de reservas de tours en Panamá. Explora, reserva y disfruta de las mejores experiencias turísticas.');
    
    // Actualizar sección de tours
    const toursSectionTitle = document.getElementById('toursSectionTitle');
    if (toursSectionTitle) toursSectionTitle.textContent = content.toursSectionTitle || 'Tours Disponibles';
    
    const toursSectionSubtitle = document.getElementById('toursSectionSubtitle');
    if (toursSectionSubtitle) toursSectionSubtitle.textContent = content.toursSectionSubtitle || 'Selecciona tu próxima aventura';
    
    const loadingToursText = document.getElementById('loadingToursText');
    if (loadingToursText) loadingToursText.textContent = content.loadingToursText || 'Cargando tours...';
    
    const errorLoadingToursText = document.getElementById('errorLoadingToursText');
    if (errorLoadingToursText) errorLoadingToursText.textContent = content.errorLoadingToursText || 'Error al cargar los tours. Por favor, intenta de nuevo.';
    
    const noToursFoundText = document.getElementById('noToursFoundText');
    if (noToursFoundText) noToursFoundText.textContent = content.noToursFoundText || 'No se encontraron tours disponibles.';
    
    // Actualizar footer
    const footerBrandText = document.getElementById('footerBrandText');
    if (footerBrandText) footerBrandText.textContent = content.footerBrandText || 'ToursPanama';
    
    const footerDescription = document.getElementById('footerDescription');
    if (footerDescription) footerDescription.textContent = content.footerDescription || 'Tu plataforma de confianza para descubrir Panamá';
    
    const footerCopyright = document.getElementById('footerCopyright');
    if (footerCopyright) footerCopyright.textContent = content.footerCopyright || '© 2024 ToursPanama. Todos los derechos reservados.';
  } catch (error) {
    console.error('Error loading homepage content:', error);
    // Si falla, usar valores por defecto (ya están en el HTML)
  }
}

// Authentication
function checkAuth() {
  const accessToken = localStorage.getItem('accessToken') || localStorage.getItem('authToken');
  const userRoles = JSON.parse(localStorage.getItem('userRoles') || '[]');
  const isAdmin = userRoles.includes('Admin') || userRoles.includes('admin');
  const loginLink = document.getElementById('loginLink');
  const adminLink = document.getElementById('adminLink');
  const logoutBtn = document.getElementById('logoutBtn');

  if (accessToken) {
    if (loginLink) loginLink.style.display = 'none';
    if (logoutBtn) {
      logoutBtn.style.display = 'block';
      // Agregar event listener para logout
      logoutBtn.onclick = async () => {
        await api.logout();
        window.location.href = '/';
      };
    }
    
    // Si es admin, mostrar link de admin y redirigir automáticamente al panel
    if (isAdmin) {
      if (adminLink) adminLink.style.display = 'block';
      // Si estamos en la página principal y el usuario es admin, redirigir al panel
      if (window.location.pathname === '/' || window.location.pathname === '/index.html') {
        window.location.href = '/admin.html';
      }
    } else {
      if (adminLink) adminLink.style.display = 'none';
    }
  } else {
    if (loginLink) loginLink.style.display = 'block';
    if (logoutBtn) logoutBtn.style.display = 'none';
    if (adminLink) adminLink.style.display = 'none';
  }
}

// Load Tours
async function loadTours() {
  const loadingState = document.getElementById('loadingState');
  const errorState = document.getElementById('errorState');
  const emptyState = document.getElementById('emptyState');
  const toursGrid = document.getElementById('toursGrid');

  try {
    loadingState.style.display = 'block';
    errorState.style.display = 'none';
    emptyState.style.display = 'none';
    toursGrid.innerHTML = '';

    // Mostrar loader inline en el grid
    const loaderId = loadingManager.showInline(toursGrid, 'Cargando tours...');

    // Llamar a la API real
    let tours = [];
    try {
      tours = await api.getTours();
      loadingManager.hideInline(toursGrid);
    } catch (error) {
      // Si falla la API, usar datos mock como fallback
      console.warn('API no disponible, usando datos mock:', error);
      tours = [
      {
        id: '1',
        name: 'Tour del Canal de Panamá',
        description: 'Descubre la maravilla de la ingeniería mundial. Visita las esclusas de Miraflores y aprende sobre la historia del canal.',
        price: 75.00,
        durationHours: 4,
        location: 'Ciudad de Panamá',
        availableSpots: 15,
        maxCapacity: 20,
        tourImages: [{ imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800', isPrimary: true }]
      },
      {
        id: '2',
        name: 'Casco Antiguo y Panamá Viejo',
        description: 'Recorre la historia de Panamá visitando el Casco Antiguo colonial y las ruinas de Panamá Viejo, declaradas Patrimonio de la Humanidad.',
        price: 45.00,
        durationHours: 3,
        location: 'Casco Antiguo',
        availableSpots: 8,
        maxCapacity: 15,
        tourImages: [{ imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800', isPrimary: true }]
      },
      {
        id: '3',
        name: 'Isla Taboga - Día Completo',
        description: 'Escápate a la Isla de las Flores. Disfruta de playas paradisíacas, snorkel y la tranquilidad de este paraíso tropical.',
        price: 120.00,
        durationHours: 8,
        location: 'Isla Taboga',
        availableSpots: 12,
        maxCapacity: 25,
        tourImages: [{ imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800', isPrimary: true }]
      },
      {
        id: '4',
        name: 'Tour Nocturno de la Ciudad',
        description: 'Explora la ciudad de Panamá de noche. Disfruta de la vida nocturna, restaurantes y vistas panorámicas de la ciudad iluminada.',
        price: 65.00,
        durationHours: 4,
        location: 'Ciudad de Panamá',
        availableSpots: 20,
        maxCapacity: 30,
        tourImages: [{ imageUrl: 'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=800', isPrimary: true }]
      },
      {
        id: '5',
        name: 'Rainforest Adventure - Gamboa',
        description: 'Aventura en la naturaleza. Camina por senderos del bosque tropical, observa la fauna local y disfruta de la biodiversidad panameña.',
        price: 95.00,
        durationHours: 6,
        location: 'Gamboa',
        availableSpots: 5,
        maxCapacity: 12,
        tourImages: [{ imageUrl: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800', isPrimary: true }]
      },
      {
        id: '6',
        name: 'Tour Gastronómico Panameño',
        description: 'Saborea la auténtica cocina panameña. Visita mercados locales, prueba platos tradicionales y aprende sobre la cultura culinaria.',
        price: 55.00,
        durationHours: 3,
        location: 'Ciudad de Panamá',
        availableSpots: 18,
        maxCapacity: 20,
        tourImages: [{ imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800', isPrimary: true }]
      }
      ];
    }

    loadingState.style.display = 'none';

    if (tours.length === 0) {
      emptyState.style.display = 'block';
      return;
    }

    toursGrid.innerHTML = tours.map(tour => createTourCard(tour)).join('');
    
    // Animar cards después de insertarlos
    setTimeout(() => {
      const cards = toursGrid.querySelectorAll('.tour-card');
      cards.forEach((card, index) => {
        setTimeout(() => {
          card.style.transition = 'opacity 0.6s ease-out, transform 0.6s ease-out';
          card.style.opacity = '1';
          card.style.transform = 'translateY(0)';
        }, index * 100);
      });
    }, 100);
  } catch (error) {
    if (typeof logger !== 'undefined') {
      logger.error('Error loading tours', error, { endpoint: '/api/tours' });
    } else {
      console.error('Error loading tours:', error);
    }
    loadingState.style.display = 'none';
    errorState.style.display = 'block';
    loadingManager.hideInline(toursGrid);
  }
}

// Imágenes de referencia para usar como fallback
const DEFAULT_TOUR_IMAGES = [
  'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800',
  'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
  'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
  'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=800',
  'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
  'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800'
];

// Función para obtener una imagen de referencia (rotativa o basada en el ID del tour)
function getDefaultTourImage(tourId = '') {
  if (!tourId) {
    return DEFAULT_TOUR_IMAGES[0];
  }
  // Usar el ID del tour para seleccionar una imagen de forma consistente
  const hash = tourId.toString().split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
  return DEFAULT_TOUR_IMAGES[hash % DEFAULT_TOUR_IMAGES.length];
}

// Create Tour Card
function createTourCard(tour) {
  // Validar y sanitizar datos del tour
  // Prioridad: tourImages[0].imageUrl > imageUrl > imagen de referencia > placeholder
  const imageUrl = tour.tourImages?.[0]?.imageUrl 
    || tour.imageUrl 
    || getDefaultTourImage(tour.id)
    || 'https://via.placeholder.com/400x220?text=Tour+Image';
  
  const availability = (tour.availableSpots ?? 0) > 0 ? 'Disponible' : 'Agotado';
  const availabilityClass = (tour.availableSpots ?? 0) > 0 ? 'success' : 'danger';
  
  // Validar precio - puede venir como número, string, o undefined
  const price = tour.price != null ? (typeof tour.price === 'number' ? tour.price : parseFloat(tour.price) || 0) : 0;
  const formattedPrice = price.toFixed(2);
  
  // Validar otros campos
  const tourName = tour.name || 'Tour sin nombre';
  const tourDescription = tour.description || 'Sin descripción disponible';
  const durationHours = tour.durationHours ?? tour.durationHours ?? 0;
  const location = tour.location || 'Ubicación no especificada';
  const tourId = tour.id || '';

  return `
    <div class="tour-card" onclick="window.location.href='/tour-detail.html?id=${tourId}'" style="opacity: 0; transform: translateY(30px);">
      ${(tour.availableSpots ?? 0) > 0 ? '<div class="tour-card-badge">Disponible</div>' : '<div class="tour-card-badge" style="background: var(--danger);">Agotado</div>'}
      <img src="${imageUrl}" alt="${tourName}" class="tour-card-image" loading="lazy" onerror="this.src='${getDefaultTourImage(tourId)}'" />
      <div class="tour-card-content">
        <h3 class="tour-card-title">${tourName}</h3>
        <p class="tour-card-description">${tourDescription}</p>
        <div class="tour-card-footer">
          <div>
            <div class="tour-card-price">$${formattedPrice}</div>
            <div class="tour-card-info">
              <span>⏱ ${durationHours}h</span>
              <span>📍 ${location}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  `;
}

// Search Tours
function searchTours() {
  const searchInput = document.getElementById('searchInput');
  const query = searchInput.value.toLowerCase().trim();
  
  // TODO: Implement actual search when API is ready
  console.log('Searching for:', query);
  // For now, just reload all tours
  loadTours();
}

// Logout
if (document.getElementById('logoutBtn')) {
  document.getElementById('logoutBtn').addEventListener('click', () => {
    api.logout();
    checkAuth();
    window.location.href = '/';
  });
}

// Enter key for search
if (document.getElementById('searchInput')) {
  document.getElementById('searchInput').addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
      searchTours();
    }
  });
}

// Scroll Effects - Animaciones al hacer scroll
function initScrollEffects() {
  const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.style.opacity = '1';
        entry.target.style.transform = 'translateY(0)';
      }
    });
  }, observerOptions);

  // Observar cards de tours
  document.querySelectorAll('.tour-card').forEach(card => {
    card.style.opacity = '0';
    card.style.transform = 'translateY(30px)';
    card.style.transition = 'opacity 0.6s ease-out, transform 0.6s ease-out';
    observer.observe(card);
  });
}

// Navbar scroll effect
function initNavbarScroll() {
  const nav = document.querySelector('.nav');
  if (!nav) return;

  let lastScroll = 0;
  window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;
    
    if (currentScroll > 50) {
      nav.classList.add('scrolled');
    } else {
      nav.classList.remove('scrolled');
    }
    
    lastScroll = currentScroll;
  });
}

// Smooth scroll para enlaces internos
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', function (e) {
    e.preventDefault();
    const target = document.querySelector(this.getAttribute('href'));
    if (target) {
      target.scrollIntoView({
        behavior: 'smooth',
        block: 'start'
      });
    }
  });
});
