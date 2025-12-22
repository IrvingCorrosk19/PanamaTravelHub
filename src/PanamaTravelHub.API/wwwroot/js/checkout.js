// Checkout JavaScript para ToursPanama

let currentTour = null;
let numberOfParticipants = 1;
let selectedPaymentMethod = 'stripe';

// Cargar información del tour desde URL
document.addEventListener('DOMContentLoaded', () => {
  loadTourFromUrl();
  updateParticipants();
  setupPaymentInputs();
});

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
  } catch (error) {
    console.error('Error loading tour:', error);
    alert('Error al cargar el tour');
    window.location.href = '/';
  }
}

function updateTourSummary() {
  const summaryDiv = document.getElementById('tourSummary');
  const imageUrl = currentTour.tourImages?.[0]?.imageUrl || 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400';

  summaryDiv.innerHTML = `
    <img src="${imageUrl}" alt="${currentTour.name}" class="tour-summary-image" onerror="this.src='https://via.placeholder.com/400x300'" />
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
  
  const total = currentTour.price * numberOfParticipants;
  document.getElementById('summaryTotal').textContent = `$${total.toFixed(2)}`;
}

function updateParticipants() {
  numberOfParticipants = parseInt(document.getElementById('numberOfParticipants').value) || 1;
  
  const participantsList = document.getElementById('participantsList');
  participantsList.innerHTML = '';

  for (let i = 1; i <= numberOfParticipants; i++) {
    const participantCard = document.createElement('div');
    participantCard.className = 'participant-card';
    participantCard.innerHTML = `
      <div class="participant-header">Participante ${i}${i === 1 ? ' (Titular)' : ''}</div>
      <div class="form-group">
        <label class="form-label">Nombre</label>
        <input type="text" class="form-input" placeholder="Nombre completo" required />
      </div>
      <div class="form-group">
        <label class="form-label">Email</label>
        <input type="email" class="form-input" placeholder="email@ejemplo.com" ${i === 1 ? 'required' : ''} />
      </div>
      <div class="form-group">
        <label class="form-label">Teléfono</label>
        <input type="tel" class="form-input" placeholder="+507 6000-0000" />
      </div>
      ${i > 1 ? `
      <div class="form-group">
        <label class="form-label">Fecha de Nacimiento (opcional)</label>
        <input type="date" class="form-input" />
      </div>
      ` : ''}
    `;
    participantsList.appendChild(participantCard);
  }

  updateOrderSummary();
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

async function processPayment() {
  const btn = document.getElementById('checkoutBtn');
  const modal = document.getElementById('paymentModal');
  const statusText = document.getElementById('paymentStatus');

  // Validar campos requeridos
  if (selectedPaymentMethod === 'stripe') {
    const cardNumber = document.getElementById('cardNumber').value.replace(/\s/g, '');
    const cardExpiry = document.getElementById('cardExpiry').value;
    const cardCvv = document.getElementById('cardCvv').value;
    const cardName = document.getElementById('cardName').value.trim();

    if (!cardNumber || cardNumber.length < 13) {
      alert('Por favor ingresa un número de tarjeta válido');
      return;
    }
    if (!cardExpiry || cardExpiry.length !== 5) {
      alert('Por favor ingresa una fecha de vencimiento válida (MM/AA)');
      return;
    }
    if (!cardCvv || cardCvv.length < 3) {
      alert('Por favor ingresa un CVV válido');
      return;
    }
    if (!cardName) {
      alert('Por favor ingresa el nombre en la tarjeta');
      return;
    }
  }

  if (selectedPaymentMethod === 'yappy') {
    const phone = document.getElementById('yappyPhone').value.trim();
    if (!phone) {
      alert('Por favor ingresa tu número de teléfono para Yappy');
      return;
    }
  }

  // Mostrar modal de procesamiento
  modal.style.display = 'flex';
  btn.disabled = true;

  // Simular procesamiento de pago
  statusText.textContent = 'Validando información...';
  await sleep(1500);

  statusText.textContent = 'Procesando pago con ' + getPaymentMethodName(selectedPaymentMethod) + '...';
  await sleep(2000);

  statusText.textContent = 'Autorizando transacción...';
  await sleep(1500);

  // Simular éxito
  statusText.textContent = '¡Pago procesado exitosamente!';
  await sleep(1000);

    // Crear reserva
    try {
      // Obtener datos de participantes
      const participants = [];
      const participantCards = document.querySelectorAll('.participant-card');
      
      participantCards.forEach((card, index) => {
        const inputs = card.querySelectorAll('input');
        const firstName = inputs[0]?.value.trim() || '';
        const lastName = inputs[1]?.value.trim() || '';
        const email = inputs[2]?.value.trim() || '';
        const phone = inputs[3]?.value.trim() || '';
        const dateOfBirth = inputs[4]?.value || null;

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

      const bookingData = {
        tourId: currentTour.id,
        tourDateId: null, // TODO: Obtener de selección de fecha
        numberOfParticipants: numberOfParticipants,
        participants: participants
      };

      // Llamar a API real
      await api.createBooking(bookingData);

      // Redirigir a página de confirmación
      const bookingId = response.id || generateBookingId();
      const totalAmount = response.totalAmount || (currentTour.price * numberOfParticipants);
      window.location.href = `/booking-success.html?bookingId=${bookingId}&amount=${totalAmount}`;
  } catch (error) {
    console.error('Error creating booking:', error);
    statusText.textContent = 'Error al procesar el pago. Por favor intenta de nuevo.';
    await sleep(2000);
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
