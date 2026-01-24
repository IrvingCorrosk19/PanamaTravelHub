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
    
    // El backend devuelve PascalCase, pero también intentamos camelCase para compatibilidad
    const getValue = (obj, pascalKey, camelKey) => {
      return obj[pascalKey] ?? obj[camelKey] ?? null;
    };
    
    // Actualizar navegación
    const navBrandText = document.getElementById('navBrandText');
    if (navBrandText) navBrandText.textContent = getValue(content, 'NavBrandText', 'navBrandText') || 'ToursPanama';
    
    const navToursLink = document.getElementById('navToursLink');
    if (navToursLink) navToursLink.textContent = getValue(content, 'NavToursLink', 'navToursLink') || 'Tours';
    
    const navBookingsLink = document.getElementById('navBookingsLink');
    if (navBookingsLink) navBookingsLink.textContent = getValue(content, 'NavBookingsLink', 'navBookingsLink') || 'Mis Reservas';
    
    const loginLink = document.getElementById('loginLink');
    if (loginLink) loginLink.textContent = getValue(content, 'NavLoginLink', 'navLoginLink') || 'Iniciar Sesión';
    
    const logoutBtn = document.getElementById('logoutBtn');
    if (logoutBtn) logoutBtn.textContent = getValue(content, 'NavLogoutButton', 'navLogoutButton') || 'Cerrar Sesión';
    
    // Actualizar hero section
    const heroTitle = document.getElementById('heroTitle');
    if (heroTitle) heroTitle.textContent = getValue(content, 'HeroTitle', 'heroTitle') || 'Descubre Panamá';
    
    const heroSubtitle = document.getElementById('heroSubtitle');
    if (heroSubtitle) heroSubtitle.textContent = getValue(content, 'HeroSubtitle', 'heroSubtitle') || 'Explora los destinos más increíbles con nuestros tours exclusivos';
    
    const searchInput = document.getElementById('searchInput');
    if (searchInput) searchInput.placeholder = getValue(content, 'HeroSearchPlaceholder', 'heroSearchPlaceholder') || 'Buscar tours...';
    
    const searchButton = document.getElementById('searchButton');
    if (searchButton) searchButton.textContent = getValue(content, 'HeroSearchButton', 'heroSearchButton') || 'Buscar';
    
    // Actualizar imagen de fondo del hero
    const heroImageUrl = getValue(content, 'HeroImageUrl', 'heroImageUrl');
    const heroSection = document.querySelector('.hero');
    if (heroSection && heroImageUrl) {
      // Convertir URL relativa a absoluta si es necesario
      const absoluteHeroImageUrl = heroImageUrl.startsWith('http') 
        ? heroImageUrl 
        : `${window.location.origin}${heroImageUrl.startsWith('/') ? '' : '/'}${heroImageUrl}`;
      
      // Aplicar imagen manteniendo los gradientes superpuestos
      heroSection.style.backgroundImage = `
        radial-gradient(circle at 20% 30%, rgba(14, 165, 233, 0.08) 0%, transparent 50%),
        radial-gradient(circle at 80% 70%, rgba(99, 102, 241, 0.08) 0%, transparent 50%),
        linear-gradient(135deg, rgba(11, 18, 32, 0.5) 0%, rgba(6, 182, 212, 0.3) 100%),
        url('${absoluteHeroImageUrl}')
      `;
      heroSection.style.backgroundSize = 'cover';
      heroSection.style.backgroundPosition = 'center';
      heroSection.style.backgroundRepeat = 'no-repeat';
      console.log('✅ [loadHomePageContent] Imagen del hero aplicada:', absoluteHeroImageUrl);
    } else if (heroSection && !heroImageUrl) {
      // Si no hay imagen, mantener la imagen por defecto del CSS
      // El CSS ya tiene una imagen por defecto: background-image: url('/images/Hero Image 19369.png');
      console.log('ℹ️ [loadHomePageContent] No hay imagen del hero configurada, usando imagen por defecto del CSS');
      // Asegurar que se use la imagen por defecto con gradientes
      heroSection.style.backgroundImage = `
        radial-gradient(circle at 20% 30%, rgba(14, 165, 233, 0.08) 0%, transparent 50%),
        radial-gradient(circle at 80% 70%, rgba(99, 102, 241, 0.08) 0%, transparent 50%),
        linear-gradient(135deg, rgba(11, 18, 32, 0.5) 0%, rgba(6, 182, 212, 0.3) 100%),
        url('/images/Hero Image 19369.png')
      `;
      heroSection.style.backgroundSize = 'cover';
      heroSection.style.backgroundPosition = 'center';
      heroSection.style.backgroundRepeat = 'no-repeat';
    }
    
    // Actualizar título y meta description
    const pageTitle = document.getElementById('pageTitle');
    if (pageTitle) pageTitle.textContent = getValue(content, 'PageTitle', 'pageTitle') || 'ToursPanama — Descubre los Mejores Tours en Panamá';
    
    const metaDescription = document.getElementById('metaDescription');
    if (metaDescription) metaDescription.setAttribute('content', getValue(content, 'MetaDescription', 'metaDescription') || 'Plataforma moderna de reservas de tours en Panamá. Explora, reserva y disfruta de las mejores experiencias turísticas.');
    
    // Actualizar favicon
    const faviconUrl = getValue(content, 'FaviconUrl', 'faviconUrl');
    const faviconLink = document.getElementById('faviconLink');
    if (faviconLink && faviconUrl) {
      faviconLink.href = faviconUrl;
    }
    
    // Actualizar logo en navbar
    const logoUrl = getValue(content, 'LogoUrl', 'logoUrl');
    const navLogo = document.getElementById('navLogo');
    if (navLogo) {
      if (logoUrl) {
        navLogo.src = logoUrl;
        navLogo.style.display = 'block';
      } else {
        navLogo.style.display = 'none';
      }
    }
    
    // Actualizar logo en footer
    const footerLogo = document.getElementById('footerLogo');
    if (footerLogo) {
      if (logoUrl) {
        footerLogo.src = logoUrl;
        footerLogo.style.display = 'block';
      } else {
        footerLogo.style.display = 'none';
      }
    }
    
    // Actualizar meta tags Open Graph y Twitter
    const pageTitleValue = getValue(content, 'PageTitle', 'pageTitle') || 'ToursPanama — Descubre los Mejores Tours en Panamá';
    const metaDescriptionValue = getValue(content, 'MetaDescription', 'metaDescription') || 'Plataforma moderna de reservas de tours en Panamá. Explora, reserva y disfruta de las mejores experiencias turísticas.';
    const logoUrlSocial = getValue(content, 'LogoUrlSocial', 'logoUrlSocial');
    
    const ogTitle = document.getElementById('ogTitle');
    if (ogTitle) ogTitle.setAttribute('content', pageTitleValue);
    
    const ogDescription = document.getElementById('ogDescription');
    if (ogDescription) ogDescription.setAttribute('content', metaDescriptionValue);
    
    const ogImage = document.getElementById('ogImage');
    if (ogImage && logoUrlSocial) {
      ogImage.setAttribute('content', logoUrlSocial);
    }
    
    const twitterTitle = document.getElementById('twitterTitle');
    if (twitterTitle) twitterTitle.setAttribute('content', pageTitleValue);
    
    const twitterDescription = document.getElementById('twitterDescription');
    if (twitterDescription) twitterDescription.setAttribute('content', metaDescriptionValue);
    
    const twitterImage = document.getElementById('twitterImage');
    if (twitterImage && logoUrlSocial) {
      twitterImage.setAttribute('content', logoUrlSocial);
    }
    
    // Actualizar sección de tours
    const toursSectionTitle = document.getElementById('toursSectionTitle');
    if (toursSectionTitle) toursSectionTitle.textContent = getValue(content, 'ToursSectionTitle', 'toursSectionTitle') || 'Tours Disponibles';
    
    const toursSectionSubtitle = document.getElementById('toursSectionSubtitle');
    if (toursSectionSubtitle) toursSectionSubtitle.textContent = getValue(content, 'ToursSectionSubtitle', 'toursSectionSubtitle') || 'Selecciona tu próxima aventura';
    
    const loadingToursText = document.getElementById('loadingToursText');
    if (loadingToursText) loadingToursText.textContent = getValue(content, 'LoadingToursText', 'loadingToursText') || 'Cargando tours...';
    
    const errorLoadingToursText = document.getElementById('errorLoadingToursText');
    if (errorLoadingToursText) errorLoadingToursText.textContent = getValue(content, 'ErrorLoadingToursText', 'errorLoadingToursText') || 'Error al cargar los tours. Por favor, intenta de nuevo.';
    
    const noToursFoundText = document.getElementById('noToursFoundText');
    if (noToursFoundText) noToursFoundText.textContent = getValue(content, 'NoToursFoundText', 'noToursFoundText') || 'No se encontraron tours disponibles.';
    
    // Actualizar footer
    const footerBrandText = document.getElementById('footerBrandText');
    if (footerBrandText) footerBrandText.textContent = getValue(content, 'FooterBrandText', 'footerBrandText') || 'ToursPanama';
    
    const footerDescription = document.getElementById('footerDescription');
    if (footerDescription) footerDescription.textContent = getValue(content, 'FooterDescription', 'footerDescription') || 'Tu plataforma de confianza para descubrir Panamá';
    
    const footerCopyright = document.getElementById('footerCopyright');
    if (footerCopyright) footerCopyright.textContent = getValue(content, 'FooterCopyright', 'footerCopyright') || '© 2024 ToursPanama. Todos los derechos reservados.';
  } catch (error) {
    console.error('Error loading homepage content:', error);
    // Si falla, usar valores por defecto (ya están en el HTML)
  }
}

