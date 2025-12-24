// Checkout JavaScript para ToursPanama

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
    updateOrderSummary();
    
    // Cargar fechas disponibles
    await loadAvailableDates(tourId);
  } catch (error) {
    console.error('Error loading tour:', error);
    alert('Error al cargar el tour');
    window.location.href = '/';
  }
}

async function loadAvailableDates(tourId) {
  try {
    const dateSelection = document.getElementById('dateSelection');
    const dateError = document.getElementById('dateError');
    
    dateSelection.innerHTML = '<div class="date-loading">Cargando fechas disponibles...</div>';
    dateError.style.display = 'none';
    
    availableDates = await api.getTourDates(tourId);
    
    if (!availableDates || availableDates.length === 0) {
      dateSelection.innerHTML = `
        <div class="date-empty">
          <p style="color: var(--text-muted); margin: 20px 0;">No hay fechas disponibles para este tour en este momento.</p>
          <p style="color: var(--text-muted); font-size: 0.9rem;">Por favor, contacta con nosotros para más información.</p>
        </div>
      `;
      return;
    }
    
    // Mostrar calendario de fechas disponibles
    renderDateCalendar();
  } catch (error) {
    console.error('Error loading dates:', error);
    document.getElementById('dateSelection').innerHTML = `
      <div class="date-error">
        <p style="color: var(--error);">Error al cargar las fechas disponibles. Por favor, intenta de nuevo.</p>
      </div>
    `;
  }
}

