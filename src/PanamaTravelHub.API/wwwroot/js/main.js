// Main JavaScript para ToursPanama

// Check authentication on load
document.addEventListener('DOMContentLoaded', () => {
  checkAuth();
  loadTours();
  initScrollEffects();
  initNavbarScroll();
});

// Authentication
function checkAuth() {
  const token = localStorage.getItem('authToken');
  const loginLink = document.getElementById('loginLink');
  const adminLink = document.getElementById('adminLink');
  const logoutBtn = document.getElementById('logoutBtn');

  if (token) {
    if (loginLink) loginLink.style.display = 'none';
    if (logoutBtn) logoutBtn.style.display = 'block';
    // TODO: Check if user is admin and show admin link
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

    // Llamar a la API real
    let tours = [];
    try {
      tours = await api.getTours();
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
    console.error('Error loading tours:', error);
    loadingState.style.display = 'none';
    errorState.style.display = 'block';
  }
}

// Create Tour Card
function createTourCard(tour) {
  const imageUrl = tour.tourImages?.[0]?.imageUrl || 'https://via.placeholder.com/400x220';
  const availability = tour.availableSpots > 0 ? 'Disponible' : 'Agotado';
  const availabilityClass = tour.availableSpots > 0 ? 'success' : 'danger';

  return `
    <div class="tour-card" onclick="window.location.href='/tour-detail.html?id=${tour.id}'" style="opacity: 0; transform: translateY(30px);">
      ${tour.availableSpots > 0 ? '<div class="tour-card-badge">Disponible</div>' : '<div class="tour-card-badge" style="background: var(--danger);">Agotado</div>'}
      <img src="${imageUrl}" alt="${tour.name}" class="tour-card-image" loading="lazy" onerror="this.src='https://via.placeholder.com/400x220?text=Tour+Image'" />
      <div class="tour-card-content">
        <h3 class="tour-card-title">${tour.name}</h3>
        <p class="tour-card-description">${tour.description}</p>
        <div class="tour-card-footer">
          <div>
            <div class="tour-card-price">$${tour.price.toFixed(2)}</div>
            <div class="tour-card-info">
              <span>⏱ ${tour.durationHours}h</span>
              <span>📍 ${tour.location}</span>
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