// Cargar información del usuario autenticado
async function loadUserInfo() {
  const accessToken = localStorage.getItem('accessToken') || localStorage.getItem('authToken');
  const userGreeting = document.getElementById('userGreeting');
  
  if (!accessToken || !userGreeting) {
    if (userGreeting) userGreeting.style.display = 'none';
    return;
  }

  try {
    // Intentar obtener el nombre desde localStorage primero (para evitar llamadas innecesarias)
    let userName = localStorage.getItem('userName');
    
    // Si no hay nombre guardado, obtenerlo de la API
    if (!userName) {
      const currentUser = await api.getCurrentUser();
      if (currentUser) {
        const firstName = currentUser.FirstName || currentUser.firstName || '';
        const lastName = currentUser.LastName || currentUser.lastName || '';
        userName = `${firstName} ${lastName}`.trim();
        
        // Guardar en localStorage para futuras cargas
        if (userName) {
          localStorage.setItem('userName', userName);
        }
      }
    }
    
    // Mostrar el saludo si hay nombre
    if (userName) {
      userGreeting.textContent = `Hola, ${userName}`;
      userGreeting.style.display = 'inline-flex';
    } else {
      userGreeting.style.display = 'none';
    }
  } catch (error) {
    console.warn('No se pudo cargar la información del usuario:', error);
    // Si falla, ocultar el saludo
    if (userGreeting) userGreeting.style.display = 'none';
    // Limpiar nombre guardado si hay error de autenticación
    localStorage.removeItem('userName');
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
  const userGreeting = document.getElementById('userGreeting');

  if (accessToken) {
    if (loginLink) loginLink.style.display = 'none';
    if (logoutBtn) {
      logoutBtn.style.display = 'block';
      // Agregar event listener para logout
      logoutBtn.onclick = async () => {
        // Limpiar nombre del usuario al hacer logout
        localStorage.removeItem('userName');
        await api.logout();
        window.location.href = '/';
      };
    }
    
    // Cargar información del usuario para mostrar su nombre
    loadUserInfo();
    
    // Si es admin, mostrar link de admin y redirigir automáticamente al panel
    if (isAdmin) {
      if (adminLink) adminLink.style.display = 'block';
      // Si estamos en la página principal y el usuario es admin, redirigir al panel
      if (window.location.pathname === '/' || window.location.pathname === '/index.html') {
        window.location.href = '/Admin';
      }
    } else {
      if (adminLink) adminLink.style.display = 'none';
    }
  } else {
    if (loginLink) loginLink.style.display = 'block';
    if (logoutBtn) logoutBtn.style.display = 'none';
    if (adminLink) adminLink.style.display = 'none';
    if (userGreeting) userGreeting.style.display = 'none';
    // Limpiar nombre del usuario si no está autenticado
    localStorage.removeItem('userName');
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
      console.log('🔍 [loadTours] Llamando a api.getTours()...');
      tours = await api.getTours();
      console.log('✅ [loadTours] Respuesta recibida:', tours);
      console.log('📊 [loadTours] Tipo de datos:', Array.isArray(tours) ? 'Array' : typeof tours);
      console.log('📊 [loadTours] Cantidad de tours:', tours?.length || 0);
      if (tours && tours.length > 0) {
        console.log('📋 [loadTours] Primer tour:', tours[0]);
      }
      loadingManager.hideInline(toursGrid);
    } catch (error) {
      console.error('❌ [loadTours] Error al obtener tours:', error);
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

    console.log('🔍 [loadTours] Validando tours...');
    console.log('📊 [loadTours] Total tours recibidos:', tours?.length || 0);
    
    // Debug: ver estructura completa de los tours
    if (tours && tours.length > 0) {
      console.table(tours.map(t => ({
        id: t.id || t.Id,
        name: t.name || t.Name,
        price: t.price ?? t.Price ?? 'UNDEFINED',
        priceType: typeof (t.price ?? t.Price)
      })));
    }

    if (!tours || tours.length === 0) {
      console.warn('⚠️ [loadTours] No hay tours para mostrar');
      emptyState.style.display = 'block';
      return;
    }

    // Validar y sanitizar tours antes de renderizar
    console.log('🔍 [loadTours] Filtrando tours válidos...');
    const validTours = tours.filter(tour => {
      // El backend puede retornar Id (mayúscula) o id (minúscula)
      const tourId = tour.id || tour.Id;
      if (!tour || !tourId) {
        console.warn('⚠️ [loadTours] Tour inválido encontrado:', tour);
        if (typeof logger !== 'undefined') {
          logger.warn('Tour inválido encontrado', { tour });
        }
        return false;
      }
      return true;
    });

    console.log('✅ [loadTours] Tours válidos:', validTours.length);

    if (validTours.length === 0) {
      console.warn('⚠️ [loadTours] No hay tours válidos después del filtrado');
      emptyState.style.display = 'block';
      return;
    }

    toursGrid.innerHTML = validTours.map(tour => {
      try {
        return createTourCard(tour);
      } catch (error) {
        if (typeof logger !== 'undefined') {
          logger.error('Error al crear card del tour', error, { tourId: tour.id, tour });
        } else {
          console.error('Error al crear card del tour:', error, tour);
        }
        return ''; // Retornar string vacío si hay error
      }
    }).filter(card => card !== '').join('');
    
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
  console.log('🎴 [createTourCard] === INICIO ===', { tour });
  
  // Validar que tour existe
  if (!tour) {
    console.error('❌ [createTourCard] Tour es null o undefined');
    throw new Error('Tour es null o undefined');
  }

  console.log('✅ [createTourCard] Tour válido, normalizando propiedades...');

  // Normalizar propiedades (el backend puede retornar Id/Name con mayúscula)
  // El backend ASP.NET Core retorna PascalCase por defecto
  const tourId = tour.Id || tour.id || '';
  const tourName = tour.Name || tour.name || '';
  const tourDescription = tour.Description || tour.description || '';
  const tourLocation = tour.Location || tour.location || '';
  
  // Priorizar TourImages (PascalCase) que es lo que devuelve el backend
  const tourImages = tour.TourImages || tour.tourImages || [];
  
  const availableSpots = tour.AvailableSpots !== undefined ? tour.AvailableSpots : 
                         (tour.availableSpots !== undefined ? tour.availableSpots : 0);
  const maxCapacity = tour.MaxCapacity !== undefined ? tour.MaxCapacity : 
                      (tour.maxCapacity !== undefined ? tour.maxCapacity : 0);
  
  console.log('📋 [createTourCard] Propiedades normalizadas:', {
    tourId,
    tourName,
    tourLocation,
    availableSpots,
    maxCapacity,
    tourImagesCount: tourImages.length
  });

  // ============================================
  // DISTRIBUCIÓN DE IMÁGENES EN HOME/INDEX
  // ============================================
  // Las imágenes se muestran en las tarjetas de tours con la siguiente prioridad:
  // 1. tourImages[0].ImageUrl - Primera imagen del array (PascalCase del backend)
  // 2. tourImages[0].imageUrl - Primera imagen (camelCase fallback)
  // 3. Imagen principal (IsPrimary = true) si existe
  // 4. tour.ImageUrl - Imagen principal del tour (fallback)
  // 5. getDefaultTourImage(tourId) - Imagen de referencia basada en el ID del tour (rotativa)
  // 6. Placeholder genérico - Si no hay ninguna imagen disponible
  //
  // NOTA: El backend retorna las imágenes en el array 'TourImages' (PascalCase) ordenadas por DisplayOrder,
  // donde la primera imagen (índice 0) es la imagen principal (IsPrimary = true).
  // ============================================
  
  // Buscar imagen principal (IsPrimary = true) o usar la primera imagen
  let imageUrl = null;
  if (tourImages && tourImages.length > 0) {
    // Buscar imagen principal
    const primaryImage = tourImages.find(img => img.IsPrimary === true || img.isPrimary === true);
    if (primaryImage) {
      imageUrl = primaryImage.ImageUrl || primaryImage.imageUrl;
    } else {
      // Si no hay imagen principal, usar la primera
      imageUrl = tourImages[0]?.ImageUrl || tourImages[0]?.imageUrl;
    }
  }
  
  // Fallbacks
  if (!imageUrl) {
    imageUrl = tour.ImageUrl || tour.imageUrl || getDefaultTourImage(tourId) || 'https://via.placeholder.com/400x220?text=Tour+Image';
  }
  
  const availability = (availableSpots ?? 0) > 0 ? 'Disponible' : 'Agotado';
  const availabilityClass = (availableSpots ?? 0) > 0 ? 'success' : 'danger';
  
  console.log('🏷️ [createTourCard] Disponibilidad calculada:', {
    availableSpots,
    maxCapacity,
    availability,
    availabilityClass,
    isAvailable: (availableSpots ?? 0) > 0
  });
  
  console.log('💰 [createTourCard] === PROCESANDO PRECIO ===');
  
  // ✅ SOLUCIÓN ROBUSTA: Normalizar precio de forma segura
  // El backend debe retornar siempre un precio válido, pero validamos por seguridad
  const rawPrice = tour.Price ?? tour.price ?? null;
  
  console.log('1️⃣ [createTourCard] Raw price obtenido:', {
    'tour.Price': tour.Price,
    'tour.price': tour.price,
    rawPrice,
    rawPriceType: typeof rawPrice,
    hasPrice: 'price' in tour,
    hasPriceUpper: 'Price' in tour
  });
  
  // Convertir a número con fallback a 0 (evita crash con toFixed)
  let price = Number(rawPrice ?? 0);
  
  console.log('2️⃣ [createTourCard] Price después de Number():', {
    price,
    priceType: typeof price,
    isNaN: isNaN(price),
    isFinite: isFinite(price)
  });
  
  // Validación estricta: asegurar que price es un número válido y finito
  if (typeof price !== 'number' || isNaN(price) || !isFinite(price)) {
    console.warn('⚠️ [createTourCard] Precio inválido detectado en validación 1, usando 0:', { 
      tourId, 
      tourName, 
      rawPrice, 
      rawPriceType: typeof rawPrice,
      priceBeforeFix: price,
      priceType: typeof price
    });
    price = 0;
  } else {
    console.log('✅ [createTourCard] Validación 1 pasada: price es número válido');
  }
  
  // Validación estricta solo en desarrollo (para detectar problemas en rawPrice)
  if (typeof rawPrice !== 'number' && rawPrice !== null && rawPrice !== undefined) {
    console.warn('⚠️ [createTourCard] Tour con precio no numérico (tipo inesperado):', { 
      tourId, 
      tourName, 
      rawPrice, 
      priceType: typeof rawPrice,
      finalPrice: price 
    });
  }
  
  // 🛡️ VALIDACIÓN FINAL: Asegurar que price es número válido antes de toFixed
  // Esto nunca debería ejecutarse si todo está bien, pero es protección extra
  if (typeof price !== 'number' || isNaN(price) || !isFinite(price)) {
    console.error('❌ [createTourCard] ERROR CRÍTICO: price inválido antes de toFixed, usando 0', {
      tourId,
      tourName,
      price,
      priceType: typeof price
    });
    price = 0;
  } else {
    console.log('✅ [createTourCard] Validación final pasada: price listo para toFixed()');
  }
  
  // Formatear precio (price siempre es un número válido aquí)
  console.log('3️⃣ [createTourCard] Llamando a toFixed(2) con price:', price);
  const formattedPrice = price.toFixed(2);
  console.log('✅ [createTourCard] formattedPrice obtenido:', formattedPrice);
  
  // Fallback visual elegante si el precio es 0 (puede indicar "consultar precio")
  const priceText = price > 0 ? `$${formattedPrice}` : 'Consultar precio';
  console.log('4️⃣ [createTourCard] priceText final:', priceText);
  
  // Validar otros campos con valores normalizados (priorizar PascalCase del backend)
  const finalTourName = tourName || 'Tour sin nombre';
  const finalTourDescription = tourDescription || 'Sin descripción disponible';
  const durationHours = tour.DurationHours || tour.durationHours || 0;
  const finalLocation = tourLocation || 'Ubicación no especificada';
  
  // Obtener fecha del tour (TourDate)
  const tourDate = tour.TourDate || tour.tourDate;
  let formattedTourDate = '';
  if (tourDate) {
    try {
      const dateObj = new Date(tourDate);
      if (!isNaN(dateObj.getTime())) {
        formattedTourDate = dateObj.toLocaleDateString('es-PA', { 
          year: 'numeric', 
          month: 'short', 
          day: 'numeric' 
        });
      }
    } catch (e) {
      console.warn('Error al formatear fecha del tour:', e);
    }
  }

    // Alt text para SEO
    const imageAlt = tourName || 'Tour en Panamá';
    
    console.log('🎨 [createTourCard] Generando HTML para card:', {
    finalTourName,
    durationHours,
    finalLocation,
    priceText,
    tourDate: formattedTourDate
  });

  const cardHtml = `
    <div class="tour-card" onclick="window.location.href='/tour-detail.html?id=${tourId}'" style="opacity: 0; transform: translateY(30px);">
      ${(availableSpots ?? 0) > 0 ? '<div class="tour-card-badge">Disponible</div>' : '<div class="tour-card-badge" style="background: var(--danger);">Agotado</div>'}
      <img src="${imageUrl}" alt="${finalTourName}" class="tour-card-image" loading="lazy" onerror="this.src='${getDefaultTourImage(tourId)}'" />
      <div class="tour-card-content">
        <h3 class="tour-card-title">${finalTourName}</h3>
        <p class="tour-card-description">${finalTourDescription}</p>
        <div class="tour-card-footer">
          <div>
            <div class="tour-card-price">${priceText}</div>
            <div class="tour-card-info">
              <span>⏱ ${durationHours}h</span>
              <span>📍 ${finalLocation}</span>
              ${formattedTourDate ? `<span>📅 ${formattedTourDate}</span>` : ''}
            </div>
          </div>
        </div>
      </div>
    </div>
  `;
  
  console.log('✅ [createTourCard] === FIN - Card generada exitosamente ===');
  return cardHtml;
}

// Search Tours with Advanced Filters
let currentSearchQuery = '';
let currentFilters = {};

async function searchTours() {
  const searchInput = document.getElementById('searchInput');
  const query = searchInput?.value?.trim() || '';
  currentSearchQuery = query;
  
  const loadingState = document.getElementById('loadingState');
  const errorState = document.getElementById('errorState');
  const emptyState = document.getElementById('emptyState');
  const toursGrid = document.getElementById('toursGrid');
  
  try {
    loadingState.style.display = 'block';
    errorState.style.display = 'none';
    emptyState.style.display = 'none';
    toursGrid.innerHTML = '';
    
    const loaderId = loadingManager.showInline(toursGrid, 'Buscando tours...');
    
    // Construir filtros
    const filters = {
      minPrice: document.getElementById('filterMinPrice')?.value ? parseFloat(document.getElementById('filterMinPrice').value) : null,
      maxPrice: document.getElementById('filterMaxPrice')?.value ? parseFloat(document.getElementById('filterMaxPrice').value) : null,
      minDuration: document.getElementById('filterMinDuration')?.value ? parseInt(document.getElementById('filterMinDuration').value) : null,
      maxDuration: document.getElementById('filterMaxDuration')?.value ? parseInt(document.getElementById('filterMaxDuration').value) : null,
      location: document.getElementById('filterLocation')?.value?.trim() || null,
      sortBy: document.getElementById('filterSortBy')?.value || 'created',
      sortOrder: document.getElementById('filterSortOrder')?.value || 'desc'
    };
    
    currentFilters = filters;
    
    // Usar búsqueda avanzada si hay query o filtros
    let tours = [];
    if (query || Object.values(filters).some(v => v !== null && v !== '')) {
      const response = await api.searchTours(query, filters, 1, 50);
      tours = response.tours || response.data || [];
    } else {
      // Si no hay búsqueda ni filtros, cargar todos
      tours = await api.getTours();
    }
    
    loadingManager.hideInline(toursGrid);
    loadingState.style.display = 'none';
    
    if (!tours || tours.length === 0) {
      emptyState.style.display = 'block';
      return;
    }
    
    // Renderizar tours
    toursGrid.innerHTML = tours.map(tour => {
      try {
        return createTourCard(tour);
      } catch (error) {
        console.error('Error al crear card del tour:', error, tour);
        return '';
      }
    }).filter(card => card !== '').join('');
    
    // Animar cards
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
    console.error('Error searching tours:', error);
    loadingState.style.display = 'none';
    errorState.style.display = 'block';
    loadingManager.hideInline(toursGrid);
  }
}

function toggleAdvancedFilters() {
  const filtersPanel = document.getElementById('advancedFilters');
  const toggleText = document.getElementById('filtersToggleText');
  
  if (filtersPanel.style.display === 'none') {
    filtersPanel.style.display = 'block';
    toggleText.textContent = 'Ocultar Filtros Avanzados';
  } else {
    filtersPanel.style.display = 'none';
    toggleText.textContent = 'Mostrar Filtros Avanzados';
  }
}

function applyFilters() {
  searchTours();
}

function clearFilters() {
  document.getElementById('searchInput').value = '';
  document.getElementById('filterMinPrice').value = '';
  document.getElementById('filterMaxPrice').value = '';
  document.getElementById('filterMinDuration').value = '';
  document.getElementById('filterMaxDuration').value = '';
  document.getElementById('filterLocation').value = '';
  document.getElementById('filterSortBy').value = 'created';
  document.getElementById('filterSortOrder').value = 'desc';
  currentSearchQuery = '';
  currentFilters = {};
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