function renderDateCalendar() {
  const dateSelection = document.getElementById('dateSelection');
  const now = new Date();
  
  // Agrupar fechas por mes
  const datesByMonth = {};
  availableDates.forEach(date => {
    const dateObj = new Date(date.tourDateTime);
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
    const firstDate = new Date(dates[0].tourDateTime);
    const monthName = firstDate.toLocaleDateString('es-PA', { month: 'long', year: 'numeric' });
    
    html += `<div class="date-month-group">`;
    html += `<h3 class="date-month-title">${monthName.charAt(0).toUpperCase() + monthName.slice(1)}</h3>`;
    html += `<div class="date-grid">`;
    
    dates.forEach(date => {
      const dateObj = new Date(date.tourDateTime);
      const isSelected = selectedTourDateId === date.id;
      const isPast = dateObj < now;
      const isLowAvailability = date.availableSpots <= 3;
      
      html += `
        <div class="date-card ${isSelected ? 'selected' : ''} ${isPast ? 'disabled' : ''} ${isLowAvailability ? 'low-availability' : ''}" 
             data-date-id="${date.id}" 
             onclick="${!isPast ? `selectDate('${date.id}')` : ''}">
          <div class="date-day">${dateObj.getDate()}</div>
          <div class="date-weekday">${dateObj.toLocaleDateString('es-PA', { weekday: 'short' })}</div>
          <div class="date-time">${dateObj.toLocaleTimeString('es-PA', { hour: '2-digit', minute: '2-digit' })}</div>
          <div class="date-spots">${date.availableSpots} cupos</div>
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
  document.getElementById('dateError').style.display = 'none';
  
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
  const summaryDiv = document.getElementById('tourSummary');
  const imageUrl = currentTour.tourImages?.[0]?.imageUrl || getDefaultTourImageCheckout(currentTour.id);

  summaryDiv.innerHTML = `
    <img src="${imageUrl}" alt="${currentTour.name}" class="tour-summary-image" onerror="this.src='${getDefaultTourImageCheckout(currentTour.id)}'" />
    <div class="tour-summary-info">
      <div class="tour-summary-name">${currentTour.name}</div>
      <div class="tour-summary-details">
        <div>📍 ${currentTour.location}</div>
        <div>⏱ ${currentTour.durationHours} horas</div>
        <div>👥 ${currentTour.availableSpots} cupos disponibles</div>
      </div>
    </div>
  `;
}

function updateOrderSummary() {
  document.getElementById('summaryTourName').textContent = currentTour.name;
  document.getElementById('summaryParticipants').textContent = numberOfParticipants;
  document.getElementById('summaryUnitPrice').textContent = `$${currentTour.price.toFixed(2)}`;
  
  // Mostrar fecha seleccionada si existe
  const selectedDate = availableDates.find(d => d.id === selectedTourDateId);
  if (selectedDate) {
    const dateObj = new Date(selectedDate.tourDateTime);
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
  
  const total = currentTour.price * numberOfParticipants;
  document.getElementById('summaryTotal').textContent = `$${total.toFixed(2)}`;
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
    alert('Por favor corrige los siguientes errores:\n\n' + errors.join('\n'));
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
      alert('Por favor ingresa un número de tarjeta válido (13-19 dígitos)');
      document.getElementById('cardNumber').classList.add('input-error');
      document.getElementById('cardNumber').focus();
      return false;
    }

    // Validar formato de fecha MM/AA
    if (!cardExpiry || !/^\d{2}\/\d{2}$/.test(cardExpiry)) {
      alert('Por favor ingresa una fecha de vencimiento válida (MM/AA)');
      document.getElementById('cardExpiry').classList.add('input-error');
      document.getElementById('cardExpiry').focus();
      return false;
    }

    // Validar que la fecha no esté vencida
    const [month, year] = cardExpiry.split('/');
    const expiryDate = new Date(2000 + parseInt(year), parseInt(month) - 1);
    const today = new Date();
    if (expiryDate < today) {
      alert('La tarjeta está vencida');
      document.getElementById('cardExpiry').classList.add('input-error');
      document.getElementById('cardExpiry').focus();
      return false;
    }

    // Validar CVV
    if (!cardCvv || cardCvv.length < 3 || cardCvv.length > 4) {
      alert('Por favor ingresa un CVV válido (3-4 dígitos)');
      document.getElementById('cardCvv').classList.add('input-error');
      document.getElementById('cardCvv').focus();
      return false;
    }

    // Validar nombre
    if (!cardName || cardName.length < 2) {
      alert('Por favor ingresa el nombre completo en la tarjeta');
      document.getElementById('cardName').classList.add('input-error');
      document.getElementById('cardName').focus();
      return false;
    }
  }

  if (selectedPaymentMethod === 'yappy') {
    const phone = document.getElementById('yappyPhone').value.trim();
    if (!phone) {
      alert('Por favor ingresa tu número de teléfono para Yappy');
      document.getElementById('yappyPhone').classList.add('input-error');
      document.getElementById('yappyPhone').focus();
      return false;
    }
    if (!/^\+?[\d\s\-\(\)]+$/.test(phone)) {
      alert('Por favor ingresa un número de teléfono válido');
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
  const selectedDate = availableDates.find(d => d.id === selectedTourDateId);
  if (!selectedDate) {
    const dateError = document.getElementById('dateError');
    dateError.textContent = 'La fecha seleccionada ya no está disponible';
    dateError.style.display = 'block';
    return;
  }
  
  if (selectedDate.availableSpots < numberOfParticipants) {
    const dateError = document.getElementById('dateError');
    dateError.textContent = `Solo hay ${selectedDate.availableSpots} cupo(s) disponible(s) para esta fecha`;
    dateError.style.display = 'block';
    return;
  }
  
  // Validar participantes
  if (!validateParticipants()) {
    return;
  }

  // Verificar que el usuario esté autenticado
  const userId = localStorage.getItem('userId');
  if (!userId) {
    alert('Debes iniciar sesión para realizar una reserva');
    window.location.href = '/login.html?redirect=' + encodeURIComponent(window.location.href);
    return;
  }

  // Verificar que haya cupos disponibles
  if (!currentTour || currentTour.availableSpots < numberOfParticipants) {
    alert('No hay suficientes cupos disponibles para este tour');
    return;
  }

  // Mostrar modal de procesamiento
  modal.style.display = 'flex';
  btn.disabled = true;
  statusText.textContent = 'Creando reserva...';

  try {
    // Obtener datos de participantes
    const participants = [];
    const participantCards = document.querySelectorAll('.participant-card');
    
    participantCards.forEach((card, index) => {
      const firstName = card.querySelector('.participant-firstname')?.value.trim() || '';
      const lastName = card.querySelector('.participant-lastname')?.value.trim() || '';
      const email = card.querySelector('.participant-email')?.value.trim() || '';
      const phone = card.querySelector('.participant-phone')?.value.trim() || '';
      const dateOfBirth = card.querySelector('.participant-dob')?.value || null;

      if (firstName && lastName) {
        participants.push({
          firstName: firstName,
          lastName: lastName,
          email: email || null,
          phone: phone || null,
          dateOfBirth: dateOfBirth ? new Date(dateOfBirth).toISOString() : null
        });
      }
    });

    // Validar que el tour tenga cupos disponibles
    if (currentTour.availableSpots < numberOfParticipants) {
      statusText.textContent = 'Error: No hay suficientes cupos disponibles';
      await sleep(2000);
      modal.style.display = 'none';
      btn.disabled = false;
      return;
    }

    // Mostrar loading global
    loadingManager.showGlobal('Procesando tu reserva...');

    // Crear la reserva primero
    statusText.textContent = 'Creando reserva...';
    const bookingData = {
      tourId: currentTour.id,
      tourDateId: selectedTourDateId,
      numberOfParticipants: numberOfParticipants,
      participants: participants
    };

    const bookingResponse = await api.createBooking(bookingData);
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
    statusText.textContent = error.message || 'Error al procesar el pago. Por favor intenta de nuevo.';
    await sleep(3000);
    modal.style.display = 'none';
    btn.disabled = false;
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
