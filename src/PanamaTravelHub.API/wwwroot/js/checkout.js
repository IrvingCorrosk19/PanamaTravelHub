// Checkout JavaScript para ToursPanama

// ✅ Función helper para mostrar errores de notificación
function showNotificationError(message) {
  if (typeof notificationManager !== 'undefined' && notificationManager) {
    notificationManager.error(message);
  } else if (typeof window !== 'undefined' && window.notificationManager) {
    window.notificationManager.error(message);
  } else {
    // Fallback a alert si no hay notificationManager disponible
    alert(message);
  }
}

// ✅ Función helper para formatear precios de forma segura
function formatPrice(value, fallbackText = 'Consultar precio') {
  const rawPrice = value ?? null;
  let price = Number(rawPrice ?? 0);
  
  // Validación: asegurar que price es un número válido y finito
  if (typeof price !== 'number' || isNaN(price) || !isFinite(price)) {
    console.warn('⚠️ [formatPrice] Precio inválido, usando 0:', { value, rawPrice, price });
    price = 0;
  }
  
  // Formatear precio
  const formattedPrice = price.toFixed(2);
  return price > 0 ? `$${formattedPrice}` : fallbackText;
}

let currentTour = null;
let numberOfParticipants = 1;
let selectedPaymentMethod = 'stripe';
let selectedTourDateId = null;
let availableDates = [];
let stripe = null;
let stripePublishableKey = null;

// Cargar información del tour desde URL
document.addEventListener('DOMContentLoaded', async () => {
  await loadStripeConfig();
  loadTourFromUrl();
  loadCountries();
  updateParticipants();
  setupPaymentInputs();
});

async function loadStripeConfig() {
  try {
    const config = await api.getStripeConfig();
    stripePublishableKey = config.publishableKey;
    if (stripePublishableKey && typeof Stripe !== 'undefined') {
      stripe = Stripe(stripePublishableKey);
    }
  } catch (error) {
    console.warn('No se pudo cargar la configuración de Stripe:', error);
  }
}

function loadTourFromUrl() {
  const urlParams = new URLSearchParams(window.location.search);
  const tourId = urlParams.get('tourId');

  if (!tourId) {
    // Si no hay tourId, redirigir a home
    window.location.href = '/';
    return;
  }

  loadTour(tourId);
}

async function loadTour(tourId) {
  try {
    // Intentar cargar desde API
    try {
      currentTour = await api.getTour(tourId);
    } catch (error) {
      // Fallback a datos mock
      console.warn('API no disponible, usando datos mock:', error);
      currentTour = {
        id: tourId,
        name: 'Tour del Canal de Panamá',
        description: 'Descubre la maravilla de la ingeniería mundial.',
        price: 75.00,
        durationHours: 4,
        location: 'Ciudad de Panamá',
        availableSpots: 15,
        maxCapacity: 20,
        tourImages: [{ imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400', isPrimary: true }]
      };
    }

    updateTourSummary();
    // updateOrderSummary se llamará después de cargar las fechas
    // para evitar el warning "No hay tour cargado"
    
    // Cargar fechas disponibles
    await loadAvailableDates(tourId);
    
    // Actualizar resumen después de cargar todo
    updateOrderSummary();
  } catch (error) {
    console.error('Error loading tour:', error);
    if (typeof notificationManager !== 'undefined' && notificationManager) {
      notificationManager.error('Error al cargar el tour. Redirigiendo...');
    } else if (typeof window !== 'undefined' && window.notificationManager) {
      window.notificationManager.error('Error al cargar el tour. Redirigiendo...');
    }
    setTimeout(() => {
      window.location.href = '/';
    }, 2000);
  }
}

async function loadCountries() {
  try {
    console.log('🌍 [loadCountries] Cargando países...');
    const countries = await api.getCountries();
    console.log('🌍 [loadCountries] Países recibidos:', countries);
    
    const countrySelect = document.getElementById('countrySelect');
    
    if (!countrySelect) {
      console.warn('🌍 [loadCountries] Select de países no encontrado');
      return;
    }
    
    // Limpiar opciones existentes excepto la primera
    countrySelect.innerHTML = '<option value="">Selecciona un país...</option>';
    
    // Agregar países al select (normalizar PascalCase del backend)
    if (countries && Array.isArray(countries) && countries.length > 0) {
      console.log(`🌍 [loadCountries] Agregando ${countries.length} países al select`);
      countries.forEach((country, index) => {
        // Priorizar PascalCase que es lo que devuelve el backend
        const countryId = country.Id || country.id;
        const countryName = country.Name || country.name;
        
        if (countryId && countryName) {
          const option = document.createElement('option');
          option.value = countryId;
          
          // El problema de codificación puede estar en la base de datos o en la serialización
          // Intentar corregir caracteres comunes mal codificados
          let decodedName = countryName;
          
          // Mapeo de caracteres mal codificados comunes (UTF-8 interpretado como Latin-1)
          const encodingFixMap = {
            'PanamÃ¡': 'Panamá',
            'MÃ©xico': 'México',
            'CanadÃ¡': 'Canadá',
            'EspaÃ±a': 'España',
            'PerÃº': 'Perú',
            'Ã¡': 'á',
            'Ã©': 'é',
            'Ã­': 'í',
            'Ã³': 'ó',
            'Ãº': 'ú',
            'Ã±': 'ñ',
            'Ã': 'Á',
            'Ã‰': 'É',
            'Ã': 'Í',
            'Ã"': 'Ó',
            'Ãš': 'Ú',
            "Ã'": 'Ñ'
          };
          
          // Aplicar correcciones
          for (const [wrong, correct] of Object.entries(encodingFixMap)) {
            decodedName = decodedName.replace(new RegExp(wrong.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g'), correct);
          }
          
          option.textContent = decodedName;
          countrySelect.appendChild(option);
          console.log(`🌍 [loadCountries] País ${index + 1}: ${decodedName} (ID: ${countryId})`);
        } else {
          console.warn(`🌍 [loadCountries] País inválido en índice ${index}:`, country);
        }
      });
      console.log(`🌍 [loadCountries] Total países agregados: ${countrySelect.options.length - 1}`);
    } else {
      console.warn('🌍 [loadCountries] No se recibieron países o el array está vacío');
    }
  } catch (error) {
    console.error('❌ [loadCountries] Error loading countries:', error);
    console.warn('No se pudieron cargar los países:', error);
  }
}

async function loadAvailableDates(tourId) {
  try {
    // 🔒 GUARD CLAUSE: Validar que tourId esté presente
    if (!tourId) {
      // Intentar obtener tourId de fuentes alternativas
      const tourIdFromTour = currentTour?.Id || currentTour?.id;
      const tourIdFromUrl = new URLSearchParams(window.location.search).get('tourId');
      const tourIdFromStorage = localStorage.getItem('currentTourId');
      
      const fallbackTourId = tourIdFromTour || tourIdFromUrl || tourIdFromStorage;
      
      if (!fallbackTourId) {
        console.error('❌ [loadAvailableDates] tourId no proporcionado y no se pudo obtener de fuentes alternativas', {
          tourId,
          tourIdFromTour,
          tourIdFromUrl,
          tourIdFromStorage,
          currentTour: currentTour ? 'presente' : 'ausente'
        });
        return;
      }
      
      console.warn('⚠️ [loadAvailableDates] tourId no proporcionado, usando fallback:', fallbackTourId);
      tourId = fallbackTourId;
    }
    
    console.log('📅 [loadAvailableDates] Cargando fechas para tour:', tourId);
    const dateSelection = document.getElementById('dateSelection');
    const dateError = document.getElementById('dateError');
    
    if (!dateSelection) {
      console.error('📅 [loadAvailableDates] Elemento dateSelection no encontrado');
      return;
    }
    
    dateSelection.innerHTML = '<div class="date-loading">Cargando fechas disponibles...</div>';
    if (dateError) dateError.style.display = 'none';
    
    // Intentar cargar fechas específicas del tour (tour_dates)
    try {
      availableDates = await api.getTourDates(tourId);
      console.log('📅 [loadAvailableDates] Fechas recibidas de API:', availableDates);
    } catch (apiError) {
      console.error('📅 [loadAvailableDates] Error al llamar a getTourDates:', apiError);
      availableDates = [];
    }
    
    // Si no hay fechas específicas, verificar si el tour tiene una fecha principal (TourDate)
    if ((!availableDates || availableDates.length === 0) && currentTour) {
      console.log('📅 [loadAvailableDates] No hay fechas específicas, verificando fecha principal del tour');
      const tourDate = currentTour.TourDate || currentTour.tourDate;
      console.log('📅 [loadAvailableDates] Fecha principal del tour:', tourDate);
      
      if (tourDate) {
        // Crear una fecha virtual basada en la fecha principal del tour
        const dateObj = new Date(tourDate);
        if (!isNaN(dateObj.getTime()) && dateObj > new Date()) {
          // Solo si la fecha es futura
          console.log('📅 [loadAvailableDates] Creando fecha virtual desde fecha principal del tour');
          availableDates = [{
            Id: null, // No tiene ID porque es la fecha principal, no una fecha específica
            id: null,
            TourDateTime: tourDate,
            tourDateTime: tourDate,
            AvailableSpots: currentTour.AvailableSpots ?? currentTour.availableSpots ?? 0,
            availableSpots: currentTour.AvailableSpots ?? currentTour.availableSpots ?? 0,
            IsActive: true,
            isActive: true
          }];
          console.log('📅 [loadAvailableDates] Fecha virtual creada:', availableDates[0]);
        } else {
          console.warn('📅 [loadAvailableDates] La fecha principal del tour es pasada o inválida');
        }
      } else {
        console.warn('📅 [loadAvailableDates] El tour no tiene fecha principal');
      }
    }
    
    if (!availableDates || availableDates.length === 0) {
      console.warn('📅 [loadAvailableDates] No hay fechas disponibles');
      dateSelection.innerHTML = `
        <div class="date-empty">
          <p style="color: var(--text-muted); margin: 20px 0;">No hay fechas disponibles para este tour en este momento.</p>
          <p style="color: var(--text-muted); font-size: 0.9rem;">Por favor, contacta con nosotros para más información.</p>
        </div>
      `;
      return;
    }
    
    console.log(`📅 [loadAvailableDates] Mostrando ${availableDates.length} fecha(s) disponible(s)`);
    // Mostrar calendario de fechas disponibles
    renderDateCalendar();
  } catch (error) {
    console.error('❌ [loadAvailableDates] Error loading dates:', error);
    const dateSelection = document.getElementById('dateSelection');
    if (dateSelection) {
      dateSelection.innerHTML = `
        <div class="date-error">
          <p style="color: var(--error);">Error al cargar las fechas disponibles. Por favor, intenta de nuevo.</p>
        </div>
      `;
    }
  }
}

function renderDateCalendar() {
  const dateSelection = document.getElementById('dateSelection');
  const now = new Date();
  
  // Agrupar fechas por mes
  const datesByMonth = {};
  availableDates.forEach(date => {
    // Normalizar propiedades (priorizar PascalCase del backend)
    const tourDateTime = date.TourDateTime || date.tourDateTime;
    const dateObj = new Date(tourDateTime);
    const monthKey = `${dateObj.getFullYear()}-${dateObj.getMonth()}`;
    if (!datesByMonth[monthKey]) {
      datesByMonth[monthKey] = [];
    }
    datesByMonth[monthKey].push(date);
  });
  
  let html = '<div class="date-calendar">';
  
  // Mostrar las fechas disponibles
  Object.keys(datesByMonth).sort().forEach(monthKey => {
    const dates = datesByMonth[monthKey];
    const firstDateDateTime = dates[0].TourDateTime || dates[0].tourDateTime;
    const firstDate = new Date(firstDateDateTime);
    const monthName = firstDate.toLocaleDateString('es-PA', { month: 'long', year: 'numeric' });
    
    html += `<div class="date-month-group">`;
    html += `<h3 class="date-month-title">${monthName.charAt(0).toUpperCase() + monthName.slice(1)}</h3>`;
    html += `<div class="date-grid">`;
    
    dates.forEach(date => {
      // Normalizar propiedades (priorizar PascalCase del backend)
      const dateId = date.Id || date.id;
      // Si no hay ID (fecha principal del tour), usar un identificador especial
      const displayDateId = dateId || 'tour-main-date';
      const tourDateTime = date.TourDateTime || date.tourDateTime;
      const availableSpots = Number(date.AvailableSpots ?? date.availableSpots ?? 0) || 0;
      
      if (!tourDateTime) {
        console.warn('Fecha sin TourDateTime:', date);
        return; // Saltar fechas sin fecha/hora
      }
      
      const dateObj = new Date(tourDateTime);
      if (isNaN(dateObj.getTime())) {
        console.warn('Fecha inválida:', tourDateTime);
        return; // Saltar fechas inválidas
      }
      
      const isSelected = selectedTourDateId === dateId || (selectedTourDateId === 'tour-main-date' && !dateId);
      const isPast = dateObj < now;
      const isLowAvailability = availableSpots <= 3;
      
      html += `
        <div class="date-card ${isSelected ? 'selected' : ''} ${isPast ? 'disabled' : ''} ${isLowAvailability ? 'low-availability' : ''}" 
             data-date-id="${displayDateId}" 
             onclick="${!isPast ? `selectDate('${displayDateId}')` : ''}">
          <div class="date-day">${dateObj.getDate()}</div>
          <div class="date-weekday">${dateObj.toLocaleDateString('es-PA', { weekday: 'short' })}</div>
          <div class="date-time">${dateObj.toLocaleTimeString('es-PA', { hour: '2-digit', minute: '2-digit' })}</div>
          <div class="date-spots">${availableSpots} cupos</div>
          ${isLowAvailability ? '<div class="date-warning">Últimos cupos</div>' : ''}
        </div>
      `;
    });
    
    html += `</div></div>`;
  });
  
  html += '</div>';
  dateSelection.innerHTML = html;
}

function selectDate(dateId) {
  // Si dateId es 'tour-main-date', significa que es la fecha principal del tour (sin ID específico)
  // En ese caso, mantener selectedTourDateId como 'tour-main-date' para identificarlo
  selectedTourDateId = dateId;
  
  // Actualizar UI
  document.querySelectorAll('.date-card').forEach(card => {
    card.classList.remove('selected');
  });
  
  const selectedCard = document.querySelector(`[data-date-id="${dateId}"]`);
  if (selectedCard) {
    selectedCard.classList.add('selected');
  }
  
  // Ocultar error si existe
  const dateError = document.getElementById('dateError');
  if (dateError) {
    dateError.style.display = 'none';
  }
  
  // Actualizar resumen
  updateOrderSummary();
}

// Imágenes de referencia para usar como fallback
const DEFAULT_TOUR_IMAGES_CHECKOUT = [
  'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400',
  'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
  'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
  'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=400',
  'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400',
  'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'
];

function getDefaultTourImageCheckout(tourId = '') {
  if (!tourId) return DEFAULT_TOUR_IMAGES_CHECKOUT[0];
  const hash = tourId.toString().split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
  return DEFAULT_TOUR_IMAGES_CHECKOUT[hash % DEFAULT_TOUR_IMAGES_CHECKOUT.length];
}

function updateTourSummary() {
  if (!currentTour) {
    console.error('No hay tour cargado para mostrar en el resumen');
    return;
  }

  const summaryDiv = document.getElementById('tourSummary');
  
  // Normalizar propiedades (priorizar PascalCase del backend)
  const tourId = currentTour.Id || currentTour.id || '';
  const tourName = currentTour.Name || currentTour.name || 'Tour sin nombre';
  const tourLocation = currentTour.Location || currentTour.location || 'Ubicación no especificada';
  const durationHours = currentTour.DurationHours ?? currentTour.durationHours ?? 0;
  const availableSpots = Number(currentTour.AvailableSpots ?? currentTour.availableSpots ?? 0) || 0;
  
  // Obtener imagen (priorizar PascalCase)
  const tourImages = currentTour.TourImages || currentTour.tourImages || [];
  let imageUrl = null;
  if (tourImages && tourImages.length > 0) {
    const primaryImage = tourImages.find(img => img.IsPrimary === true || img.isPrimary === true);
    if (primaryImage) {
      imageUrl = primaryImage.ImageUrl || primaryImage.imageUrl;
    } else {
      imageUrl = tourImages[0]?.ImageUrl || tourImages[0]?.imageUrl;
    }
  }
  
  // Fallbacks
  if (!imageUrl) {
    imageUrl = currentTour.ImageUrl || currentTour.imageUrl || getDefaultTourImageCheckout(tourId);
  }

  summaryDiv.innerHTML = `
    <img src="${imageUrl}" alt="${tourName}" class="tour-summary-image" onerror="this.src='${getDefaultTourImageCheckout(tourId)}'" />
    <div class="tour-summary-info">
      <div class="tour-summary-name">${tourName}</div>
      <div class="tour-summary-details">
        <div>📍 ${tourLocation}</div>
        <div>⏱ ${durationHours} horas</div>
        <div>👥 ${availableSpots} cupos disponibles</div>
      </div>
    </div>
  `;
}

function updateOrderSummary() {
  if (!currentTour) {
    console.error('No hay tour cargado para actualizar el resumen de orden');
    return;
  }

  // Normalizar propiedades (priorizar PascalCase del backend)
  const tourName = currentTour.Name || currentTour.name || 'Tour sin nombre';
  const unitPrice = currentTour.Price ?? currentTour.price ?? 0;
  
  const summaryTourNameEl = document.getElementById('summaryTourName');
  if (summaryTourNameEl) {
    summaryTourNameEl.textContent = tourName;
  }
  
  const summaryParticipantsEl = document.getElementById('summaryParticipants');
  if (summaryParticipantsEl) {
    summaryParticipantsEl.textContent = numberOfParticipants;
  }
  
  // ✅ Usar función segura para formatear precio
  const summaryUnitPriceEl = document.getElementById('summaryUnitPrice');
  if (summaryUnitPriceEl) {
    summaryUnitPriceEl.textContent = formatPrice(unitPrice);
  }
  
  // Mostrar fecha seleccionada si existe
  const selectedDate = availableDates.find(d => {
    const dateId = d.Id || d.id;
    return dateId === selectedTourDateId || (selectedTourDateId === 'tour-main-date' && !dateId);
  });
  
  if (selectedDate) {
    const tourDateTime = selectedDate.TourDateTime || selectedDate.tourDateTime;
    if (tourDateTime) {
      try {
        const dateObj = new Date(tourDateTime);
        if (!isNaN(dateObj.getTime())) {
          const dateDisplay = document.getElementById('summaryDate');
          if (dateDisplay) {
            dateDisplay.textContent = dateObj.toLocaleDateString('es-PA', { 
              weekday: 'long', 
              year: 'numeric', 
              month: 'long', 
              day: 'numeric',
              hour: '2-digit',
              minute: '2-digit'
            });
          }
        }
      } catch (e) {
        console.warn('Error al formatear fecha:', e);
      }
    }
  } else if (!selectedTourDateId) {
    // Si no hay fecha seleccionada, mostrar mensaje por defecto
    const dateDisplay = document.getElementById('summaryDate');
    if (dateDisplay) {
      dateDisplay.textContent = 'Selecciona una fecha';
    }
  }
  
  // ✅ Calcular y formatear total de forma segura
  const price = Number(currentTour.Price ?? currentTour.price ?? 0);
  const total = price * numberOfParticipants;
  document.getElementById('summaryTotal').textContent = formatPrice(total);
}

function updateParticipants() {
  numberOfParticipants = parseInt(document.getElementById('numberOfParticipants').value) || 1;
  
  // Validar número de participantes
  if (numberOfParticipants < 1 || numberOfParticipants > 50) {
    numberOfParticipants = Math.max(1, Math.min(50, numberOfParticipants));
    document.getElementById('numberOfParticipants').value = numberOfParticipants;
  }
  
  const participantsList = document.getElementById('participantsList');
  participantsList.innerHTML = '';

  for (let i = 1; i <= numberOfParticipants; i++) {
    const participantCard = document.createElement('div');
    participantCard.className = 'participant-card';
    participantCard.setAttribute('data-participant-index', i);
    participantCard.innerHTML = `
      <div class="participant-header">Participante ${i}${i === 1 ? ' (Titular)' : ''}</div>
      <div class="form-group">
        <label class="form-label">Nombre <span class="required">*</span></label>
        <input type="text" class="form-input participant-firstname" placeholder="Nombre completo" required maxlength="100" pattern="[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+" />
        <span class="field-error participant-firstname-error"></span>
      </div>
      <div class="form-group">
        <label class="form-label">Apellido <span class="required">*</span></label>
        <input type="text" class="form-input participant-lastname" placeholder="Apellido completo" required maxlength="100" pattern="[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+" />
        <span class="field-error participant-lastname-error"></span>
      </div>
      <div class="form-group">
        <label class="form-label">Email ${i === 1 ? '<span class="required">*</span>' : ''}</label>
        <input type="email" class="form-input participant-email" placeholder="email@ejemplo.com" ${i === 1 ? 'required' : ''} maxlength="255" />
        <span class="field-error participant-email-error"></span>
      </div>
      <div class="form-group">
        <label class="form-label">Teléfono</label>
        <input type="tel" class="form-input participant-phone" placeholder="+507 6000-0000" maxlength="20" />
        <span class="field-error participant-phone-error"></span>
      </div>
      ${i > 1 ? `
      <div class="form-group">
        <label class="form-label">Fecha de Nacimiento (opcional)</label>
        <input type="date" class="form-input participant-dob" max="${new Date().toISOString().split('T')[0]}" />
        <span class="field-error participant-dob-error"></span>
      </div>
      ` : ''}
    `;
    participantsList.appendChild(participantCard);
    
    // Agregar validaciones en tiempo real
    setupParticipantValidation(participantCard, i);
  }

  updateOrderSummary();
}

function setupParticipantValidation(card, index) {
  const firstName = card.querySelector('.participant-firstname');
  const lastName = card.querySelector('.participant-lastname');
  const email = card.querySelector('.participant-email');
  const phone = card.querySelector('.participant-phone');
  const dob = card.querySelector('.participant-dob');

  // Validar nombre
  if (firstName) {
    firstName.addEventListener('blur', function() {
      const value = this.value.trim();
      const error = card.querySelector('.participant-firstname-error');
      if (!value) {
        error.textContent = 'El nombre es requerido';
        this.classList.add('input-error');
      } else if (!/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/.test(value)) {
        error.textContent = 'Solo se permiten letras y espacios';
        this.classList.add('input-error');
      } else {
        error.textContent = '';
        this.classList.remove('input-error');
      }
    });
  }

  // Validar apellido
  if (lastName) {
    lastName.addEventListener('blur', function() {
      const value = this.value.trim();
      const error = card.querySelector('.participant-lastname-error');
      if (!value) {
        error.textContent = 'El apellido es requerido';
        this.classList.add('input-error');
      } else if (!/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/.test(value)) {
        error.textContent = 'Solo se permiten letras y espacios';
        this.classList.add('input-error');
      } else {
        error.textContent = '';
        this.classList.remove('input-error');
      }
    });
  }

  // Validar email
  if (email) {
    email.addEventListener('blur', function() {
      const value = this.value.trim();
      const error = card.querySelector('.participant-email-error');
      const isRequired = index === 1;
      if (isRequired && !value) {
        error.textContent = 'El email es requerido para el titular';
        this.classList.add('input-error');
      } else if (value && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
        error.textContent = 'El email no tiene un formato válido';
        this.classList.add('input-error');
      } else {
        error.textContent = '';
        this.classList.remove('input-error');
      }
    });
  }

  // Validar teléfono
  if (phone) {
    phone.addEventListener('blur', function() {
      const value = this.value.trim();
      const error = card.querySelector('.participant-phone-error');
      if (value && !/^\+?[\d\s\-\(\)]+$/.test(value)) {
        error.textContent = 'El teléfono no tiene un formato válido';
        this.classList.add('input-error');
      } else {
        error.textContent = '';
        this.classList.remove('input-error');
      }
    });
  }

  // Validar fecha de nacimiento
  if (dob) {
    dob.addEventListener('change', function() {
      const value = this.value;
      const error = card.querySelector('.participant-dob-error');
      if (value) {
        const date = new Date(value);
        const today = new Date();
        const maxAge = new Date();
        maxAge.setFullYear(today.getFullYear() - 120);
        if (date >= today) {
          error.textContent = 'La fecha debe ser anterior a hoy';
          this.classList.add('input-error');
        } else if (date < maxAge) {
          error.textContent = 'La fecha no es válida';
          this.classList.add('input-error');
        } else {
          error.textContent = '';
          this.classList.remove('input-error');
        }
      } else {
        error.textContent = '';
        this.classList.remove('input-error');
      }
    });
  }
}

function selectPaymentMethod(method) {
  selectedPaymentMethod = method;
  
  // Actualizar radio buttons
  document.querySelectorAll('input[name="paymentMethod"]').forEach(radio => {
    radio.checked = radio.value === method;
  });

  // Actualizar cards con animación
  document.querySelectorAll('.payment-method-card').forEach(card => {
    if (card.dataset.method === method) {
      card.classList.add('selected');
      // Mostrar detalles con animación
      const details = card.querySelector('.payment-method-details');
      if (details) {
        details.style.display = 'block';
      }
    } else {
      card.classList.remove('selected');
      // Ocultar detalles
      const details = card.querySelector('.payment-method-details');
      if (details) {
        details.style.display = 'none';
      }
    }
  });
}

function setupPaymentInputs() {
  // Formato de número de tarjeta
  const cardNumber = document.getElementById('cardNumber');
  if (cardNumber) {
    cardNumber.addEventListener('input', function(e) {
      let value = e.target.value.replace(/\s/g, '');
      let formattedValue = value.match(/.{1,4}/g)?.join(' ') || value;
      e.target.value = formattedValue;
    });
  }

  // Formato de fecha de vencimiento
  const cardExpiry = document.getElementById('cardExpiry');
  if (cardExpiry) {
    cardExpiry.addEventListener('input', function(e) {
      let value = e.target.value.replace(/\D/g, '');
      if (value.length >= 2) {
        value = value.substring(0, 2) + '/' + value.substring(2, 4);
      }
      e.target.value = value;
    });
  }

  // Solo números para CVV
  const cardCvv = document.getElementById('cardCvv');
  if (cardCvv) {
    cardCvv.addEventListener('input', function(e) {
      e.target.value = e.target.value.replace(/\D/g, '');
    });
  }
}

function validateParticipants() {
  const participantCards = document.querySelectorAll('.participant-card');
  let isValid = true;
  const errors = [];

  participantCards.forEach((card, index) => {
    const firstName = card.querySelector('.participant-firstname')?.value.trim();
    const lastName = card.querySelector('.participant-lastname')?.value.trim();
    const email = card.querySelector('.participant-email')?.value.trim();
    const phone = card.querySelector('.participant-phone')?.value.trim();
    const dob = card.querySelector('.participant-dob')?.value;

    // Validar nombre
    if (!firstName) {
      errors.push(`Participante ${index + 1}: El nombre es requerido`);
      card.querySelector('.participant-firstname')?.classList.add('input-error');
      isValid = false;
    } else if (!/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/.test(firstName)) {
      errors.push(`Participante ${index + 1}: El nombre solo puede contener letras`);
      card.querySelector('.participant-firstname')?.classList.add('input-error');
      isValid = false;
    }

    // Validar apellido
    if (!lastName) {
      errors.push(`Participante ${index + 1}: El apellido es requerido`);
      card.querySelector('.participant-lastname')?.classList.add('input-error');
      isValid = false;
    } else if (!/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/.test(lastName)) {
      errors.push(`Participante ${index + 1}: El apellido solo puede contener letras`);
      card.querySelector('.participant-lastname')?.classList.add('input-error');
      isValid = false;
    }

    // Validar email (requerido solo para el titular)
    if (index === 0 && !email) {
      errors.push(`Participante ${index + 1}: El email es requerido para el titular`);
      card.querySelector('.participant-email')?.classList.add('input-error');
      isValid = false;
    } else if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      errors.push(`Participante ${index + 1}: El email no tiene un formato válido`);
      card.querySelector('.participant-email')?.classList.add('input-error');
      isValid = false;
    }

    // Validar teléfono
    if (phone && !/^\+?[\d\s\-\(\)]+$/.test(phone)) {
      errors.push(`Participante ${index + 1}: El teléfono no tiene un formato válido`);
      card.querySelector('.participant-phone')?.classList.add('input-error');
      isValid = false;
    }

    // Validar fecha de nacimiento
    if (dob) {
      const date = new Date(dob);
      const today = new Date();
      if (date >= today) {
        errors.push(`Participante ${index + 1}: La fecha de nacimiento debe ser anterior a hoy`);
        card.querySelector('.participant-dob')?.classList.add('input-error');
        isValid = false;
      }
    }
  });

  if (!isValid) {
    const errorMessage = 'Por favor corrige los siguientes errores:\n\n' + errors.join('\n');
    showNotificationError(errorMessage.replace(/\n/g, '<br>'));
    // Scroll al primer error
    const firstError = document.querySelector('.input-error');
    if (firstError) {
      firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
      firstError.focus();
    }
  }

  return isValid;
}

function validatePaymentMethod() {
  if (selectedPaymentMethod === 'stripe') {
    const cardNumber = document.getElementById('cardNumber').value.replace(/\s/g, '');
    const cardExpiry = document.getElementById('cardExpiry').value;
    const cardCvv = document.getElementById('cardCvv').value;
    const cardName = document.getElementById('cardName').value.trim();

    // Validar número de tarjeta (algoritmo de Luhn básico)
    if (!cardNumber || cardNumber.length < 13 || cardNumber.length > 19) {
      const msg = 'Por favor ingresa un número de tarjeta válido (13-19 dígitos)';
      showNotificationError(msg);
      document.getElementById('cardNumber').classList.add('input-error');
      document.getElementById('cardNumber').focus();
      return false;
    }

    // Validar formato de fecha MM/AA
    if (!cardExpiry || !/^\d{2}\/\d{2}$/.test(cardExpiry)) {
      const msg = 'Por favor ingresa una fecha de vencimiento válida (MM/AA)';
      showNotificationError(msg);
      document.getElementById('cardExpiry').classList.add('input-error');
      document.getElementById('cardExpiry').focus();
      return false;
    }

    // Validar que la fecha no esté vencida
    const [month, year] = cardExpiry.split('/');
    const expiryDate = new Date(2000 + parseInt(year), parseInt(month) - 1);
    const today = new Date();
    if (expiryDate < today) {
      const msg = 'La tarjeta está vencida';
      showNotificationError(msg);
      document.getElementById('cardExpiry').classList.add('input-error');
      document.getElementById('cardExpiry').focus();
      return false;
    }

    // Validar CVV
    if (!cardCvv || cardCvv.length < 3 || cardCvv.length > 4) {
      const msg = 'Por favor ingresa un CVV válido (3-4 dígitos)';
      showNotificationError(msg);
      document.getElementById('cardCvv').classList.add('input-error');
      document.getElementById('cardCvv').focus();
      return false;
    }

    // Validar nombre
    if (!cardName || cardName.length < 2) {
      const msg = 'Por favor ingresa el nombre completo en la tarjeta';
      showNotificationError(msg);
      document.getElementById('cardName').classList.add('input-error');
      document.getElementById('cardName').focus();
      return false;
    }
  }

  if (selectedPaymentMethod === 'yappy') {
    const phone = document.getElementById('yappyPhone').value.trim();
    if (!phone) {
      const msg = 'Por favor ingresa tu número de teléfono para Yappy';
      showNotificationError(msg);
      document.getElementById('yappyPhone').classList.add('input-error');
      document.getElementById('yappyPhone').focus();
      return false;
    }
    if (!/^\+?[\d\s\-\(\)]+$/.test(phone)) {
      const msg = 'Por favor ingresa un número de teléfono válido';
      showNotificationError(msg);
      document.getElementById('yappyPhone').classList.add('input-error');
      document.getElementById('yappyPhone').focus();
      return false;
    }
  }

  return true;
}

async function processPayment() {
  const btn = document.getElementById('checkoutBtn');
  const modal = document.getElementById('paymentModal');
  const statusText = document.getElementById('paymentStatus');

  // Limpiar errores previos
  document.querySelectorAll('.input-error').forEach(el => el.classList.remove('input-error'));

  // Validar fecha seleccionada
  if (!selectedTourDateId) {
    const dateError = document.getElementById('dateError');
    dateError.textContent = 'Por favor selecciona una fecha para el tour';
    dateError.style.display = 'block';
    document.getElementById('dateSelection').scrollIntoView({ behavior: 'smooth', block: 'center' });
    return;
  }
  
  // Validar que la fecha tenga cupos suficientes
  // Nota: selectedTourDateId puede ser null si se seleccionó la fecha principal del tour
  const selectedDate = availableDates.find(d => {
    const dateId = d.Id || d.id;
    return dateId === selectedTourDateId || (selectedTourDateId === 'tour-main-date' && dateId === null);
  });
  
  if (!selectedDate) {
    const dateError = document.getElementById('dateError');
    dateError.textContent = 'La fecha seleccionada ya no está disponible';
    dateError.style.display = 'block';
    return;
  }
  
  // Verificar cupos de la fecha seleccionada (si es una fecha específica)
  // Si es la fecha principal del tour (selectedTourDateId === 'tour-main-date' o null), 
  // los cupos se validarán más adelante usando los del tour
  if (selectedTourDateId && selectedTourDateId !== 'tour-main-date') {
    const availableSpots = Number(selectedDate.AvailableSpots ?? selectedDate.availableSpots ?? 0) || 0;
    console.log('🔍 [processPayment] Validando cupos de fecha específica:', {
      dateId: selectedTourDateId,
      availableSpots,
      numberOfParticipants
    });
    
    if (availableSpots < numberOfParticipants) {
      const dateError = document.getElementById('dateError');
      dateError.textContent = `Solo hay ${availableSpots} cupo(s) disponible(s) para esta fecha`;
      dateError.style.display = 'block';
      return;
    }
  } else {
    console.log('🔍 [processPayment] Usando fecha principal del tour, cupos se validarán con los del tour');
  }
  
  // Validar participantes
  if (!validateParticipants()) {
    return;
  }

  // Verificar que el usuario esté autenticado
  let userId = localStorage.getItem('userId');
  
  // Si no hay userId pero hay token, intentar obtener el usuario actual
  if (!userId) {
    const token = localStorage.getItem('accessToken') || localStorage.getItem('authToken');
    if (token) {
      try {
        console.log('🔍 [processPayment] No hay userId en localStorage, obteniendo usuario actual...');
        const currentUser = await api.getCurrentUser();
        userId = currentUser?.Id || currentUser?.id;
        if (userId) {
          localStorage.setItem('userId', userId);
          console.log('✅ [processPayment] userId obtenido y guardado:', userId);
        }
      } catch (error) {
        console.warn('⚠️ [processPayment] Error al obtener usuario actual:', error);
      }
    }
  }
  
  if (!userId) {
    const msg = 'Debes iniciar sesión para realizar una reserva';
    showNotificationError(msg);
    setTimeout(() => {
      window.location.href = '/login.html?redirect=' + encodeURIComponent(window.location.href);
    }, 2000);
    return;
  }

  // Verificar que haya cupos disponibles
  if (!currentTour) {
    const msg = 'No hay información del tour disponible';
    showNotificationError(msg);
    return;
  }
  
  // Determinar cupos disponibles: si hay fecha seleccionada, usar cupos de esa fecha, sino usar cupos del tour
  let availableSpotsCheck = 0;
  if (selectedTourDateId && selectedDate) {
    // Si hay una fecha específica seleccionada, usar sus cupos
    const dateSpots = selectedDate.AvailableSpots ?? selectedDate.availableSpots ?? 0;
    availableSpotsCheck = Number(dateSpots) || 0;
    console.log('🔍 [processPayment] Verificando cupos de fecha seleccionada:', {
      dateId: selectedTourDateId,
      selectedDate: selectedDate,
      availableSpotsRaw: dateSpots,
      availableSpots: availableSpotsCheck,
      numberOfParticipants: numberOfParticipants,
      typeAvailable: typeof availableSpotsCheck,
      typeRequired: typeof numberOfParticipants
    });
  } else {
    // Si no hay fecha específica, usar cupos del tour general
    const tourSpots = currentTour.AvailableSpots ?? currentTour.availableSpots ?? 0;
    availableSpotsCheck = Number(tourSpots) || 0;
    console.log('🔍 [processPayment] Verificando cupos del tour general:', {
      tourId: currentTour.Id || currentTour.id,
      currentTour: currentTour,
      availableSpotsRaw: tourSpots,
      availableSpots: availableSpotsCheck,
      numberOfParticipants: numberOfParticipants,
      typeAvailable: typeof availableSpotsCheck,
      typeRequired: typeof numberOfParticipants
    });
  }
  
  // Asegurar que numberOfParticipants sea un número - USAR EL MISMO VALOR QUE SE ENVIARÁ EN EL PAYLOAD
  const numParticipants = Number(numberOfParticipants) || 1;
  
  // 🔍 LOG: Validación de cupos antes de proceder
  console.log('🔍 [processPayment] Validación de cupos (antes de crear reserva):', {
    availableSpots: availableSpotsCheck,
    availableSpotsType: typeof availableSpotsCheck,
    numberOfParticipants: numParticipants,
    numberOfParticipantsType: typeof numParticipants,
    numberOfParticipantsRaw: numberOfParticipants,
    numberOfParticipantsRawType: typeof numberOfParticipants,
    comparison: `${availableSpotsCheck} < ${numParticipants} = ${availableSpotsCheck < numParticipants}`,
    willProceed: availableSpotsCheck >= numParticipants
  });
  
  if (availableSpotsCheck < numParticipants) {
    const msg = `No hay suficientes cupos disponibles. Solo hay ${availableSpotsCheck} cupo(s) disponible(s) y necesitas ${numParticipants}`;
    console.warn('⚠️ [processPayment] Cupos insuficientes - BLOQUEANDO creación de reserva:', {
      available: availableSpotsCheck,
      required: numParticipants,
      comparison: `${availableSpotsCheck} < ${numParticipants} = ${availableSpotsCheck < numParticipants}`
    });
    showNotificationError(msg);
    return;
  }
  
  console.log('✅ [processPayment] Cupos verificados correctamente - PERMITIENDO creación de reserva:', {
    available: availableSpotsCheck,
    required: numParticipants,
    comparison: `${availableSpotsCheck} >= ${numParticipants} = ${availableSpotsCheck >= numParticipants}`
  });

  // Mostrar modal de procesamiento
  modal.style.display = 'flex';
  btn.disabled = true;
  statusText.textContent = 'Creando reserva...';

  try {
    // Obtener datos de participantes
    const participants = [];
    const participantCards = document.querySelectorAll('.participant-card');
    
    // Asegurar que tenemos exactamente numberOfParticipants participantes
    if (participantCards.length !== numParticipants) {
      const errorMsg = `Error: Se esperaban ${numParticipants} participante(s) pero se encontraron ${participantCards.length}. Por favor, recarga la página.`;
      console.error('❌ [processPayment]', errorMsg);
      showNotificationError(errorMsg);
      modal.style.display = 'none';
      btn.disabled = false;
      loadingManager.hideGlobal();
      return;
    }
    
    participantCards.forEach((card, index) => {
      const firstName = card.querySelector('.participant-firstname')?.value.trim() || '';
      const lastName = card.querySelector('.participant-lastname')?.value.trim() || '';
      const email = card.querySelector('.participant-email')?.value.trim() || '';
      const phone = card.querySelector('.participant-phone')?.value.trim() || '';
      const dateOfBirth = card.querySelector('.participant-dob')?.value || null;

      // Validar que nombre y apellido estén presentes
      if (!firstName || !lastName) {
        const errorMsg = `Participante ${index + 1}: El nombre y apellido son requeridos.`;
        console.error('❌ [processPayment]', errorMsg);
        showNotificationError(errorMsg);
        modal.style.display = 'none';
        btn.disabled = false;
        loadingManager.hideGlobal();
        return;
      }

      // Construir objeto participante con formato correcto (camelCase para JSON)
      const participant = {
        firstName: firstName,
        lastName: lastName
      };
      
      // Agregar campos opcionales solo si tienen valor
      if (email) {
        participant.email = email;
      }
      if (phone) {
        participant.phone = phone;
      }
      if (dateOfBirth) {
        // Convertir fecha a ISO string (el backend espera DateTime)
        const dobDate = new Date(dateOfBirth);
        if (!isNaN(dobDate.getTime())) {
          participant.dateOfBirth = dobDate.toISOString();
        }
      }
      
      participants.push(participant);
    });
    
    // Validar que tenemos exactamente el número correcto de participantes
    if (participants.length !== numParticipants) {
      const errorMsg = `Error: Se esperaban ${numParticipants} participante(s) pero solo se encontraron ${participants.length} válidos. Por favor, completa todos los campos.`;
      console.error('❌ [processPayment]', errorMsg);
      showNotificationError(errorMsg);
      modal.style.display = 'none';
      btn.disabled = false;
      loadingManager.hideGlobal();
      return;
    }

    // Validar que el tour tenga cupos disponibles (usar la misma lógica que arriba)
    let availableSpotsForBooking = 0;
    if (selectedTourDateId && selectedDate) {
      const rawSpots = selectedDate.AvailableSpots ?? selectedDate.availableSpots ?? 0;
      availableSpotsForBooking = Number(rawSpots) || 0;
    } else {
      const rawSpots = currentTour.AvailableSpots ?? currentTour.availableSpots ?? 0;
      availableSpotsForBooking = Number(rawSpots) || 0;
    }
    
    // Asegurar que numberOfParticipants sea un número
    const numParticipantsFinal = Number(numberOfParticipants) || 1;
    
    console.log('🔍 [processPayment] Validación final de cupos antes de crear reserva:', {
      available: availableSpotsForBooking,
      availableType: typeof availableSpotsForBooking,
      required: numParticipantsFinal,
      requiredType: typeof numParticipantsFinal,
      hasSelectedDate: !!selectedTourDateId,
      comparison: `${availableSpotsForBooking} < ${numParticipantsFinal} = ${availableSpotsForBooking < numParticipantsFinal}`
    });
    
    if (availableSpotsForBooking < numParticipantsFinal) {
      statusText.textContent = `Error: Solo hay ${availableSpotsForBooking} cupo(s) disponible(s) y necesitas ${numParticipantsFinal}`;
      await sleep(2000);
      modal.style.display = 'none';
      btn.disabled = false;
      return;
    }

    // Validación final: Recargar el tour para verificar cupos actualizados justo antes de crear la reserva
    statusText.textContent = 'Verificando disponibilidad...';
    try {
      const updatedTour = await api.getTour(currentTour.Id || currentTour.id);
      if (updatedTour) {
        // Actualizar currentTour con datos frescos
        currentTour = updatedTour;
        
        // Verificar cupos una vez más con datos actualizados
        let finalAvailableSpots = 0;
        if (selectedTourDateId && selectedTourDateId !== 'tour-main-date') {
          // Si hay fecha específica, verificar cupos de esa fecha
          try {
            const updatedDates = await api.getTourDates(currentTour.Id || currentTour.id);
            if (Array.isArray(updatedDates) && updatedDates.length > 0) {
              const updatedDate = updatedDates.find(d => {
                const dateId = d.Id || d.id;
                return dateId === selectedTourDateId;
              });
              if (updatedDate) {
                finalAvailableSpots = Number(updatedDate.AvailableSpots ?? updatedDate.availableSpots ?? 0);
              } else {
                // Si no se encuentra la fecha, usar cupos del tour
                finalAvailableSpots = Number(currentTour.AvailableSpots ?? currentTour.availableSpots ?? 0);
              }
            } else {
              // Si no hay fechas específicas, usar cupos del tour
              finalAvailableSpots = Number(currentTour.AvailableSpots ?? currentTour.availableSpots ?? 0);
            }
          } catch (dateError) {
            console.warn('⚠️ [processPayment] Error al obtener fechas actualizadas, usando cupos del tour:', dateError);
            finalAvailableSpots = Number(currentTour.AvailableSpots ?? currentTour.availableSpots ?? 0);
          }
        } else {
          // Usar cupos del tour general
          finalAvailableSpots = Number(currentTour.AvailableSpots ?? currentTour.availableSpots ?? 0);
        }
        
        // Usar el mismo valor que se enviará en el payload (declarar ANTES de usarlo)
        const numParticipantsForValidation = Number(numberOfParticipants) || 1;
        
        console.log('🔍 [processPayment] Validación final con datos actualizados:', {
          available: finalAvailableSpots,
          availableType: typeof finalAvailableSpots,
          required: numParticipantsForValidation,
          requiredType: typeof numParticipantsForValidation,
          comparison: `${finalAvailableSpots} < ${numParticipantsForValidation} = ${finalAvailableSpots < numParticipantsForValidation}`
        });
        if (finalAvailableSpots < numParticipantsForValidation) {
          // Cerrar modal de pago
          modal.style.display = 'none';
          btn.disabled = false;
          loadingManager.hideGlobal();
          
          // Mostrar mensaje claro y amigable
          showNotificationError(
            `Lo sentimos, este tour ya no tiene cupos disponibles. Solo quedan ${finalAvailableSpots} cupo(s) disponible(s) y necesitas ${numParticipantsForValidation}. Por favor, selecciona otra fecha o reduce el número de participantes.`
          );
          
          // Recargar fechas disponibles para actualizar la UI (usar tourId estable)
          const tourIdForReload = currentTour?.Id || currentTour?.id || tourIdForBooking;
          if (tourIdForReload) {
            await loadAvailableDates(tourIdForReload);
          } else {
            console.warn('⚠️ [processPayment] No se pudo obtener tourId para recargar fechas');
          }
          return;
        }
      }
    } catch (error) {
      console.warn('⚠️ [processPayment] No se pudo verificar disponibilidad actualizada, continuando...', error);
      // Continuar con la reserva si no se puede verificar (no bloquear el flujo)
    }

    // Asegurar que numberOfParticipants sea un número explícito y consistente
    const finalNumberOfParticipants = Number(numberOfParticipants) || 1;
    
    // Validar que tenemos tourId válido
    const tourIdForBooking = currentTour?.Id || currentTour?.id;
    if (!tourIdForBooking) {
      const errorMsg = 'Error: No se pudo obtener el ID del tour. Por favor, recarga la página.';
      console.error('❌ [processPayment]', errorMsg, { currentTour });
      showNotificationError(errorMsg);
      modal.style.display = 'none';
      btn.disabled = false;
      loadingManager.hideGlobal();
      return;
    }

    // Mostrar loading global
    loadingManager.showGlobal('Procesando tu reserva...');

    // Crear la reserva primero
    statusText.textContent = 'Creando reserva...';
    const countrySelect = document.getElementById('countrySelect');
    const countryId = countrySelect?.value || null;
    
    // Si selectedTourDateId es 'tour-main-date', significa que se seleccionó la fecha principal del tour
    // En ese caso, no enviar tourDateId (será null)
    const tourDateId = selectedTourDateId === 'tour-main-date' ? null : selectedTourDateId;
    
    // Preparar payload de booking con valores explícitos y consistentes
    const bookingData = {
      tourId: tourIdForBooking,
      tourDateId: tourDateId,
      numberOfParticipants: finalNumberOfParticipants, // Usar el valor convertido explícitamente
      countryId: countryId || undefined,
      participants: participants
    };

    // 🔍 LOGS DETALLADOS ANTES DE POST /api/bookings
    console.log('📤 [processPayment] Preparando POST /api/bookings con payload:', {
      tourId: bookingData.tourId,
      tourDateId: bookingData.tourDateId,
      numberOfParticipants: bookingData.numberOfParticipants,
      numberOfParticipantsType: typeof bookingData.numberOfParticipants,
      countryId: bookingData.countryId,
      participantsCount: bookingData.participants?.length || 0,
      payloadCompleto: bookingData
    });
    
    console.log('🔍 [processPayment] Estado actual del tour:', {
      tourId: tourIdForBooking,
      tourName: currentTour?.Name || currentTour?.name,
      availableSpots: currentTour?.AvailableSpots ?? currentTour?.availableSpots,
      availableSpotsType: typeof (currentTour?.AvailableSpots ?? currentTour?.availableSpots),
      maxCapacity: currentTour?.MaxCapacity ?? currentTour?.maxCapacity,
      isActive: currentTour?.IsActive ?? currentTour?.isActive
    });
    
    console.log('🔍 [processPayment] Validación de cupos vs payload:', {
      cuposDisponibles: currentTour?.AvailableSpots ?? currentTour?.availableSpots ?? 0,
      cuposSolicitados: finalNumberOfParticipants,
      comparacion: `${currentTour?.AvailableSpots ?? currentTour?.availableSpots ?? 0} >= ${finalNumberOfParticipants}`,
      resultado: (currentTour?.AvailableSpots ?? currentTour?.availableSpots ?? 0) >= finalNumberOfParticipants
    });

    let bookingResponse;
    try {
      // Validar que el payload tenga todos los campos requeridos antes de enviar
      console.log('🔍 [processPayment] Validando payload antes de enviar:', {
        tourId: bookingData.tourId,
        tourDateId: bookingData.tourDateId,
        numberOfParticipants: bookingData.numberOfParticipants,
        participantsCount: bookingData.participants?.length || 0,
        countryId: bookingData.countryId,
        participants: bookingData.participants
      });
      
      // Validar que numberOfParticipants coincida con la cantidad de participantes
      if (bookingData.participants && bookingData.participants.length !== bookingData.numberOfParticipants) {
        const errorMsg = `El número de participantes (${bookingData.numberOfParticipants}) no coincide con la lista proporcionada (${bookingData.participants.length}). Por favor, verifica los datos.`;
        console.error('❌ [processPayment]', errorMsg);
        showNotificationError(errorMsg);
        modal.style.display = 'none';
        btn.disabled = false;
        loadingManager.hideGlobal();
        return;
      }
      
      // Validar que todos los participantes tengan nombre y apellido
      if (bookingData.participants) {
        const invalidParticipants = bookingData.participants.filter(p => 
          !p.firstName || !p.lastName || p.firstName.trim() === '' || p.lastName.trim() === ''
        );
        if (invalidParticipants.length > 0) {
          const errorMsg = `Por favor, completa el nombre y apellido de todos los participantes.`;
          console.error('❌ [processPayment]', errorMsg, invalidParticipants);
          showNotificationError(errorMsg);
          modal.style.display = 'none';
          btn.disabled = false;
          loadingManager.hideGlobal();
          return;
        }
      }
      
      bookingResponse = await api.createBooking(bookingData);
    } catch (bookingError) {
      console.error('❌ [processPayment] Error al crear reserva:', bookingError);
      
      // Cerrar modal de pago
      modal.style.display = 'none';
      btn.disabled = false;
      loadingManager.hideGlobal();
      
      // Extraer mensaje de error más específico
      let errorMessage = 'Error al crear la reserva. Por favor, intenta de nuevo.';
      
      if (bookingError.message) {
        errorMessage = bookingError.message;
      } else if (bookingError.response) {
        // Intentar extraer mensaje del response
        if (bookingError.response.errors) {
          // Errores de validación de FluentValidation
          const validationErrors = Object.values(bookingError.response.errors).flat();
          if (validationErrors.length > 0) {
            errorMessage = validationErrors.join('\n');
          }
        } else if (bookingError.response.message) {
          errorMessage = bookingError.response.message;
        } else if (bookingError.response.title) {
          errorMessage = bookingError.response.title;
        }
      }
      
      // Manejar específicamente el error de cupos insuficientes
      if (errorMessage.includes('cupos') || 
          errorMessage.includes('cupo') ||
          errorMessage.includes('disponibles') ||
          errorMessage.includes('INSUFFICIENT_SPOTS')) {
        errorMessage = 'Lo sentimos, este tour ya no tiene cupos disponibles en este momento. Por favor, selecciona otra fecha o intenta más tarde.';
        // Recargar fechas disponibles para actualizar la UI
        await loadAvailableDates();
      }
      
      // Mostrar mensaje de error
      showNotificationError(errorMessage);
      return;
    }
    const bookingId = bookingResponse.id;

    // Procesar pago según el método seleccionado
    if (selectedPaymentMethod === 'stripe') {
      if (!stripe || !stripePublishableKey) {
        throw new Error('Stripe no está configurado. Por favor recarga la página.');
      }

      statusText.textContent = 'Iniciando pago con Stripe...';
      
      // Crear el payment intent
      const paymentResponse = await api.createPayment(bookingId, 'USD', 'stripe');
      
      if (!paymentResponse.clientSecret) {
        throw new Error('No se pudo crear el payment intent');
      }

      statusText.textContent = 'Procesando pago...';
      
      // Usar Stripe para confirmar el pago
      // Nota: En producción, es mejor usar Stripe Elements para capturar los datos de la tarjeta de forma segura
      // Por ahora usamos confirmCardPayment con los datos del formulario
      const cardNumber = document.getElementById('cardNumber').value.replace(/\s/g, '');
      const cardExpiry = document.getElementById('cardExpiry').value.split('/');
      const cardCvv = document.getElementById('cardCvv').value;
      const cardName = document.getElementById('cardName').value;

      // Crear un payment method primero
      const { error: pmError, paymentMethod } = await stripe.createPaymentMethod({
        type: 'card',
        card: {
          number: cardNumber,
          exp_month: parseInt(cardExpiry[0]),
          exp_year: 2000 + parseInt(cardExpiry[1]),
          cvc: cardCvv
        },
        billing_details: {
          name: cardName
        }
      });

      if (pmError) {
        throw new Error(pmError.message);
      }

      // Confirmar el pago con el payment method
      const { error: confirmError, paymentIntent } = await stripe.confirmCardPayment(
        paymentResponse.clientSecret,
        {
          payment_method: paymentMethod.id
        }
      );

      if (confirmError) {
        throw new Error(confirmError.message);
      }

      // Confirmar el pago en el backend
      statusText.textContent = 'Confirmando pago...';
      await api.confirmPayment(paymentResponse.paymentIntentId);

      // Redirigir a página de éxito
      const totalAmount = bookingResponse.totalAmount || (currentTour.price * numberOfParticipants);
      loadingManager.hideGlobal();
      window.location.href = `/booking-success.html?bookingId=${bookingId}&amount=${totalAmount}`;
      
    } else if (selectedPaymentMethod === 'paypal') {
      statusText.textContent = 'Iniciando pago con PayPal...';
      
      // Crear el payment intent
      const paymentResponse = await api.createPayment(bookingId, 'USD', 'paypal');
      
      if (!paymentResponse.checkoutUrl) {
        throw new Error('No se pudo crear el checkout de PayPal');
      }

      statusText.textContent = 'Redirigiendo a PayPal...';
      
      // Redirigir a PayPal (en modo de pruebas, esto será una simulación)
      // En producción, esto redirigiría a PayPal Sandbox o Live
      if (paymentResponse.checkoutUrl.includes('sandbox.paypal.com') || paymentResponse.checkoutUrl.includes('localhost')) {
        // Modo simulación - confirmar directamente
        await sleep(1500);
        statusText.textContent = 'Simulando pago de PayPal...';
        await api.confirmPayment(paymentResponse.paymentIntentId);
        
        const totalAmount = bookingResponse.totalAmount || (currentTour.price * numberOfParticipants);
        loadingManager.hideGlobal();
        window.location.href = `/booking-success.html?bookingId=${bookingId}&amount=${totalAmount}`;
      } else {
        // Redirigir a PayPal
        loadingManager.hideGlobal();
        window.location.href = paymentResponse.checkoutUrl;
      }
      
    } else if (selectedPaymentMethod === 'yappy') {
      const phone = document.getElementById('yappyPhone').value.trim();
      
      if (!phone) {
        throw new Error('Por favor ingresa tu número de teléfono para Yappy');
      }

      statusText.textContent = 'Generando código QR de Yappy...';
      
      // Crear el payment intent
      const paymentResponse = await api.createPayment(bookingId, 'USD', 'yappy');
      
      if (!paymentResponse.checkoutUrl) {
        throw new Error('No se pudo generar el código QR de Yappy');
      }

      statusText.textContent = 'Mostrando código QR...';
      
      // En modo de pruebas, simular la confirmación después de mostrar el QR
      // En producción, esto mostraría un modal con el QR y esperaría el webhook
      await sleep(2000);
      statusText.textContent = 'Simulando escaneo de QR...';
      await sleep(1500);
      
      await api.confirmPayment(paymentResponse.paymentIntentId);
      
      const totalAmount = bookingResponse.totalAmount || (currentTour.price * numberOfParticipants);
      loadingManager.hideGlobal();
      window.location.href = `/booking-success.html?bookingId=${bookingId}&amount=${totalAmount}`;
    }

  } catch (error) {
    console.error('Error processing payment:', error);
    loadingManager.hideGlobal();
    
    // Manejar específicamente errores de cupos
    if (error.message && (
      error.message.includes('cupos') || 
      error.message.includes('cupo') ||
      error.message.includes('disponibles') ||
      error.message.includes('INSUFFICIENT_SPOTS')
    )) {
      // Cerrar modal de pago
      modal.style.display = 'none';
      btn.disabled = false;
      
      // Mostrar mensaje claro y amigable
      showNotificationError(
        'Lo sentimos, este tour ya no tiene cupos disponibles en este momento. Por favor, selecciona otra fecha o intenta más tarde.'
      );
      
          // Recargar fechas disponibles para actualizar la UI (usar tourId estable)
          const tourIdForReload = currentTour?.Id || currentTour?.id || tourIdForBooking;
          if (tourIdForReload) {
            try {
              await loadAvailableDates(tourIdForReload);
            } catch (reloadError) {
              console.warn('⚠️ [processPayment] Error al recargar fechas:', reloadError);
            }
          } else {
            console.warn('⚠️ [processPayment] No se pudo obtener tourId para recargar fechas');
          }
    } else {
      // Para otros errores, mostrar mensaje genérico
      statusText.textContent = error.message || 'Error al procesar el pago. Por favor intenta de nuevo.';
      await sleep(3000);
      modal.style.display = 'none';
      btn.disabled = false;
    }
  }
}

function getPaymentMethodName(method) {
  const names = {
    'stripe': 'Tarjeta de Crédito',
    'paypal': 'PayPal',
    'yappy': 'Yappy'
  };
  return names[method] || method;
}

function generateBookingId() {
  return 'BK-' + Date.now().toString(36).toUpperCase();
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// Cerrar modal al hacer clic fuera
document.getElementById('paymentModal')?.addEventListener('click', function(e) {
  if (e.target === this) {
    // No permitir cerrar durante el procesamiento
    const btn = document.getElementById('checkoutBtn');
    if (btn.disabled) return;
    this.style.display = 'none';
  }
});
