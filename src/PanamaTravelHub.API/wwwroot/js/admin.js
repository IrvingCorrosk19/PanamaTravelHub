// Admin Panel JavaScript
let revenueChart, bookingsStatusChart, topToursChart, timeseriesChart, toursReportChart;
let adminTourImages = []; // Imágenes para el formulario de tour (admin.html)

// Inicialización
document.addEventListener('DOMContentLoaded', async () => {
  // Verificar autenticación (seguridad temporalmente desactivada: no se verifica rol Admin)
  const token = localStorage.getItem('accessToken');
  if (!token) {
    window.location.href = '/login.html';
    return;
  }

  // Configurar navegación
  setupNavigation();
  
  // Cargar dashboard por defecto
  await loadDashboard();
  
  // Configurar logout
  document.getElementById('logoutLink')?.addEventListener('click', async (e) => {
    e.preventDefault();
    await api.logout();
    window.location.href = '/';
  });
});

// Navegación
function setupNavigation() {
  const navLinks = document.querySelectorAll('.admin-nav .nav-link');
  navLinks.forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      const section = link.getAttribute('data-section');
      if (section) {
        showSection(section);
      }
    });
  });
}

function showSection(sectionName) {
  // Ocultar todas las secciones
  document.querySelectorAll('.admin-content').forEach(section => {
    section.classList.remove('active');
  });
  
  // Mostrar sección seleccionada
  const section = document.getElementById(`${sectionName}-section`);
  if (section) {
    section.classList.add('active');
    
    // Actualizar título
    const titles = {
      'dashboard': 'Dashboard',
      'tours': 'Gestión de Tours',
      'bookings': 'Gestión de Reservas',
      'users': 'Gestión de Usuarios',
      'coupons': 'Gestión de Cupones',
      'reviews': 'Moderación de Reviews',
      'waitlist': 'Lista de Espera',
      'blog-comments': 'Comentarios de Blog',
      'homepage': 'CMS (Homepage)',
      'email-settings': 'Configuración de Email',
      'chatbot-settings': 'Configuración del Chatbot',
      'media': 'Biblioteca de Media',
      'pages': 'Gestión de Páginas',
      'reports': 'Reportes y Analytics',
      'analytics': 'Analytics y Conversión',
      'cms-blocks': 'Bloques CMS'
    };
    document.getElementById('pageTitle').textContent = titles[sectionName] || 'Admin Panel';
    
    // Actualizar nav activo
    document.querySelectorAll('.admin-nav .nav-link').forEach(link => {
      link.classList.remove('active');
      if (link.getAttribute('data-section') === sectionName) {
        link.classList.add('active');
      }
    });
    
    // Cargar datos según sección
    loadSectionData(sectionName);
  }
}

async function loadSectionData(sectionName) {
  switch(sectionName) {
    case 'dashboard':
      await loadDashboard();
      break;
    case 'tours':
      await loadTours();
      break;
    case 'analytics':
      // Inicializar periodo por defecto
      if (!document.getElementById('analyticsStartDate')?.value) {
        setAnalyticsPeriod('30d');
      }
      await loadAnalytics();
      break;
    case 'bookings':
      await loadBookings();
      break;
    case 'users':
      await loadUsers();
      break;
    case 'coupons':
      await loadCoupons();
      break;
    case 'reviews':
      await loadReviews();
      break;
    case 'waitlist':
      await loadWaitlist();
      break;
    case 'blog-comments':
      await loadBlogComments();
      break;
    case 'homepage':
      await loadHomepageContent();
      break;
    case 'email-settings':
      await loadEmailSettings();
      break;
    case 'chatbot-settings':
      await loadChatbotSettings();
      break;
    case 'media':
      await loadMedia();
      break;
    case 'pages':
      await loadPages();
      break;
    case 'reports':
      await loadReports();
      break;
  }
}

// Dashboard
async function loadDashboard() {
  try {
    const summary = await api.getReportsSummary();
    const b = summary.Bookings || summary.bookings || {};
    const r = summary.Revenue || summary.revenue || {};
    const t = summary.Tours || summary.tours || {};
    const u = summary.Users || summary.users || {};
    
    // Actualizar estadísticas (soporta PascalCase y camelCase)
    document.getElementById('statTotalBookings').textContent = b.Total ?? b.total ?? 0;
    document.getElementById('statTotalRevenue').textContent = `$${formatNumber(r.Total ?? r.total ?? 0)}`;
    document.getElementById('statActiveTours').textContent = t.Active ?? t.active ?? 0;
    document.getElementById('statActiveUsers').textContent = u.Total ?? u.total ?? 0;
    
    // Cargar gráficos
    await loadRevenueChart();
    await loadBookingsStatusChart();
    await loadTopToursChart();
  } catch (error) {
    console.error('Error cargando dashboard:', error);
    showError('Error al cargar el dashboard');
  }
}

async function loadRevenueChart() {
  try {
    const timeseries = await api.getTimeseriesReport();
    const ctx = document.getElementById('revenueChart');
    if (!ctx) return;
    
    if (revenueChart) revenueChart.destroy();
    
    const dataPoints = timeseries.DataPoints || timeseries.dataPoints || timeseries.data || [];
    
    revenueChart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: dataPoints.map(d => formatDate(d.Date || d.date)) || [],
        datasets: [{
          label: 'Ingresos',
          data: dataPoints.map(d => d.Revenue ?? d.revenue ?? 0) || [],
          borderColor: '#0ea5e9',
          backgroundColor: 'rgba(14, 165, 233, 0.1)',
          tension: 0.4
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: { display: false }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: function(value) {
                return '$' + formatNumber(value);
              }
            }
          }
        }
      }
    });
  } catch (error) {
    console.error('Error cargando gráfico de ingresos:', error);
  }
}

async function loadBookingsStatusChart() {
  try {
    const summary = await api.getReportsSummary();
    const ctx = document.getElementById('bookingsStatusChart');
    if (!ctx) return;
    
    if (bookingsStatusChart) bookingsStatusChart.destroy();
    
    const b = summary.Bookings || summary.bookings || {};
    
    bookingsStatusChart = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: ['Confirmadas', 'Pendientes', 'Canceladas'],
        datasets: [{
          data: [
            b.Confirmed ?? b.confirmed ?? 0,
            b.Pending ?? b.pending ?? 0,
            b.Cancelled ?? b.cancelled ?? 0
          ],
          backgroundColor: ['#10b981', '#f59e0b', '#ef4444']
        }]
      },
      options: {
        responsive: true
      }
    });
  } catch (error) {
    console.error('Error cargando gráfico de estados:', error);
  }
}

async function loadTopToursChart() {
  try {
    const toursReport = await api.getToursReport();
    const ctx = document.getElementById('topToursChart');
    if (!ctx) return;
    
    if (topToursChart) topToursChart.destroy();
    
    const tours = toursReport.TopSellingTours || toursReport.topSellingTours || toursReport.tours || [];
    const top10 = (Array.isArray(tours) ? tours : []).slice(0, 10);
    
    topToursChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: top10.map(t => t.TourName || t.tourName || '-'),
        datasets: [{
          label: 'Ventas',
          data: top10.map(t => t.TotalBookings ?? t.totalBookings ?? 0),
          backgroundColor: '#0ea5e9'
        }]
      },
      options: {
        responsive: true,
        indexAxis: 'y',
        plugins: {
          legend: { display: false }
        }
      }
    });
  } catch (error) {
    console.error('Error cargando gráfico de tours:', error);
  }
}

// Tours
async function loadTours() {
  try {
    const res = await api.getAdminTours();
    const tours = Array.isArray(res) ? res : (res?.items || res?.data || []);
    const tbody = document.getElementById('toursTableBody');
    if (!tbody) return;
    
    if (!tours || tours.length === 0) {
      tbody.innerHTML = '<tr><td colspan="5" class="loading">No hay tours</td></tr>';
      return;
    }
    
    tbody.innerHTML = tours.map(tour => {
      const tid = tour.Id || tour.id;
      const tname = tour.Name || tour.name || '-';
      const tprice = tour.Price ?? tour.price ?? 0;
      const tduration = tour.DurationHours ?? tour.durationHours ?? '-';
      const tactive = tour.IsActive ?? tour.isActive ?? true;
      return `
      <tr>
        <td>${escapeHtml(tname)}</td>
        <td>$${formatNumber(tprice)}</td>
        <td>${tduration === '-' ? '-' : tduration + 'h'}</td>
        <td>${tactive ? '<span class="badge badge-success">Activo</span>' : '<span class="badge badge-danger">Inactivo</span>'}</td>
        <td>
          <a href="/tour-detail.html?id=${tid}" target="_blank" rel="noopener" class="btn btn-secondary" style="margin-right: 6px;">👁 Ver</a>
          <button class="btn btn-secondary" onclick="editTour('${tid}')">Editar</button>
          <button class="btn btn-primary" onclick="editTourBlocks('${tid}')" style="background: #8b5cf6;">📐 Bloques CMS</button>
          <button class="btn btn-danger" onclick="deleteTour('${tid}')">Eliminar</button>
        </td>
      </tr>
    `;
    }).join('');
  } catch (error) {
    console.error('Error cargando tours:', error);
    showError('Error al cargar tours');
  }
}

// Bookings
async function loadBookings() {
  try {
    const res = await api.getAdminBookings();
    const bookings = Array.isArray(res) ? res : (res?.items || res?.data || []);
    const tbody = document.getElementById('bookingsTableBody');
    if (!tbody) return;
    
    if (!bookings || bookings.length === 0) {
      tbody.innerHTML = '<tr><td colspan="7" class="loading">No hay reservas</td></tr>';
      return;
    }
    
    tbody.innerHTML = bookings.map(booking => {
      const id = booking.Id ?? booking.id ?? '';
      const idStr = typeof id === 'string' ? id : (id && id.toString ? id.toString() : '');
      const tourName = booking.TourName ?? booking.tourName ?? '-';
      const userEmail = booking.UserEmail ?? booking.userEmail ?? '-';
      const tourDate = booking.TourDate ?? booking.tourDate;
      const totalAmount = booking.TotalAmount ?? booking.totalAmount ?? 0;
      const status = booking.Status ?? booking.status ?? '';
      return `
      <tr>
        <td>${idStr ? idStr.substring(0, 8) + '...' : '-'}</td>
        <td>${escapeHtml(tourName)}</td>
        <td>${escapeHtml(userEmail)}</td>
        <td>${formatDate(tourDate)}</td>
        <td>$${formatNumber(totalAmount)}</td>
        <td>${getBookingStatusBadge(status)}</td>
        <td>
          <button class="btn btn-secondary" onclick="viewBooking('${idStr}')">Ver</button>
        </td>
      </tr>
    `;
    }).join('');
  } catch (error) {
    console.error('Error cargando reservas:', error);
    showError('Error al cargar reservas');
  }
}

function viewBooking(bookingId) {
  if (!bookingId) return;
  window.open(`/reservas.html?booking=${encodeURIComponent(bookingId)}`, '_blank');
}

// Users
async function loadUsers() {
  try {
    const res = await api.getAdminUsers();
    const users = Array.isArray(res) ? res : (res?.items || res?.data || []) || [];
    const tbody = document.getElementById('usersTableBody');
    if (!tbody) return;
    
    if (!users || users.length === 0) {
      tbody.innerHTML = '<tr><td colspan="5" class="loading">No hay usuarios</td></tr>';
      return;
    }
    
    tbody.innerHTML = users.map(user => {
      const id = user.Id ?? user.id ?? '';
      const idStr = (id && typeof id !== 'string') ? String(id) : (id || '');
      const email = user.Email ?? user.email ?? '-';
      const firstName = user.FirstName ?? user.firstName ?? '';
      const lastName = user.LastName ?? user.lastName ?? '';
      const fullName = `${firstName} ${lastName}`.trim() || '-';
      const isActive = user.IsActive ?? user.isActive ?? false;
      const roles = user.Roles ?? user.roles ?? [];
      const isAdmin = Array.isArray(roles) && roles.some(r => (r && String(r).toLowerCase()) === 'admin');
      return `
      <tr>
        <td>${escapeHtml(email)}</td>
        <td>${escapeHtml(fullName)}</td>
        <td>${isActive ? '<span class="badge badge-success">Activo</span>' : '<span class="badge badge-danger">Inactivo</span>'}</td>
        <td>${isAdmin ? '<span class="badge badge-info">Admin</span>' : '<span class="badge badge-secondary">Usuario</span>'}</td>
        <td>
          <button type="button" class="btn btn-secondary" onclick="editUser('${escapeHtml(idStr)}')">Editar</button>
          <button type="button" class="btn btn-danger" onclick="deleteUser('${escapeHtml(idStr)}')">Eliminar</button>
        </td>
      </tr>
    `;
    }).join('');
  } catch (error) {
    console.error('Error cargando usuarios:', error);
    showError('Error al cargar usuarios');
  }
}

function getUserFormHTML(isEdit) {
  const passwordFields = isEdit
    ? '<p class="form-hint">Dejar contraseña en blanco para no cambiarla.</p><div class="form-group"><label>Nueva contraseña</label><input type="password" id="userPassword" class="form-input" placeholder="Opcional" autocomplete="new-password" /></div>'
    : '<div class="form-group"><label>Contraseña *</label><input type="password" id="userPassword" class="form-input" required minlength="6" placeholder="Mínimo 6 caracteres" autocomplete="new-password" /></div>';
  return `
    <form id="userForm" onsubmit="saveUser(event)">
      <div class="form-group">
        <label>Email *</label>
        <input type="email" id="userEmail" class="form-input" required ${isEdit ? 'readonly' : ''} />
      </div>
      <div class="form-group">
        <label>Nombre</label>
        <input type="text" id="userFirstName" class="form-input" maxlength="100" />
      </div>
      <div class="form-group">
        <label>Apellido</label>
        <input type="text" id="userLastName" class="form-input" maxlength="100" />
      </div>
      <div class="form-group">
        <label>Teléfono</label>
        <input type="text" id="userPhone" class="form-input" maxlength="20" />
      </div>
      ${passwordFields}
      <div class="form-group">
        <label><input type="checkbox" id="userIsActive" checked /> Activo</label>
      </div>
      <div class="form-group">
        <label>Rol</label>
        <div style="display: flex; gap: 16px;">
          <label><input type="checkbox" id="userRoleCustomer" /> Usuario (Customer)</label>
          <label><input type="checkbox" id="userRoleAdmin" /> Admin</label>
        </div>
      </div>
      <div class="btn-group">
        <button type="submit" class="btn btn-primary">Guardar</button>
        <button type="button" class="btn btn-secondary" onclick="closeUserModal()">Cancelar</button>
      </div>
    </form>
  `;
}

function openCreateUserModal() {
  const title = document.getElementById('userModalTitle');
  const body = document.getElementById('userModalBody');
  if (!title || !body) return;
  title.textContent = 'Crear usuario';
  body.innerHTML = getUserFormHTML(false);
  document.getElementById('userForm').dataset.userId = '';
  document.getElementById('userModal').classList.add('active');
}

async function editUser(userId) {
  if (!userId) return;
  const title = document.getElementById('userModalTitle');
  const body = document.getElementById('userModalBody');
  if (!title || !body) return;
  title.textContent = 'Editar usuario';
  body.innerHTML = '<div class="loading" style="padding: 40px; text-align: center;"><div class="spinner"></div><p>Cargando...</p></div>';
  document.getElementById('userModal').classList.add('active');
  try {
    const user = await api.getAdminUser(userId);
    const email = user.Email ?? user.email ?? '';
    const firstName = user.FirstName ?? user.firstName ?? '';
    const lastName = user.LastName ?? user.lastName ?? '';
    const phone = user.Phone ?? user.phone ?? '';
    const isActive = (user.IsActive ?? user.isActive) !== false;
    const roles = user.Roles ?? user.roles ?? [];
    body.innerHTML = getUserFormHTML(true);
    document.getElementById('userForm').dataset.userId = userId;
    document.getElementById('userEmail').value = email;
    document.getElementById('userFirstName').value = firstName;
    document.getElementById('userLastName').value = lastName;
    document.getElementById('userPhone').value = phone || '';
    document.getElementById('userIsActive').checked = isActive;
    document.getElementById('userPassword').required = false;
    document.getElementById('userRoleCustomer').checked = Array.isArray(roles) && roles.some(r => String(r).toLowerCase() === 'customer');
    document.getElementById('userRoleAdmin').checked = Array.isArray(roles) && roles.some(r => String(r).toLowerCase() === 'admin');
  } catch (err) {
    console.error(err);
    showError('Error al cargar usuario');
    body.innerHTML = '<p class="error">Error al cargar usuario.</p><button class="btn btn-secondary" onclick="closeUserModal()">Cerrar</button>';
  }
}

function closeUserModal() {
  const modal = document.getElementById('userModal');
  if (modal) modal.classList.remove('active');
}

async function saveUser(e) {
  e.preventDefault();
  const form = document.getElementById('userForm');
  const userId = form?.dataset?.userId;
  const email = document.getElementById('userEmail')?.value?.trim();
  const firstName = document.getElementById('userFirstName')?.value?.trim() ?? '';
  const lastName = document.getElementById('userLastName')?.value?.trim() ?? '';
  const phone = document.getElementById('userPhone')?.value?.trim() || null;
  const isActive = document.getElementById('userIsActive')?.checked ?? true;
  const password = document.getElementById('userPassword')?.value;
  const roles = [];
  if (document.getElementById('userRoleAdmin')?.checked) roles.push('Admin');
  if (document.getElementById('userRoleCustomer')?.checked) roles.push('Customer');
  if (roles.length === 0) roles.push('Customer');

  if (!email) {
    showError('El email es obligatorio');
    return;
  }

  try {
    if (userId) {
      const payload = { firstName, lastName, phone, isActive, roles };
      if (password && password.length >= 6) payload.password = password;
      await api.updateAdminUser(userId, payload);
      showSuccess('Usuario actualizado');
    } else {
      if (!password || password.length < 6) {
        showError('La contraseña es obligatoria y debe tener al menos 6 caracteres');
        return;
      }
      await api.createAdminUser({ email, firstName, lastName, phone, password, roles, isActive });
      showSuccess('Usuario creado');
    }
    closeUserModal();
    await loadUsers();
  } catch (err) {
    console.error(err);
    showError(err?.message || err?.response?.detail || 'Error al guardar usuario');
  }
}

async function deleteUser(userId) {
  if (!userId) return;
  if (!confirm('¿Eliminar este usuario? Esta acción no se puede deshacer.')) return;
  try {
    await api.deleteAdminUser(userId);
    showSuccess('Usuario eliminado');
    await loadUsers();
  } catch (err) {
    console.error(err);
    showError(err?.message || err?.response?.detail || 'Error al eliminar usuario');
  }
}

// Coupons
async function loadCoupons() {
  try {
    const res = await api.getCoupons();
    const coupons = Array.isArray(res) ? res : (res?.items || res?.data || []);
    const tbody = document.getElementById('couponsTableBody');
    if (!tbody) return;
    
    if (coupons.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="loading">No hay cupones</td></tr>';
      return;
    }
    
    const isPct = (c) => {
      const dt = c.DiscountType ?? c.discountType;
      return dt === 1 || dt === 'Percentage' || (typeof dt === 'string' && dt.toLowerCase().includes('percent'));
    };
    
    tbody.innerHTML = coupons.map(coupon => {
      const code = coupon.Code ?? coupon.code ?? '';
      const val = coupon.DiscountValue ?? coupon.discountValue ?? 0;
      const uses = coupon.CurrentUses ?? coupon.currentUses ?? 0;
      const max = coupon.MaxUses ?? coupon.maxUses;
      const active = coupon.IsActive ?? coupon.isActive ?? true;
      const id = coupon.Id ?? coupon.id ?? '';
      return `
      <tr>
        <td><strong>${escapeHtml(code)}</strong></td>
        <td>${isPct(coupon) ? 'Porcentaje' : 'Monto Fijo'}</td>
        <td>${isPct(coupon) ? `${val}%` : `$${formatNumber(val)}`}</td>
        <td>${uses} / ${max ?? '∞'}</td>
        <td>${active ? '<span class="badge badge-success">Activo</span>' : '<span class="badge badge-danger">Inactivo</span>'}</td>
        <td>
          <button class="btn btn-secondary" onclick="editCoupon('${id}')">Editar</button>
          <button class="btn btn-danger" onclick="deleteCoupon('${id}')">Eliminar</button>
        </td>
      </tr>
    `;
    }).join('');
  } catch (error) {
    console.error('Error cargando cupones:', error);
    showError('Error al cargar cupones');
  }
}

// Reviews
async function loadReviews() {
  try {
    const res = await api.getAllReviews();
    const reviewsList = res?.Reviews ?? res?.reviews ?? (Array.isArray(res) ? res : []);
    const tbody = document.getElementById('reviewsTableBody');
    if (!tbody) return;
    
    if (!reviewsList || reviewsList.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="loading">No hay reviews</td></tr>';
      return;
    }
    
    tbody.innerHTML = reviewsList.map(review => {
      const tourName = review.TourName ?? review.tourName ?? '-';
      const userName = review.UserName ?? review.userName ?? review.UserEmail ?? review.userEmail ?? '-';
      const rating = review.Rating ?? review.rating ?? 0;
      const comment = review.Comment ?? review.comment ?? review.Title ?? review.title ?? '-';
      const isApproved = review.IsApproved ?? review.isApproved ?? false;
      const id = review.Id ?? review.id ?? '';
      const tourId = review.TourId ?? review.tourId ?? '';
      return `
      <tr>
        <td>${escapeHtml(tourName)}</td>
        <td>${escapeHtml(userName)}</td>
        <td>${'⭐'.repeat(Math.min(5, rating))} (${rating}/5)</td>
        <td>${escapeHtml(String(comment).substring(0, 50))}...</td>
        <td>${isApproved ? '<span class="badge badge-success">Aprobada</span>' : '<span class="badge badge-warning">Pendiente</span>'}</td>
        <td>
          ${!isApproved ? `<button class="btn btn-success" onclick="approveReview('${id}', '${tourId}')">Aprobar</button>` : ''}
          ${isApproved ? `<button class="btn btn-danger" onclick="rejectReview('${id}', '${tourId}')">Rechazar</button>` : ''}
        </td>
      </tr>
    `;
    }).join('');
  } catch (error) {
    console.error('Error cargando reviews:', error);
    showError('Error al cargar reviews');
  }
}

async function approveReview(reviewId, tourId) {
  try {
    await api.approveReview(reviewId, tourId);
    showSuccess('Review aprobada exitosamente');
    await loadReviews();
  } catch (error) {
    console.error('Error aprobando review:', error);
    showError('Error al aprobar review');
  }
}

async function rejectReview(reviewId, tourId) {
  try {
    await api.rejectReview(reviewId, tourId);
    showSuccess('Review rechazada exitosamente');
    await loadReviews();
  } catch (error) {
    console.error('Error rechazando review:', error);
    showError('Error al rechazar review');
  }
}

// Waitlist
async function loadWaitlist() {
  try {
    const res = await api.getWaitlist();
    const waitlist = Array.isArray(res) ? res : (res?.items || res?.data || []);
    const tbody = document.getElementById('waitlistTableBody');
    if (!tbody) return;
    
    if (waitlist.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="loading">No hay entradas en waitlist</td></tr>';
      return;
    }
    
    tbody.innerHTML = waitlist.map(entry => {
      const tourName = entry.TourName ?? entry.tourName ?? '-';
      const userEmail = entry.UserEmail ?? entry.userEmail ?? '-';
      const date = entry.RequestedDate ?? entry.requestedDate ?? entry.CreatedAt ?? entry.createdAt;
      const priority = entry.Priority ?? entry.priority ?? 0;
      const active = entry.IsActive ?? entry.isActive ?? true;
      const id = entry.Id ?? entry.id ?? '';
      return `
      <tr>
        <td>${escapeHtml(tourName)}</td>
        <td>${escapeHtml(userEmail)}</td>
        <td>${formatDate(date)}</td>
        <td>${priority}</td>
        <td>${active ? '<span class="badge badge-success">Activo</span>' : '<span class="badge badge-danger">Inactivo</span>'}</td>
        <td>
          <button class="btn btn-danger" onclick="removeFromWaitlist('${id}')">Remover</button>
        </td>
      </tr>
    `;
    }).join('');
  } catch (error) {
    console.error('Error cargando waitlist:', error);
    showError('Error al cargar waitlist');
  }
}

// Blog Comments
// Homepage Content (CMS completo)
function getVal(c, ...keys) {
  for (const k of keys) {
    const v = c?.[k];
    if (v !== undefined && v !== null) return v;
  }
  return '';
}

async function loadHomepageContent() {
  try {
    const content = await api.getAdminHomePageContent();
    const form = document.getElementById('homepageForm');
    
    if (!form) return;
    
    const logoUrl = getVal(content, 'LogoUrl', 'logoUrl');
    const faviconUrl = getVal(content, 'FaviconUrl', 'faviconUrl');
    const logoUrlSocial = getVal(content, 'LogoUrlSocial', 'logoUrlSocial');
    const heroImageUrl = getVal(content, 'HeroImageUrl', 'heroImageUrl');
    
    form.innerHTML = `
      <div class="cms-section" style="margin-bottom: 24px; padding: 20px; background: #f8fafc; border-radius: 12px;">
        <h3 style="margin: 0 0 16px 0; color: #1e293b;">🖼️ Identidad y marca</h3>
        <div class="form-group">
          <label>Logo URL</label>
          <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
            <div id="logoPreviewWrapper" style="min-width: 60px; min-height: 40px; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden; display: flex; align-items: center; justify-content: center;">
              <img id="logoPreview" src="${escapeHtml(logoUrl) || ''}" alt="Logo" style="max-width: 120px; max-height: 60px; object-fit: contain;" onerror="this.style.display='none'" />
              ${!logoUrl ? '<span style="color:#94a3b8; font-size:12px;">Sin imagen</span>' : ''}
            </div>
            <input type="text" id="homepageLogoUrl" value="${escapeHtml(logoUrl)}" class="form-input" placeholder="URL o sube/selecciona" style="flex:1; min-width:200px;" />
            <input type="file" id="homepageLogoUrlFile" accept="image/*" style="display:none;" />
            <button type="button" class="btn btn-primary btn-sm" onclick="document.getElementById('homepageLogoUrlFile').click()">📤 Subir</button>
            <button type="button" class="btn btn-secondary btn-sm" onclick="adminSelectMediaForCMS('homepageLogoUrl','logoPreviewWrapper','logoPreview')">📁 Seleccionar</button>
          </div>
        </div>
        <div class="form-group">
          <label>Favicon URL</label>
          <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
            <div id="faviconPreviewWrapper" style="min-width: 32px; min-height: 32px;">${faviconUrl ? `<img id="faviconPreview" src="${escapeHtml(faviconUrl)}" style="width:32px;height:32px;" />` : '<span id="faviconPreview" style="color:#94a3b8;">Sin favicon</span>'}</div>
            <input type="text" id="homepageFaviconUrl" value="${escapeHtml(faviconUrl)}" class="form-input" style="flex:1; min-width:200px;" />
            <input type="file" id="homepageFaviconUrlFile" accept="image/*,.ico" style="display:none;" />
            <button type="button" class="btn btn-primary btn-sm" onclick="document.getElementById('homepageFaviconUrlFile').click()">📤 Subir</button>
            <button type="button" class="btn btn-secondary btn-sm" onclick="adminSelectMediaForCMS('homepageFaviconUrl','faviconPreviewWrapper','faviconPreview')">📁 Seleccionar</button>
          </div>
        </div>
        <div class="form-group">
          <label>Logo Social (Open Graph)</label>
          <input type="text" id="homepageLogoUrlSocial" value="${escapeHtml(logoUrlSocial)}" class="form-input" placeholder="URL para redes sociales" />
        </div>
      </div>
      <div class="cms-section" style="margin-bottom: 24px; padding: 20px; background: #f8fafc; border-radius: 12px;">
        <h3 style="margin: 0 0 16px 0; color: #1e293b;">🎯 Hero (portada)</h3>
        <div class="form-group">
          <label>Imagen de fondo del Hero</label>
          <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
            <div id="heroImagePreviewWrapper" style="min-width: 120px; min-height: 60px; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;">
              <img id="heroImagePreview" src="${escapeHtml(heroImageUrl) || ''}" alt="Hero" style="max-width: 200px; max-height: 100px; object-fit: cover;" onerror="this.style.display='none'" />
            </div>
            <input type="text" id="homepageHeroImageUrl" value="${escapeHtml(heroImageUrl)}" class="form-input" style="flex:1; min-width:200px;" />
            <input type="file" id="homepageHeroImageUrlFile" accept="image/*" style="display:none;" />
            <button type="button" class="btn btn-primary btn-sm" onclick="document.getElementById('homepageHeroImageUrlFile').click()">📤 Subir</button>
            <button type="button" class="btn btn-secondary btn-sm" onclick="adminSelectMediaForCMS('homepageHeroImageUrl','heroImagePreviewWrapper','heroImagePreview')">📁 Seleccionar</button>
          </div>
        </div>
        <div class="form-group">
          <label>Hero Title</label>
          <input type="text" id="homepageHeroTitle" value="${escapeHtml(getVal(content,'HeroTitle','heroTitle'))}" class="form-input" placeholder="Título principal" />
        </div>
        <div class="form-group">
          <label>Hero Subtitle</label>
          <textarea id="homepageHeroSubtitle" class="form-input" rows="3">${escapeHtml(getVal(content,'HeroSubtitle','heroSubtitle'))}</textarea>
        </div>
        <div class="form-group">
          <label>Hero Search Placeholder</label>
          <input type="text" id="homepageHeroSearchPlaceholder" value="${escapeHtml(getVal(content,'HeroSearchPlaceholder','heroSearchPlaceholder'))}" class="form-input" placeholder="Buscar tours..." />
        </div>
        <div class="form-group">
          <label>Hero Search Button</label>
          <input type="text" id="homepageHeroSearchButton" value="${escapeHtml(getVal(content,'HeroSearchButton','heroSearchButton'))}" class="form-input" placeholder="Buscar" />
        </div>
      </div>
      <div class="cms-section" style="margin-bottom: 24px; padding: 20px; background: #f8fafc; border-radius: 12px;">
        <h3 style="margin: 0 0 16px 0; color: #1e293b;">📋 Sección Tours</h3>
        <div class="form-group">
          <label>Tours Section Title</label>
          <input type="text" id="homepageToursSectionTitle" value="${escapeHtml(getVal(content,'ToursSectionTitle','toursSectionTitle'))}" class="form-input" />
        </div>
        <div class="form-group">
          <label>Tours Section Subtitle</label>
          <textarea id="homepageToursSectionSubtitle" class="form-input" rows="2">${escapeHtml(getVal(content,'ToursSectionSubtitle','toursSectionSubtitle'))}</textarea>
        </div>
        <div class="form-group">
          <label>Loading Tours Text</label>
          <input type="text" id="homepageLoadingToursText" value="${escapeHtml(getVal(content,'LoadingToursText','loadingToursText'))}" class="form-input" placeholder="Cargando tours..." />
        </div>
        <div class="form-group">
          <label>Error Loading Tours Text</label>
          <input type="text" id="homepageErrorLoadingToursText" value="${escapeHtml(getVal(content,'ErrorLoadingToursText','errorLoadingToursText'))}" class="form-input" />
        </div>
        <div class="form-group">
          <label>No Tours Found Text</label>
          <input type="text" id="homepageNoToursFoundText" value="${escapeHtml(getVal(content,'NoToursFoundText','noToursFoundText'))}" class="form-input" />
        </div>
      </div>
      <div class="cms-section" style="margin-bottom: 24px; padding: 20px; background: #f8fafc; border-radius: 12px;">
        <h3 style="margin: 0 0 16px 0; color: #1e293b;">🧭 Navegación</h3>
        <div class="form-group"><label>Nav Brand Text</label><input type="text" id="homepageNavBrandText" value="${escapeHtml(getVal(content,'NavBrandText','navBrandText'))}" class="form-input" /></div>
        <div class="form-group"><label>Nav Tours Link</label><input type="text" id="homepageNavToursLink" value="${escapeHtml(getVal(content,'NavToursLink','navToursLink'))}" class="form-input" /></div>
        <div class="form-group"><label>Nav Bookings Link</label><input type="text" id="homepageNavBookingsLink" value="${escapeHtml(getVal(content,'NavBookingsLink','navBookingsLink'))}" class="form-input" /></div>
        <div class="form-group"><label>Nav Login Link</label><input type="text" id="homepageNavLoginLink" value="${escapeHtml(getVal(content,'NavLoginLink','navLoginLink'))}" class="form-input" /></div>
        <div class="form-group"><label>Nav Logout Button</label><input type="text" id="homepageNavLogoutButton" value="${escapeHtml(getVal(content,'NavLogoutButton','navLogoutButton'))}" class="form-input" /></div>
      </div>
      <div class="cms-section" style="margin-bottom: 24px; padding: 20px; background: #f8fafc; border-radius: 12px;">
        <h3 style="margin: 0 0 16px 0; color: #1e293b;">📄 Footer</h3>
        <div class="form-group"><label>Footer Brand Text</label><input type="text" id="homepageFooterBrandText" value="${escapeHtml(getVal(content,'FooterBrandText','footerBrandText'))}" class="form-input" /></div>
        <div class="form-group"><label>Footer Description</label><textarea id="homepageFooterDescription" class="form-input" rows="3">${escapeHtml(getVal(content,'FooterDescription','footerDescription'))}</textarea></div>
        <div class="form-group"><label>Footer Copyright</label><input type="text" id="homepageFooterCopyright" value="${escapeHtml(getVal(content,'FooterCopyright','footerCopyright'))}" class="form-input" /></div>
      </div>
      <div class="cms-section" style="margin-bottom: 24px; padding: 20px; background: #f8fafc; border-radius: 12px;">
        <h3 style="margin: 0 0 16px 0; color: #1e293b;">🔍 SEO</h3>
        <div class="form-group"><label>Page Title</label><input type="text" id="homepagePageTitle" value="${escapeHtml(getVal(content,'PageTitle','pageTitle'))}" class="form-input" /></div>
        <div class="form-group"><label>Meta Description</label><textarea id="homepageMetaDescription" class="form-input" rows="2">${escapeHtml(getVal(content,'MetaDescription','metaDescription'))}</textarea></div>
      </div>
      <div class="btn-group">
        <button type="button" class="btn btn-primary" onclick="saveHomepageContent()">💾 Guardar contenido CMS</button>
      </div>
    `;
    
    // Bind file uploads
    document.getElementById('homepageLogoUrlFile')?.addEventListener('change', e => adminUploadCMSImage(e, 'homepageLogoUrl', 'logoPreviewWrapper', 'logoPreview'));
    document.getElementById('homepageFaviconUrlFile')?.addEventListener('change', e => adminUploadCMSImage(e, 'homepageFaviconUrl', 'faviconPreviewWrapper', 'faviconPreview'));
    document.getElementById('homepageHeroImageUrlFile')?.addEventListener('change', e => adminUploadCMSImage(e, 'homepageHeroImageUrl', 'heroImagePreviewWrapper', 'heroImagePreview'));
  } catch (error) {
    console.error('Error cargando homepage content:', error);
    showError('Error al cargar el contenido de la homepage');
  }
}

async function adminUploadCMSImage(e, inputId, wrapperId, imgId) {
  const file = e.target?.files?.[0];
  if (!file) return;
  try {
    const result = await api.uploadMediaFile(file, null, null, 'cms');
    const url = result?.fileUrl || result?.url || result?.Url || result?.FileUrl;
    if (!url) throw new Error('No se recibió URL');
    const input = document.getElementById(inputId);
    const wrapper = document.getElementById(wrapperId);
    if (input) input.value = url.startsWith('http') ? url : (window.location.origin + (url.startsWith('/') ? url : '/' + url));
    if (wrapper) {
      const img = document.getElementById(imgId) || document.createElement('img');
      img.id = imgId;
      img.src = input.value;
      img.style.maxWidth = imgId === 'faviconPreview' ? '32px' : '120px';
      img.style.maxHeight = imgId === 'faviconPreview' ? '32px' : '60px';
      if (imgId === 'faviconPreview') img.style.width = img.style.height = '32px';
      img.onerror = () => img.style.display = 'none';
      wrapper.innerHTML = '';
      wrapper.appendChild(img);
    }
    showSuccess('Imagen subida correctamente');
  } catch (err) {
    showError('Error al subir: ' + (err.message || 'Error'));
  }
  e.target.value = '';
}

async function adminSelectMediaForCMS(inputId, wrapperId, imgId) {
  try {
    const mediaFiles = await api.getAdminMedia(null, true, 1, 50);
    const list = Array.isArray(mediaFiles) ? mediaFiles : (mediaFiles?.items || mediaFiles?.data || []);
    if (list.length === 0) {
      showError('No hay imágenes en la biblioteca. Sube imágenes primero en Media.');
      return;
    }
    const opts = list.map(f => {
      const u = f.FileUrl ?? f.fileUrl ?? f.Url ?? f.url ?? '';
      return { url: u.startsWith('http') ? u : (window.location.origin + (u.startsWith('/') ? u : '/' + u)), id: f.Id ?? f.id };
    }).filter(x => x.url);
    const html = opts.map(o => `<div class="media-item" style="cursor:pointer;border:2px solid #e2e8f0;border-radius:8px;overflow:hidden;display:inline-block;margin:4px;" onclick="adminPickMediaForCMS('${escapeHtml(o.url)}','${inputId}','${wrapperId}','${imgId}')"><img src="${escapeHtml(o.url)}" style="width:80px;height:60px;object-fit:cover;" /></div>`).join('');
    const modal = document.createElement('div');
    modal.id = 'cmsMediaModal';
    modal.className = 'modal active';
    modal.style.cssText = 'position:fixed;inset:0;background:rgba(0,0,0,0.5);z-index:9999;display:flex;align-items:center;justify-content:center;padding:20px;';
    modal.innerHTML = `<div class="modal-content" style="max-width:600px;max-height:80vh;overflow:auto;background:white;padding:24px;border-radius:12px;"><h3>Seleccionar imagen</h3><div style="display:flex;flex-wrap:wrap;gap:8px;margin:16px 0;">${html}</div><button class="btn btn-secondary" onclick="document.getElementById('cmsMediaModal')?.remove()">Cancelar</button></div>`;
    document.body.appendChild(modal);
    modal.onclick = ev => { if (ev.target === modal) modal.remove(); };
  } catch (err) {
    showError('Error al cargar media: ' + (err.message || 'Error'));
  }
}

function adminPickMediaForCMS(url, inputId, wrapperId, imgId) {
  const input = document.getElementById(inputId);
  const wrapper = document.getElementById(wrapperId);
  if (input) input.value = url;
  if (wrapper) {
    const img = document.createElement('img');
    img.id = imgId;
    img.src = url;
    img.style.maxWidth = imgId === 'faviconPreview' ? '32px' : '120px';
    img.style.maxHeight = imgId === 'faviconPreview' ? '32px' : '60px';
    if (imgId === 'faviconPreview') img.style.width = img.style.height = '32px';
    img.onerror = () => img.style.display = 'none';
    wrapper.innerHTML = '';
    wrapper.appendChild(img);
  }
  document.getElementById('cmsMediaModal')?.remove();
}

async function saveHomepageContent() {
  try {
    const g = id => document.getElementById(id)?.value ?? '';
    const data = {
      HeroTitle: g('homepageHeroTitle'),
      HeroSubtitle: g('homepageHeroSubtitle'),
      HeroImageUrl: g('homepageHeroImageUrl') || null,
      HeroSearchPlaceholder: g('homepageHeroSearchPlaceholder'),
      HeroSearchButton: g('homepageHeroSearchButton'),
      ToursSectionTitle: g('homepageToursSectionTitle'),
      ToursSectionSubtitle: g('homepageToursSectionSubtitle'),
      LoadingToursText: g('homepageLoadingToursText'),
      ErrorLoadingToursText: g('homepageErrorLoadingToursText'),
      NoToursFoundText: g('homepageNoToursFoundText'),
      NavBrandText: g('homepageNavBrandText'),
      NavToursLink: g('homepageNavToursLink'),
      NavBookingsLink: g('homepageNavBookingsLink'),
      NavLoginLink: g('homepageNavLoginLink'),
      NavLogoutButton: g('homepageNavLogoutButton'),
      FooterBrandText: g('homepageFooterBrandText'),
      FooterDescription: g('homepageFooterDescription'),
      FooterCopyright: g('homepageFooterCopyright'),
      PageTitle: g('homepagePageTitle'),
      MetaDescription: g('homepageMetaDescription'),
      LogoUrl: g('homepageLogoUrl') || null,
      FaviconUrl: g('homepageFaviconUrl') || null,
      LogoUrlSocial: g('homepageLogoUrlSocial') || null
    };
    
    await api.updateAdminHomePageContent(data);
    showSuccess('Contenido CMS guardado exitosamente');
  } catch (error) {
    console.error('Error guardando homepage content:', error);
    showError('Error al guardar el contenido de la homepage');
  }
}

// Configuración de Email (SMTP)
async function loadEmailSettings() {
  try {
    const s = await api.getAdminEmailSettings();
    const host = s.SmtpHost ?? s.smtpHost ?? '';
    const port = s.SmtpPort ?? s.smtpPort ?? 587;
    const username = s.SmtpUsername ?? s.smtpUsername ?? '';
    const fromAddr = s.FromAddress ?? s.fromAddress ?? '';
    const fromName = s.FromName ?? s.fromName ?? '';
    const enableSsl = (s.EnableSsl ?? s.enableSsl) !== false;

    const form = document.getElementById('emailSettingsForm');
    const tbody = document.getElementById('emailSettingsTableBody');
    if (!form || !tbody) return;

    form.innerHTML = `
      <div class="form-group">
        <label>Host SMTP</label>
        <input type="text" id="emailSmtpHost" value="${escapeHtml(host)}" class="form-input" placeholder="smtp.gmail.com" />
      </div>
      <div class="form-group">
        <label>Puerto</label>
        <input type="number" id="emailSmtpPort" value="${port}" class="form-input" placeholder="587" min="1" max="65535" />
      </div>
      <div class="form-group">
        <label>Usuario SMTP (email)</label>
        <input type="text" id="emailSmtpUsername" value="${escapeHtml(username)}" class="form-input" placeholder="tu-email@gmail.com" />
      </div>
      <div class="form-group">
        <label>Contraseña / App password</label>
        <input type="password" id="emailSmtpPassword" class="form-input" placeholder="Dejar en blanco para mantener la actual" autocomplete="new-password" />
      </div>
      <div class="form-group">
        <label>Remitente (From address)</label>
        <input type="email" id="emailFromAddress" value="${escapeHtml(fromAddr)}" class="form-input" placeholder="noreply@panamatravelhub.com" />
      </div>
      <div class="form-group">
        <label>Nombre del remitente</label>
        <input type="text" id="emailFromName" value="${escapeHtml(fromName)}" class="form-input" placeholder="Panama Travel Hub" />
      </div>
      <div class="form-group">
        <label><input type="checkbox" id="emailEnableSsl" ${enableSsl ? 'checked' : ''} /> Usar SSL/TLS</label>
      </div>
    `;

    const pwdDisplay = username ? '••••••••' : '-';
    const updatedAt = s.UpdatedAt ?? s.updatedAt ? new Date(s.UpdatedAt ?? s.updatedAt).toLocaleString() : '-';
    tbody.innerHTML = `
      <tr><td>Host</td><td>${escapeHtml(host) || '-'}</td></tr>
      <tr><td>Puerto</td><td>${port}</td></tr>
      <tr><td>Usuario</td><td>${escapeHtml(username) || '-'}</td></tr>
      <tr><td>Contraseña</td><td>${pwdDisplay}</td></tr>
      <tr><td>Remitente</td><td>${escapeHtml(fromAddr) || '-'}</td></tr>
      <tr><td>Nombre remitente</td><td>${escapeHtml(fromName) || '-'}</td></tr>
      <tr><td>SSL</td><td>${enableSsl ? 'Sí' : 'No'}</td></tr>
      <tr><td>Última actualización</td><td>${updatedAt}</td></tr>
    `;
  } catch (error) {
    console.error('Error cargando configuración de email:', error);
    showError('Error al cargar la configuración de email');
    const form = document.getElementById('emailSettingsForm');
    const tbody = document.getElementById('emailSettingsTableBody');
    if (form) form.innerHTML = '<div class="loading" style="color: var(--color-error);">Error al cargar. Reintenta.</div>';
    if (tbody) tbody.innerHTML = '<tr><td colspan="2">Error al cargar</td></tr>';
  }
}

async function saveEmailSettings() {
  try {
    const data = {
      SmtpHost: document.getElementById('emailSmtpHost')?.value?.trim() || null,
      SmtpPort: parseInt(document.getElementById('emailSmtpPort')?.value, 10) || null,
      SmtpUsername: document.getElementById('emailSmtpUsername')?.value?.trim() || null,
      SmtpPassword: document.getElementById('emailSmtpPassword')?.value || null,
      FromAddress: document.getElementById('emailFromAddress')?.value?.trim() || null,
      FromName: document.getElementById('emailFromName')?.value?.trim() || null,
      EnableSsl: document.getElementById('emailEnableSsl')?.checked ?? null
    };
    if (data.SmtpPassword === '') data.SmtpPassword = null;

    await api.updateAdminEmailSettings(data);
    showSuccess('Configuración de email guardada correctamente');
    await loadEmailSettings();
  } catch (error) {
    console.error('Error guardando configuración de email:', error);
    showError('Error al guardar la configuración de email');
  }
}

// Configuración del Chatbot (OpenAI)
async function loadChatbotSettings() {
  try {
    const settings = await api.getAdminChatbotSettings();
    const apiKey = settings.ApiKey ?? settings.apiKey ?? '';
    const model = settings.Model ?? settings.model ?? 'gpt-4o-mini';
    const maxTokens = settings.MaxTokens ?? settings.maxTokens ?? 300;
    const temperature = settings.Temperature ?? settings.temperature ?? 0.7;
    const isEnabled = (settings.Enabled ?? settings.enabled) !== false;

    const form = document.getElementById('chatbotSettingsForm');
    const tbody = document.getElementById('chatbotSettingsTableBody');
    const statusDiv = document.getElementById('chatbotStatus');
    
    if (!form || !tbody || !statusDiv) return;

    // Formulario
    form.innerHTML = `
      <div class="form-group">
        <label>
          <input type="checkbox" id="chatbotEnabled" ${isEnabled ? 'checked' : ''} /> 
          Habilitar Chatbot con IA
        </label>
        <p style="font-size: 0.875rem; color: var(--text-secondary); margin-top: 8px;">
          Si está deshabilitado, el chatbot usará respuestas predefinidas.
        </p>
      </div>
      <div class="form-group">
        <label>API Key de OpenAI</label>
        <input 
          type="password" 
          id="chatbotApiKey" 
          value="${escapeHtml(apiKey)}" 
          class="form-input" 
          placeholder="sk-..." 
          autocomplete="new-password"
        />
        <p style="font-size: 0.875rem; color: var(--text-secondary); margin-top: 8px;">
          Deja en blanco para mantener la actual. La clave se mostrará oculta por seguridad.
        </p>
      </div>
      <div class="form-group">
        <label>Modelo de IA</label>
        <select id="chatbotModel" class="form-input">
          <option value="gpt-4o-mini" ${model === 'gpt-4o-mini' ? 'selected' : ''}>gpt-4o-mini (Recomendado - Rápido y económico)</option>
          <option value="gpt-4o" ${model === 'gpt-4o' ? 'selected' : ''}>gpt-4o (Más potente pero más costoso)</option>
          <option value="gpt-3.5-turbo" ${model === 'gpt-3.5-turbo' ? 'selected' : ''}>gpt-3.5-turbo (Alternativa económica)</option>
        </select>
      </div>
      <div class="form-group">
        <label>Máximo de Tokens (longitud de respuesta)</label>
        <input 
          type="number" 
          id="chatbotMaxTokens" 
          value="${maxTokens}" 
          class="form-input" 
          min="50" 
          max="1000" 
          step="50"
        />
        <p style="font-size: 0.875rem; color: var(--text-secondary); margin-top: 8px;">
          Recomendado: 200-300 tokens para respuestas concisas.
        </p>
      </div>
      <div class="form-group">
        <label>Temperatura (creatividad)</label>
        <input 
          type="number" 
          id="chatbotTemperature" 
          value="${temperature}" 
          class="form-input" 
          min="0" 
          max="2" 
          step="0.1"
        />
        <p style="font-size: 0.875rem; color: var(--text-secondary); margin-top: 8px;">
          Valores más bajos (0.3-0.7) = más consistente. Valores más altos (0.8-1.2) = más creativo.
        </p>
      </div>
    `;

    // Tabla de resumen
    const apiKeyDisplay = apiKey ? `${apiKey.substring(0, 7)}...${apiKey.substring(apiKey.length - 4)}` : 'No configurada';
    const statusText = isEnabled && apiKey ? '✅ Activo' : apiKey ? '⚠️ Configurado pero deshabilitado' : '❌ No configurado';
    const statusColor = isEnabled && apiKey ? '#10b981' : apiKey ? '#f59e0b' : '#ef4444';
    
    tbody.innerHTML = `
      <tr>
        <td>Estado</td>
        <td><strong style="color: ${statusColor};">${statusText}</strong></td>
        <td>-</td>
      </tr>
      <tr>
        <td>API Key</td>
        <td>${apiKeyDisplay}</td>
        <td>${apiKey ? '✅' : '❌'}</td>
      </tr>
      <tr>
        <td>Modelo</td>
        <td>${escapeHtml(model)}</td>
        <td>✅</td>
      </tr>
      <tr>
        <td>Max Tokens</td>
        <td>${maxTokens}</td>
        <td>✅</td>
      </tr>
      <tr>
        <td>Temperatura</td>
        <td>${temperature}</td>
        <td>✅</td>
      </tr>
    `;

    // Estado del chatbot
    if (isEnabled && apiKey) {
      statusDiv.innerHTML = `
        <div style="display: flex; align-items: center; gap: 12px; padding: 16px; background: linear-gradient(135deg, rgba(16, 185, 129, 0.1), rgba(5, 150, 105, 0.05)); border-radius: 12px; border: 2px solid rgba(16, 185, 129, 0.3);">
          <div style="font-size: 2rem;">✅</div>
          <div>
            <strong style="color: #059669;">Chatbot con IA Activo</strong>
            <p style="margin: 4px 0 0 0; color: var(--text-secondary); font-size: 0.9rem;">
              El chatbot está configurado y funcionando con OpenAI. Los usuarios recibirán respuestas inteligentes.
            </p>
          </div>
        </div>
      `;
    } else if (apiKey) {
      statusDiv.innerHTML = `
        <div style="display: flex; align-items: center; gap: 12px; padding: 16px; background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); border-radius: 12px; border: 2px solid rgba(245, 158, 11, 0.3);">
          <div style="font-size: 2rem;">⚠️</div>
          <div>
            <strong style="color: #d97706;">Chatbot Deshabilitado</strong>
            <p style="margin: 4px 0 0 0; color: var(--text-secondary); font-size: 0.9rem;">
              La API Key está configurada pero el chatbot está deshabilitado. Actívalo para usar respuestas inteligentes.
            </p>
          </div>
        </div>
      `;
    } else {
      statusDiv.innerHTML = `
        <div style="display: flex; align-items: center; gap: 12px; padding: 16px; background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); border-radius: 12px; border: 2px solid rgba(239, 68, 68, 0.3);">
          <div style="font-size: 2rem;">❌</div>
          <div>
            <strong style="color: #dc2626;">Chatbot no configurado</strong>
            <p style="margin: 4px 0 0 0; color: var(--text-secondary); font-size: 0.9rem;">
              El chatbot está usando respuestas predefinidas. Configura la API Key de OpenAI para habilitar respuestas inteligentes.
            </p>
          </div>
        </div>
      `;
    }
  } catch (error) {
    console.error('Error cargando configuración del chatbot:', error);
    showError('Error al cargar la configuración del chatbot');
    const form = document.getElementById('chatbotSettingsForm');
    const tbody = document.getElementById('chatbotSettingsTableBody');
    const statusDiv = document.getElementById('chatbotStatus');
    if (form) form.innerHTML = '<div class="loading" style="color: var(--color-error);">Error al cargar. Reintenta.</div>';
    if (tbody) tbody.innerHTML = '<tr><td colspan="3">Error al cargar</td></tr>';
    if (statusDiv) statusDiv.innerHTML = '<div style="color: var(--color-error);">Error al verificar estado</div>';
  }
}

async function saveChatbotSettings() {
  try {
    const data = {
      Enabled: document.getElementById('chatbotEnabled')?.checked ?? false,
      ApiKey: document.getElementById('chatbotApiKey')?.value?.trim() || null,
      Model: document.getElementById('chatbotModel')?.value || 'gpt-4o-mini',
      MaxTokens: parseInt(document.getElementById('chatbotMaxTokens')?.value, 10) || 300,
      Temperature: parseFloat(document.getElementById('chatbotTemperature')?.value) || 0.7
    };
    
    // Si la API Key está vacía, no la enviamos (mantener la actual)
    if (data.ApiKey === '') {
      data.ApiKey = null;
    }

    await api.updateAdminChatbotSettings(data);
    showSuccess('Configuración del chatbot guardada correctamente');
    await loadChatbotSettings();
  } catch (error) {
    console.error('Error guardando configuración del chatbot:', error);
    showError('Error al guardar la configuración del chatbot');
  }
}

async function testChatbotConnection() {
  try {
    const btn = event.target;
    const originalText = btn.textContent;
    btn.disabled = true;
    btn.textContent = 'Probando...';

    const result = await api.testChatbotConnection();
    
    if (result.success) {
      showSuccess('✅ Conexión exitosa con OpenAI. El chatbot está funcionando correctamente.');
    } else {
      showError(`❌ Error de conexión: ${result.message || 'No se pudo conectar con OpenAI'}`);
    }
  } catch (error) {
    console.error('Error probando conexión del chatbot:', error);
    showError('Error al probar la conexión del chatbot');
  } finally {
    const btn = event.target;
    btn.disabled = false;
    btn.textContent = '🧪 Probar Conexión';
  }
}

// Media Files
async function loadMedia() {
  try {
    const category = document.getElementById('mediaCategoryFilter')?.value || null;
    const isImage = document.getElementById('mediaTypeFilter')?.value || null;
    const isImageBool = isImage === 'true' ? true : isImage === 'false' ? false : null;
    
    const media = await api.getAdminMedia(category, isImageBool);
    const tbody = document.getElementById('mediaTableBody');
    
    if (!tbody) return;
    
    const list = Array.isArray(media) ? media : (media?.items || media?.data || []);
    if (!list || list.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="loading">No hay archivos de media</td></tr>';
      return;
    }
    
    tbody.innerHTML = list.map(file => {
      const fileId = file.Id ?? file.id ?? '';
      const fileIdStr = typeof fileId === 'string' ? fileId : (fileId && fileId.toString ? fileId.toString() : '');
      const fileUrl = file.FileUrl ?? file.fileUrl ?? '';
      const url = fileUrl.startsWith('http') ? fileUrl : (window.location.origin + (fileUrl.startsWith('/') ? fileUrl : '/' + fileUrl));
      const fileName = file.FileName ?? file.fileName ?? '-';
      const isImage = file.IsImage ?? file.isImage ?? false;
      const fileSize = file.FileSize ?? file.fileSize ?? 0;
      const createdAt = file.CreatedAt ?? file.createdAt;
      const category = file.Category ?? file.category ?? '-';
      const altText = file.AltText ?? file.altText ?? '';
      return `
      <tr>
        <td>
          ${isImage ? `<img src="${escapeHtml(url)}" alt="${escapeHtml(altText)}" style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;" onerror="this.style.display='none'" />` : '📄'}
          <span style="margin-left: 10px;">${escapeHtml(fileName)}</span>
        </td>
        <td>${escapeHtml(category)}</td>
        <td>${isImage ? 'Imagen' : 'Archivo'}</td>
        <td>${formatFileSize(fileSize)}</td>
        <td>${createdAt ? new Date(createdAt).toLocaleDateString() : '-'}</td>
        <td>
          <button type="button" class="btn btn-danger btn-sm" data-media-id="${escapeHtml(fileIdStr)}" onclick="deleteMediaFile(this.dataset.mediaId)">🗑️ Eliminar</button>
        </td>
      </tr>
    `;
    }).join('');
  } catch (error) {
    console.error('Error cargando media:', error);
    showError('Error al cargar archivos de media');
  }
}

function formatFileSize(bytes) {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
}

function openMediaUploadModal() {
  // Crear modal simple para subir archivo
  const modal = document.createElement('div');
  modal.className = 'modal active';
  modal.innerHTML = `
    <div class="modal-content">
      <div class="modal-header">
        <h2>Subir Archivo</h2>
        <button class="close-modal" onclick="this.closest('.modal').remove()">&times;</button>
      </div>
      <div>
        <div class="form-group">
          <label>Archivo</label>
          <input type="file" id="mediaFileInput" class="form-input" accept="image/*,video/*,application/pdf" />
        </div>
        <div class="form-group">
          <label>Alt Text (para imágenes)</label>
          <input type="text" id="mediaAltText" class="form-input" />
        </div>
        <div class="form-group">
          <label>Descripción</label>
          <textarea id="mediaDescription" class="form-input" rows="3"></textarea>
        </div>
        <div class="form-group">
          <label>Categoría</label>
          <select id="mediaCategory" class="form-input">
            <option value="">Sin categoría</option>
            <option value="Tours">Tours</option>
            <option value="Hero">Hero</option>
            <option value="Gallery">Galería</option>
            <option value="Blog">Blog</option>
          </select>
        </div>
        <div class="btn-group">
          <button class="btn btn-secondary" onclick="this.closest('.modal').remove()">Cancelar</button>
          <button class="btn btn-primary" onclick="uploadMediaFile()">📤 Subir</button>
        </div>
      </div>
    </div>
  `;
  document.body.appendChild(modal);
}

async function uploadMediaFile() {
  try {
    const fileInput = document.getElementById('mediaFileInput');
    const file = fileInput?.files[0];
    
    if (!file) {
      showError('Por favor selecciona un archivo');
      return;
    }
    
    const altText = document.getElementById('mediaAltText')?.value || null;
    const description = document.getElementById('mediaDescription')?.value || null;
    const category = document.getElementById('mediaCategory')?.value || null;
    
    await api.uploadMediaFile(file, altText, description, category);
    showSuccess('Archivo subido exitosamente');
    document.querySelector('.modal')?.remove();
    await loadMedia();
  } catch (error) {
    console.error('Error subiendo archivo:', error);
    showError('Error al subir el archivo');
  }
}

async function deleteMediaFile(mediaId) {
  const id = (mediaId != null && mediaId !== '') ? String(mediaId).trim() : null;
  if (!id) {
    showError('ID de archivo no válido');
    return;
  }
  if (!confirm('¿Estás seguro de eliminar este archivo?')) return;
  
  try {
    await api.deleteMediaFile(id);
    showSuccess('Archivo eliminado exitosamente');
    await loadMedia();
  } catch (error) {
    console.error('Error eliminando archivo:', error);
    showError(error?.message || 'Error al eliminar el archivo');
  }
}

// Pages
async function loadPages() {
  try {
    const isPublished = document.getElementById('pagesStatusFilter')?.value || null;
    const isPublishedBool = isPublished === 'true' ? true : isPublished === 'false' ? false : null;
    
    const pages = await api.getAdminPages(isPublishedBool);
    const tbody = document.getElementById('pagesTableBody');
    
    if (!tbody) return;
    
    if (!pages || pages.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="loading">No hay páginas</td></tr>';
      return;
    }
    
    tbody.innerHTML = pages.map(page => `
      <tr>
        <td><strong>${page.title}</strong></td>
        <td><code>${page.slug}</code></td>
        <td>${page.template || '-'}</td>
        <td>${page.isPublished ? '<span class="badge badge-success">Publicada</span>' : '<span class="badge badge-warning">Borrador</span>'}</td>
        <td>${new Date(page.createdAt).toLocaleDateString()}</td>
        <td>
          <button class="btn btn-primary btn-sm" onclick="editPage('${page.id}')">✏️ Editar</button>
          <button class="btn btn-danger btn-sm" onclick="deletePage('${page.id}')">🗑️ Eliminar</button>
        </td>
      </tr>
    `).join('');
  } catch (error) {
    console.error('Error cargando páginas:', error);
    showError('Error al cargar páginas');
  }
}

function openPageModal(pageId = null) {
  // Modal para crear/editar página
  const modal = document.createElement('div');
  modal.className = 'modal active';
  modal.id = 'pageModal';
  modal.innerHTML = `
    <div class="modal-content" style="max-width: 800px;">
      <div class="modal-header">
        <h2>${pageId ? 'Editar Página' : 'Nueva Página'}</h2>
        <button class="close-modal" onclick="closePageModal()">&times;</button>
      </div>
      <div id="pageModalBody">
        <div class="loading">Cargando...</div>
      </div>
    </div>
  `;
  document.body.appendChild(modal);
  
  if (pageId) {
    editPage(pageId);
  } else {
    loadPageForm();
  }
}

async function loadPageForm(pageId = null) {
  const body = document.getElementById('pageModalBody');
  if (!body) return;
  
  let pageData = null;
  if (pageId) {
    try {
      pageData = await api.getAdminPage(pageId);
    } catch (error) {
      console.error('Error cargando página:', error);
      showError('Error al cargar la página');
      return;
    }
  }
  
  body.innerHTML = `
    <div class="form-group">
      <label>Título</label>
      <input type="text" id="pageTitle" value="${pageData?.title || ''}" class="form-input" required />
    </div>
    <div class="form-group">
      <label>Slug (URL amigable)</label>
      <input type="text" id="pageSlug" value="${pageData?.slug || ''}" class="form-input" required pattern="[a-z0-9]+(?:-[a-z0-9]+)*" />
      <small style="color: #64748b;">Solo letras minúsculas, números y guiones</small>
    </div>
    <div class="form-group">
      <label>Contenido</label>
      <textarea id="pageContent" class="form-input" rows="10" required>${pageData?.content || ''}</textarea>
    </div>
    <div class="form-group">
      <label>Excerpt (Resumen)</label>
      <textarea id="pageExcerpt" class="form-input" rows="3">${pageData?.excerpt || ''}</textarea>
    </div>
    <div class="form-group">
      <label>Template</label>
      <select id="pageTemplate" class="form-input">
        <option value="">Default</option>
        <option value="Blog" ${pageData?.template === 'Blog' ? 'selected' : ''}>Blog</option>
      </select>
    </div>
    <div class="form-group">
      <label>
        <input type="checkbox" id="pageIsPublished" ${pageData?.isPublished ? 'checked' : ''} />
        Publicada
      </label>
    </div>
    <div class="btn-group">
      <button class="btn btn-secondary" onclick="closePageModal()">Cancelar</button>
      <button class="btn btn-primary" onclick="savePage('${pageId || ''}')">💾 Guardar</button>
    </div>
  `;
}

async function editPage(pageId) {
  await loadPageForm(pageId);
}

async function savePage(pageId) {
  try {
    const data = {
      title: document.getElementById('pageTitle').value,
      slug: document.getElementById('pageSlug').value,
      content: document.getElementById('pageContent').value,
      excerpt: document.getElementById('pageExcerpt').value || null,
      template: document.getElementById('pageTemplate').value || null,
      isPublished: document.getElementById('pageIsPublished').checked
    };
    
    if (pageId) {
      await api.updatePage(pageId, data);
      showSuccess('Página actualizada exitosamente');
    } else {
      await api.createPage(data);
      showSuccess('Página creada exitosamente');
    }
    
    closePageModal();
    await loadPages();
  } catch (error) {
    console.error('Error guardando página:', error);
    showError(error.message || 'Error al guardar la página');
  }
}

function closePageModal() {
  document.getElementById('pageModal')?.remove();
}

async function deletePage(pageId) {
  if (!confirm('¿Estás seguro de eliminar esta página? Esta acción no se puede deshacer.')) return;
  
  try {
    await api.deletePage(pageId);
    showSuccess('Página eliminada exitosamente');
    await loadPages();
  } catch (error) {
    console.error('Error eliminando página:', error);
    showError('Error al eliminar la página');
  }
}

async function loadBlogComments() {
  try {
    const statusFilter = document.getElementById('commentStatusFilter')?.value;
    const res = await api.getAllBlogComments(1, 50, statusFilter ? parseInt(statusFilter, 10) : null);
    const commentsList = res?.Comments ?? res?.comments ?? (Array.isArray(res) ? res : []);
    const tbody = document.getElementById('blogCommentsTableBody');
    if (!tbody) return;
    
    if (!commentsList || commentsList.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="loading">No hay comentarios</td></tr>';
      return;
    }
    
    tbody.innerHTML = commentsList.map(comment => {
      const statusBadges = {
        0: '<span class="badge badge-warning">Pendiente</span>',
        1: '<span class="badge badge-success">Aprobado</span>',
        2: '<span class="badge badge-danger">Rechazado</span>',
        3: '<span class="badge badge-danger">Spam</span>'
      };
      const blogPostTitle = comment.BlogPostTitle ?? comment.blogPostTitle ?? '-';
      const authorName = comment.AuthorName ?? comment.authorName ?? '-';
      const content = comment.Content ?? comment.content ?? '';
      const status = comment.Status ?? comment.status ?? 0;
      const createdAt = comment.CreatedAt ?? comment.createdAt;
      const id = comment.Id ?? comment.id ?? '';
      return `
        <tr>
          <td>${escapeHtml(blogPostTitle)}</td>
          <td>${escapeHtml(authorName)}</td>
          <td>${escapeHtml(String(content).substring(0, 50))}...</td>
          <td>${statusBadges[status] || '-'}</td>
          <td>${formatDate(createdAt)}</td>
          <td>
            ${status === 0 ? `<button class="btn btn-success" onclick="moderateComment('${id}', 1)">Aprobar</button>` : ''}
            ${status !== 2 ? `<button class="btn btn-danger" onclick="moderateComment('${id}', 2)">Rechazar</button>` : ''}
          </td>
        </tr>
      `;
    }).join('');
  } catch (error) {
    console.error('Error cargando comentarios:', error);
    showError('Error al cargar comentarios');
  }
}

async function moderateComment(commentId, status) {
  try {
    await api.moderateBlogComment(commentId, status);
    showSuccess('Comentario moderado exitosamente');
    await loadBlogComments();
  } catch (error) {
    console.error('Error moderando comentario:', error);
    showError('Error al moderar comentario');
  }
}

// Reports
async function loadReports() {
  try {
    const startDate = document.getElementById('reportStartDate')?.value;
    const endDate = document.getElementById('reportEndDate')?.value;
    
    const summary = await api.getReportsSummary(startDate, endDate);
    const timeseries = await api.getTimeseriesReport(startDate, endDate);
    const toursReport = await api.getToursReport(startDate, endDate);
    
    // Mostrar resumen (soporta PascalCase y camelCase)
    const b = summary.Bookings || summary.bookings || {};
    const r = summary.Revenue || summary.revenue || {};
    const convRate = summary.ConversionRate ?? summary.conversionRate ?? 0;
    const summaryDiv = document.getElementById('reportsSummary');
    if (summaryDiv) {
      summaryDiv.innerHTML = `
        <div class="stats-grid">
          <div class="stat-card">
            <h3>Total Reservas</h3>
            <div class="value">${b.Total ?? b.total ?? 0}</div>
          </div>
          <div class="stat-card">
            <h3>Ingresos Totales</h3>
            <div class="value">$${formatNumber(r.Total ?? r.total ?? 0)}</div>
          </div>
          <div class="stat-card">
            <h3>Ticket Promedio</h3>
            <div class="value">$${formatNumber(r.AverageTicket ?? r.averageTicket ?? 0)}</div>
          </div>
          <div class="stat-card">
            <h3>Tasa de Conversión</h3>
            <div class="value">${Number(convRate).toFixed(2)}%</div>
          </div>
        </div>
      `;
    }
    
    // Gráfico de series temporales
    const dataPoints = timeseries.DataPoints || timeseries.dataPoints || timeseries.data || [];
    const ctx1 = document.getElementById('timeseriesChart');
    if (ctx1) {
      if (timeseriesChart) timeseriesChart.destroy();
      timeseriesChart = new Chart(ctx1, {
        type: 'line',
        data: {
          labels: dataPoints.map(d => formatDate(d.Date || d.date)) || [],
          datasets: [{
            label: 'Ingresos',
            data: dataPoints.map(d => d.Revenue ?? d.revenue ?? 0) || [],
            borderColor: '#0ea5e9',
            backgroundColor: 'rgba(14, 165, 233, 0.1)',
            tension: 0.4
          }]
        },
        options: {
          responsive: true,
          scales: {
            y: {
              beginAtZero: true,
              ticks: {
                callback: function(value) {
                  return '$' + formatNumber(value);
                }
              }
            }
          }
        }
      });
    }
    
    // Gráfico de tours
    const ctx2 = document.getElementById('toursReportChart');
    if (ctx2) {
      if (toursReportChart) toursReportChart.destroy();
      const tours = toursReport.TopSellingTours || toursReport.topSellingTours || toursReport.tours || [];
      const top10 = (Array.isArray(tours) ? tours : []).slice(0, 10);
      toursReportChart = new Chart(ctx2, {
        type: 'bar',
        data: {
          labels: top10.map(t => t.TourName || t.tourName || '-'),
          datasets: [{
            label: 'Ventas',
            data: top10.map(t => t.TotalBookings ?? t.totalBookings ?? 0),
            backgroundColor: '#0ea5e9'
          }]
        },
        options: {
          responsive: true,
          indexAxis: 'y'
        }
      });
    }
  } catch (error) {
    console.error('Error cargando reportes:', error);
    showError('Error al cargar reportes');
  }
}

// Utilidades
function formatNumber(num) {
  if (num == null || isNaN(num)) return '0';
  return new Intl.NumberFormat('es-PA').format(Number(num));
}

function formatDate(date) {
  if (!date) return '-';
  try {
    return new Date(date).toLocaleDateString('es-PA');
  } catch {
    return '-';
  }
}

function escapeHtml(text) {
  if (text == null) return '';
  const div = document.createElement('div');
  div.textContent = String(text);
  return div.innerHTML;
}

function getBookingStatusBadge(status) {
  if (status == null || status === '') return '<span class="badge badge-secondary">-</span>';
  const s = String(status);
  const badges = {
    'Pending': '<span class="badge badge-warning">Pendiente</span>',
    'Confirmed': '<span class="badge badge-success">Confirmada</span>',
    'Cancelled': '<span class="badge badge-danger">Cancelada</span>',
    'Completed': '<span class="badge badge-info">Completada</span>',
    'Expired': '<span class="badge badge-secondary">Expirada</span>'
  };
  return badges[s] || '<span class="badge badge-secondary">' + escapeHtml(s) + '</span>';
}

function showError(message) {
  // Mostrar mensaje de error
  const errorDiv = document.createElement('div');
  errorDiv.className = 'error';
  errorDiv.textContent = message;
  document.querySelector('.admin-main').insertBefore(errorDiv, document.querySelector('.admin-main').firstChild);
  setTimeout(() => errorDiv.remove(), 5000);
}

function showSuccess(message) {
  // Mostrar mensaje de éxito
  const successDiv = document.createElement('div');
  successDiv.className = 'success';
  successDiv.textContent = message;
  document.querySelector('.admin-main').insertBefore(successDiv, document.querySelector('.admin-main').firstChild);
  setTimeout(() => successDiv.remove(), 5000);
}

// Tour Modal Functions
function openTourModal(tourId = null) {
  const modal = document.getElementById('tourModal');
  const modalTitle = document.getElementById('tourModalTitle');
  const modalBody = document.getElementById('tourModalBody');
  
  adminTourImages = [];
  
  if (tourId) {
    modalTitle.textContent = 'Editar Tour';
    modalBody.innerHTML = '<div class="loading" style="padding: 40px; text-align: center;"><div class="spinner"></div><p>Cargando tour...</p></div>';
    modal.classList.add('active');
    loadTourForEdit(tourId);
  } else {
    modalTitle.textContent = 'Nuevo Tour';
    modalBody.innerHTML = getTourFormHTML();
    initTinyMCE();
    modal.classList.add('active');
    setTimeout(() => adminUpdateTourImagesPreview(), 100);
  }
}

function closeTourModal() {
  const modal = document.getElementById('tourModal');
  modal.classList.remove('active');
  adminTourImages = [];
  if (typeof tinymce !== 'undefined') {
    tinymce.remove();
  }
}

function getTourFormHTML() {
  return `
    <form id="tourForm" onsubmit="saveTour(event)">
      <div class="form-group">
        <label>Nombre *</label>
        <input type="text" id="tourName" class="form-input" required />
      </div>
      <div class="form-group">
        <label>Imágenes del Tour (máx. 5)</label>
        <div id="adminTourImagesPreview" style="display: flex; flex-wrap: wrap; gap: 12px; margin-bottom: 12px;"></div>
        <div style="display: flex; gap: 10px; align-items: center;">
          <input type="file" id="adminTourImageInput" accept="image/jpeg,image/png,image/webp" multiple style="flex: 1;" />
          <button type="button" class="btn btn-secondary" onclick="adminUploadTourImages()">📤 Subir imágenes</button>
        </div>
        <small style="color: #64748b;">JPG, PNG, WEBP. Máx 5MB cada una. La primera será la principal.</small>
      </div>
      <div class="form-group">
        <label>Descripción *</label>
        <textarea id="tourDescription" class="form-input" rows="6" required minlength="50"></textarea>
        <small style="color: #64748b;">Mínimo 50 caracteres</small>
      </div>
      <div class="form-group">
        <label>Itinerario</label>
        <textarea id="tourItinerary" class="form-input" rows="4"></textarea>
      </div>
      <div class="form-group">
        <label>Qué Incluye</label>
        <textarea id="tourIncludes" class="form-input" rows="4"></textarea>
      </div>
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
        <div class="form-group">
          <label>Precio *</label>
          <input type="number" id="tourPrice" class="form-input" step="0.01" min="0" required />
        </div>
        <div class="form-group">
          <label>Duración (horas) *</label>
          <input type="number" id="tourDuration" class="form-input" min="1" required />
        </div>
      </div>
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
        <div class="form-group">
          <label>Capacidad Máxima *</label>
          <input type="number" id="tourCapacity" class="form-input" min="1" required />
        </div>
        <div class="form-group">
          <label>Ubicación</label>
          <input type="text" id="tourLocation" class="form-input" />
        </div>
      </div>
      <div class="form-group">
        <label>
          <input type="checkbox" id="tourIsActive" checked /> Activo
        </label>
      </div>
      <div class="btn-group">
        <button type="submit" class="btn btn-primary">Guardar</button>
        <button type="button" class="btn btn-secondary" onclick="closeTourModal()">Cancelar</button>
      </div>
    </form>
  `;
}

async function adminUploadTourImages() {
  const input = document.getElementById('adminTourImageInput');
  if (!input?.files?.length) {
    showError('Selecciona al menos una imagen');
    return;
  }
  const files = Array.from(input.files);
  if (adminTourImages.length + files.length > 5) {
    showError('Máximo 5 imágenes. Ya tienes ' + adminTourImages.length);
    return;
  }
  try {
    for (const file of files) {
      if (adminTourImages.length >= 5) break;
      const result = await api.uploadTourImage(file);
      const url = result.url || result.Url;
      if (url) adminTourImages.push(url.startsWith('http') ? url : (window.location.origin + (url.startsWith('/') ? url : '/' + url)));
    }
    adminUpdateTourImagesPreview();
    input.value = '';
  } catch (err) {
    console.error(err);
    showError('Error al subir imagen: ' + (err.message || 'Error desconocido'));
  }
}

function adminUpdateTourImagesPreview() {
  const container = document.getElementById('adminTourImagesPreview');
  if (!container) return;
  if (adminTourImages.length === 0) {
    container.innerHTML = '';
    container.style.display = 'none';
    return;
  }
  container.style.display = 'flex';
  container.innerHTML = adminTourImages.map((url, i) => `
    <div style="position: relative;">
      <img src="${url}" alt="Tour ${i+1}" style="width: 80px; height: 80px; object-fit: cover; border-radius: 8px;" />
      <button type="button" onclick="adminRemoveTourImage(${i})" style="position: absolute; top: -8px; right: -8px; background: #ef4444; color: white; border: none; border-radius: 50%; width: 24px; height: 24px; cursor: pointer; font-size: 14px;">×</button>
      ${i === 0 ? '<span style="position: absolute; bottom: 4px; left: 4px; background: #0ea5e9; color: white; padding: 2px 6px; border-radius: 4px; font-size: 11px;">Principal</span>' : ''}
    </div>
  `).join('');
}

function adminRemoveTourImage(index) {
  adminTourImages.splice(index, 1);
  adminUpdateTourImagesPreview();
}

function initTinyMCE() {
  if (typeof tinymce !== 'undefined') {
    tinymce.init({
      selector: '#tourDescription',
      height: 300,
      menubar: false,
      plugins: 'lists link image code',
      toolbar: 'undo redo | formatselect | bold italic | alignleft aligncenter alignright | bullist numlist | link image | code',
      content_style: 'body { font-family: Inter, sans-serif; font-size: 14px; }'
    });
  }
}

async function loadTourForEdit(tourId) {
  const modalBody = document.getElementById('tourModalBody');
  try {
    const tour = await api.getAdminTour(tourId);
    
    modalBody.innerHTML = getTourFormHTML();
    
    const name = tour.Name || tour.name || '';
    const description = tour.Description || tour.description || '';
    const itinerary = tour.Itinerary || tour.itinerary || '';
    const includes = tour.Includes || tour.includes || '';
    const price = tour.Price ?? tour.price ?? 0;
    const durationHours = tour.DurationHours ?? tour.durationHours ?? 0;
    const maxCapacity = tour.MaxCapacity ?? tour.maxCapacity ?? 0;
    const location = tour.Location || tour.location || '';
    const isActive = (tour.IsActive ?? tour.isActive) !== false;
    
    document.getElementById('tourName').value = name;
    document.getElementById('tourDescription').value = description;
    document.getElementById('tourItinerary').value = itinerary;
    document.getElementById('tourIncludes').value = includes;
    document.getElementById('tourPrice').value = price;
    document.getElementById('tourDuration').value = durationHours;
    document.getElementById('tourCapacity').value = maxCapacity;
    document.getElementById('tourLocation').value = location;
    document.getElementById('tourIsActive').checked = isActive;
    
    const imgs = tour.Images || tour.images || [];
    adminTourImages = (Array.isArray(imgs) ? imgs : []).map(u => {
      const url = typeof u === 'string' ? u : (u?.url || u?.imageUrl || '');
      return url.startsWith('http') ? url : (window.location.origin + (url.startsWith('/') ? url : '/' + url));
    }).filter(Boolean);
    setTimeout(() => adminUpdateTourImagesPreview(), 100);
    
    setTimeout(() => {
      initTinyMCE();
      if (typeof tinymce !== 'undefined' && tinymce.get('tourDescription')) {
        tinymce.get('tourDescription').setContent(description);
      }
    }, 100);
    
    document.getElementById('tourForm').dataset.tourId = tourId;
  } catch (error) {
    console.error('Error cargando tour:', error);
    showError('Error al cargar tour');
    closeTourModal();
  }
}

async function saveTour(e) {
  e.preventDefault();
  
  const form = e.target;
  const tourId = form.dataset.tourId;
  
  // Obtener contenido de TinyMCE si existe
  let description = '';
  if (typeof tinymce !== 'undefined' && tinymce.get('tourDescription')) {
    description = tinymce.get('tourDescription').getContent();
  } else {
    description = document.getElementById('tourDescription').value;
  }
  
  let images = [...adminTourImages];
  const baseUrl = window.location.origin;
  images = images.map(url => {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return url.startsWith('/') ? baseUrl + url : baseUrl + '/' + url;
  });
  
  const tourData = {
    name: document.getElementById('tourName').value,
    description: description,
    itinerary: document.getElementById('tourItinerary').value,
    includes: document.getElementById('tourIncludes').value,
    price: parseFloat(document.getElementById('tourPrice').value),
    durationHours: parseInt(document.getElementById('tourDuration').value),
    maxCapacity: parseInt(document.getElementById('tourCapacity').value),
    location: document.getElementById('tourLocation').value,
    isActive: document.getElementById('tourIsActive').checked,
    images: images
  };
  
  try {
    if (tourId) {
      await api.updateTour(tourId, tourData);
      showSuccess('Tour actualizado exitosamente');
    } else {
      await api.createTour(tourData);
      showSuccess('Tour creado exitosamente');
    }
    
    closeTourModal();
    await loadTours();
  } catch (error) {
    console.error('Error guardando tour:', error);
    showError('Error al guardar tour');
  }
}

async function editTour(tourId) {
  openTourModal(tourId);
}

async function deleteTour(tourId) {
  if (!confirm('¿Estás seguro de eliminar este tour?')) return;
  
  try {
    await api.deleteTour(tourId);
    showSuccess('Tour eliminado exitosamente');
    await loadTours();
  } catch (error) {
    console.error('Error eliminando tour:', error);
    showError('Error al eliminar tour');
  }
}

// CMS Blocks Editor
const CMS_BLOCKS_DEFINITIONS = [
  { key: 'hero', name: 'Hero', description: 'Título principal, subtítulo, precio y CTA' },
  { key: 'social', name: 'Prueba Social', description: 'Sellos de confianza (guía certificado, cancelación flexible, idiomas)' },
  { key: 'highlights', name: 'Highlights Rápidos', description: 'Duración, tipo de grupo, nivel físico, punto de encuentro' },
  { key: 'story', name: 'Historia del Tour', description: 'Contenido WYSIWYG emocional del tour' },
  { key: 'includes', name: 'Incluye / No Incluye', description: 'Listas de lo que incluye y no incluye el tour' },
  { key: 'availability', name: 'Disponibilidad y Precio', description: 'Calendario, personas, precio dinámico, mensaje de urgencia' },
  { key: 'map', name: 'Mapa', description: 'Ubicación con Google Maps y coordenadas' },
  { key: 'reviews', name: 'Reviews', description: 'Reseñas y calificaciones (top 3-5)' },
  { key: 'final_cta', name: 'CTA Final', description: 'Llamado a la acción final editable' }
];

const DEFAULT_BLOCK_ORDER = ['hero', 'social', 'highlights', 'story', 'includes', 'availability', 'map', 'reviews', 'final_cta'];

let currentTourIdForBlocks = null;
let currentBlocksState = [];

async function editTourBlocks(tourId) {
  currentTourIdForBlocks = tourId;
  
  try {
    const tour = await api.getAdminTour(tourId);
    const modal = document.getElementById('cmsBlocksModal');
    const modalTitle = document.getElementById('cmsBlocksModalTitle');
    const modalBody = document.getElementById('cmsBlocksModalBody');
    
    modalTitle.textContent = `Bloques CMS: ${tour.name || tour.Name || 'Tour'}`;
    
    // Obtener orden y estado actual (manejar tanto camelCase como PascalCase)
    let blockOrder = DEFAULT_BLOCK_ORDER;
    let blockEnabled = {};
    
    try {
      const blockOrderRaw = tour.blockOrder || tour.BlockOrder;
      if (blockOrderRaw) {
        blockOrder = typeof blockOrderRaw === 'string' ? JSON.parse(blockOrderRaw) : blockOrderRaw;
      }
      const blockEnabledRaw = tour.blockEnabled || tour.BlockEnabled;
      if (blockEnabledRaw) {
        blockEnabled = typeof blockEnabledRaw === 'string' ? JSON.parse(blockEnabledRaw) : blockEnabledRaw;
      }
    } catch (e) {
      console.warn('Error parsing block order/enabled:', e);
    }
    
    // Inicializar estado de bloques
    currentBlocksState = blockOrder.map((blockKey, index) => {
      const definition = CMS_BLOCKS_DEFINITIONS.find(b => b.key === blockKey);
      return {
        key: blockKey,
        name: definition?.name || blockKey,
        description: definition?.description || '',
        enabled: blockEnabled[blockKey] !== false, // Por defecto true si no está definido
        order: index
      };
    });
    
    // Agregar bloques que no están en el orden pero existen en las definiciones
    CMS_BLOCKS_DEFINITIONS.forEach(def => {
      if (!currentBlocksState.find(b => b.key === def.key)) {
        currentBlocksState.push({
          key: def.key,
          name: def.name,
          description: def.description,
          enabled: blockEnabled[def.key] !== false,
          order: currentBlocksState.length
        });
      }
    });
    
    renderCmsBlocksList();
    initDragAndDrop();
    
    modal.classList.add('active');
  } catch (error) {
    console.error('Error cargando bloques CMS:', error);
    showError('Error al cargar bloques CMS del tour');
  }
}

function renderCmsBlocksList() {
  const list = document.getElementById('cmsBlocksList');
  if (!list) return;
  
  // Ordenar por order
  const sortedBlocks = [...currentBlocksState].sort((a, b) => a.order - b.order);
  
  // Actualizar order de todos los bloques según su posición en sortedBlocks
  sortedBlocks.forEach((block, index) => {
    block.order = index;
  });
  
  list.innerHTML = sortedBlocks.map((block, index) => `
    <div class="cms-block-item ${block.enabled ? '' : 'disabled'}" 
         data-block-key="${block.key}" 
         draggable="true"
         data-order="${index}">
      <div class="cms-block-drag-handle">☰</div>
      <div class="cms-block-order">${index + 1}</div>
      <div class="cms-block-info">
        <div class="cms-block-name">${block.name}</div>
        <div class="cms-block-description">${block.description}</div>
      </div>
      <div class="cms-block-toggle ${block.enabled ? 'active' : ''}" 
           onclick="toggleBlock('${block.key}')">
        <div class="cms-block-toggle-slider"></div>
      </div>
    </div>
  `).join('');
  
  // Inicializar drag & drop después de renderizar
  initDragAndDrop();
}

function initDragAndDrop() {
  const list = document.getElementById('cmsBlocksList');
  if (!list) return;
  
  const items = list.querySelectorAll('.cms-block-item');
  
  items.forEach(item => {
    item.addEventListener('dragstart', handleDragStart);
    item.addEventListener('dragover', handleDragOver);
    item.addEventListener('drop', handleDrop);
    item.addEventListener('dragend', handleDragEnd);
    item.addEventListener('dragenter', handleDragEnter);
    item.addEventListener('dragleave', handleDragLeave);
  });
}

let draggedElement = null;
let draggedIndex = null;

function handleDragStart(e) {
  draggedElement = this;
  draggedIndex = parseInt(this.dataset.order);
  this.classList.add('dragging');
  e.dataTransfer.effectAllowed = 'move';
  e.dataTransfer.setData('text/html', this.innerHTML);
}

function handleDragOver(e) {
  if (e.preventDefault) {
    e.preventDefault();
  }
  e.dataTransfer.dropEffect = 'move';
  return false;
}

function handleDragEnter(e) {
  if (this !== draggedElement) {
    this.classList.add('drag-over');
  }
}

function handleDragLeave(e) {
  this.classList.remove('drag-over');
}

function handleDrop(e) {
  if (e.stopPropagation) {
    e.stopPropagation();
  }
  
  if (draggedElement !== this) {
    const dropIndex = parseInt(this.dataset.order);
    const draggedIndex = parseInt(draggedElement.dataset.order);
    const draggedBlockKey = draggedElement.dataset.blockKey;
    const dropBlockKey = this.dataset.blockKey;
    
    // Reordenar en el estado: mover el bloque arrastrado a la posición del bloque destino
    const draggedBlock = currentBlocksState.find(b => b.key === draggedBlockKey);
    const dropBlock = currentBlocksState.find(b => b.key === dropBlockKey);
    
    if (draggedBlock && dropBlock) {
      // Intercambiar órdenes
      const tempOrder = draggedBlock.order;
      draggedBlock.order = dropBlock.order;
      dropBlock.order = tempOrder;
    }
    
    // Re-renderizar (esto actualizará los orders y números)
    renderCmsBlocksList();
  }
  
  this.classList.remove('drag-over');
  return false;
}

function handleDragEnd(e) {
  this.classList.remove('dragging');
  const items = document.querySelectorAll('.cms-block-item');
  items.forEach(item => item.classList.remove('drag-over'));
}

function toggleBlock(blockKey) {
  const block = currentBlocksState.find(b => b.key === blockKey);
  if (block) {
    block.enabled = !block.enabled;
    renderCmsBlocksList();
  }
}

async function saveCmsBlocks() {
  if (!currentTourIdForBlocks) return;
  
  const btn = document.getElementById('saveCmsBlocksBtn');
  const originalText = btn.textContent;
  btn.disabled = true;
  btn.textContent = 'Guardando...';
  
  try {
    // Ordenar por order
    const sortedBlocks = [...currentBlocksState].sort((a, b) => a.order - b.order);
    
    // Construir block_order (array de keys en orden)
    const blockOrder = sortedBlocks.map(b => b.key);
    
    // Construir block_enabled (objeto con enabled state)
    const blockEnabled = {};
    sortedBlocks.forEach(block => {
      blockEnabled[block.key] = block.enabled;
    });
    
    // Actualizar tour con los nuevos valores
    await api.updateTour(currentTourIdForBlocks, {
      blockOrder: JSON.stringify(blockOrder),
      blockEnabled: JSON.stringify(blockEnabled)
    });
    
    showSuccess('Bloques CMS guardados exitosamente');
    closeCmsBlocksModal();
  } catch (error) {
    console.error('Error guardando bloques CMS:', error);
    showError('Error al guardar bloques CMS');
    btn.disabled = false;
    btn.textContent = originalText;
  }
}

function closeCmsBlocksModal() {
  const modal = document.getElementById('cmsBlocksModal');
  modal.classList.remove('active');
  currentTourIdForBlocks = null;
  currentBlocksState = [];
}

// Analytics
let deviceChart = null;
let currentAnalyticsPeriod = '30d';

function setAnalyticsPeriod(period) {
  currentAnalyticsPeriod = period;
  
  // Actualizar botones activos
  document.querySelectorAll('[id^="period"]').forEach(btn => {
    btn.classList.remove('btn-primary');
    btn.classList.add('btn-secondary');
  });
  
  const activeBtn = document.getElementById(`period${period}`);
  if (activeBtn) {
    activeBtn.classList.remove('btn-secondary');
    activeBtn.classList.add('btn-primary');
  }
  
  // Calcular fechas
  const endDate = new Date();
  const startDate = new Date();
  
  switch(period) {
    case 'today':
      startDate.setHours(0, 0, 0, 0);
      break;
    case '7d':
      startDate.setDate(startDate.getDate() - 7);
      break;
    case '30d':
      startDate.setDate(startDate.getDate() - 30);
      break;
  }
  
  document.getElementById('analyticsStartDate').value = startDate.toISOString().split('T')[0];
  document.getElementById('analyticsEndDate').value = endDate.toISOString().split('T')[0];
  
  loadAnalytics();
}

async function loadAnalytics() {
  try {
    const startDate = document.getElementById('analyticsStartDate')?.value;
    const endDate = document.getElementById('analyticsEndDate')?.value;
    
    // Cargar métricas
    const metrics = await api.getAnalyticsMetrics(startDate, endDate);
    renderAnalyticsKPIs(metrics);
    
    // Cargar funnel
    const funnel = await api.getAnalyticsFunnel(startDate, endDate);
    renderAnalyticsFunnel(funnel);
    
    // Cargar top tours
    const topTours = await api.getTopTours(startDate, endDate, 10);
    renderTopTours(topTours);
    
    // Cargar impacto UX
    const uxImpact = await api.getUxImpact(startDate, endDate);
    renderUxImpact(uxImpact);
    
    // Cargar gráfico de dispositivos
    if (metrics.byDevice && metrics.byDevice.length > 0) {
      renderDeviceChart(metrics.byDevice);
    }
  } catch (error) {
    console.error('Error cargando analytics:', error);
    showError('Error al cargar analytics');
  }
}

function renderAnalyticsKPIs(metrics) {
  const container = document.getElementById('analyticsKPIs');
  if (!container) return;
  
  const conversionRate = metrics.conversionRate || 0;
  const revenue = metrics.revenue || 0;
  const averageTicket = metrics.averageTicket || 0;
  
  container.innerHTML = `
    <div class="stat-card">
      <h3>Tours Vistos</h3>
      <div class="value">${formatNumber(metrics.tourViews || 0)}</div>
    </div>
    <div class="stat-card">
      <h3>Reservas Iniciadas</h3>
      <div class="value">${formatNumber(metrics.reserveClicks || 0)}</div>
    </div>
    <div class="stat-card">
      <h3>Pagos Exitosos</h3>
      <div class="value">${formatNumber(metrics.paymentSuccess || 0)}</div>
    </div>
    <div class="stat-card">
      <h3>Conversión</h3>
      <div class="value" style="color: ${conversionRate > 5 ? '#16a34a' : conversionRate > 2 ? '#f59e0b' : '#dc2626'}; font-size: 2rem;">
        ${conversionRate.toFixed(2)}%
      </div>
    </div>
    <div class="stat-card">
      <h3>Ingresos</h3>
      <div class="value" style="color: #16a34a;">$${formatNumber(revenue)}</div>
    </div>
    <div class="stat-card">
      <h3>Ticket Promedio</h3>
      <div class="value">$${formatNumber(averageTicket)}</div>
    </div>
  `;
}

function renderAnalyticsFunnel(funnel) {
  const container = document.getElementById('analyticsFunnel');
  if (!container) return;
  
  const steps = [
    { label: 'Vista de Tour', value: funnel.tourViewed || 0, color: '#0ea5e9' },
    { label: 'Vista Disponibilidad', value: funnel.availabilityViewed || 0, color: '#3b82f6' },
    { label: 'Clic en Reservar', value: funnel.reserveClicked || 0, color: '#6366f1' },
    { label: 'Vista de Checkout', value: funnel.checkoutViewed || 0, color: '#8b5cf6' },
    { label: 'Inicio de Pago', value: funnel.paymentStarted || 0, color: '#a855f7' },
    { label: 'Pago Exitoso', value: funnel.paymentSuccess || 0, color: '#10b981' }
  ];
  
  const maxValue = Math.max(...steps.map(s => s.value), 1);
  
  container.innerHTML = `
    <div style="display: flex; flex-direction: column; gap: 20px; max-width: 800px;">
      ${steps.map((step, index) => {
        const percentage = maxValue > 0 ? (step.value / maxValue * 100) : 0;
        const dropoff = index > 0 && steps[index - 1].value > 0 
          ? ((steps[index - 1].value - step.value) / steps[index - 1].value * 100).toFixed(1)
          : 0;
        const stepConversion = index > 0 && steps[index - 1].value > 0
          ? (step.value / steps[index - 1].value * 100).toFixed(1)
          : 100;
        
        return `
          <div style="background: white; padding: 16px; border-radius: 8px; border-left: 4px solid ${step.color};">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <div>
                <div style="font-weight: 600; color: #1f2937; margin-bottom: 4px;">${step.label}</div>
                ${index > 0 ? `
                  <small style="color: #6b7280;">
                    ${stepConversion}% del paso anterior
                    ${dropoff > 0 ? ` · Abandono: ${dropoff}%` : ''}
                  </small>
                ` : ''}
              </div>
              <div style="font-size: 1.5rem; font-weight: 700; color: ${step.color};">
                ${formatNumber(step.value)}
              </div>
            </div>
            <div style="background: #f3f4f6; border-radius: 4px; height: 32px; overflow: hidden; position: relative;">
              <div style="background: ${step.color}; height: 100%; width: ${percentage}%; transition: width 0.3s; display: flex; align-items: center; padding-left: 12px;">
                ${percentage > 10 ? `<span style="color: white; font-size: 12px; font-weight: 600;">${percentage.toFixed(0)}%</span>` : ''}
              </div>
            </div>
          </div>
        `;
      }).join('')}
    </div>
  `;
}

function renderTopTours(tours) {
  const container = document.getElementById('topToursTable');
  if (!container) return;
  
  if (!tours || tours.length === 0) {
    container.innerHTML = '<p style="color: #6b7280; text-align: center; padding: 20px;">No hay datos disponibles</p>';
    return;
  }
  
  container.innerHTML = `
    <div style="overflow-x: auto;">
      <table style="width: 100%; border-collapse: collapse;">
        <thead>
          <tr style="background: #f9fafb; border-bottom: 2px solid #e5e7eb;">
            <th style="padding: 12px; text-align: left; font-size: 0.85rem; color: #6b7280; font-weight: 600;">Tour</th>
            <th style="padding: 12px; text-align: right; font-size: 0.85rem; color: #6b7280; font-weight: 600;">Vistas</th>
            <th style="padding: 12px; text-align: right; font-size: 0.85rem; color: #6b7280; font-weight: 600;">Reservas</th>
            <th style="padding: 12px; text-align: right; font-size: 0.85rem; color: #6b7280; font-weight: 600;">Conv.</th>
            <th style="padding: 12px; text-align: right; font-size: 0.85rem; color: #6b7280; font-weight: 600;">Ingresos</th>
          </tr>
        </thead>
        <tbody>
          ${tours.map((tour, index) => {
            const conversionColor = tour.conversionRate > 5 ? '#16a34a' : tour.conversionRate > 2 ? '#f59e0b' : '#dc2626';
            return `
              <tr style="border-bottom: 1px solid #e5e7eb; ${index % 2 === 0 ? 'background: #fafafa;' : ''}">
                <td style="padding: 12px; font-weight: 500;">${escapeHtml(tour.tourName)}</td>
                <td style="padding: 12px; text-align: right; color: #6b7280;">${formatNumber(tour.views || 0)}</td>
                <td style="padding: 12px; text-align: right; color: #6b7280;">${formatNumber(tour.paymentSuccess || 0)}</td>
                <td style="padding: 12px; text-align: right; color: ${conversionColor}; font-weight: 600;">${(tour.conversionRate || 0).toFixed(2)}%</td>
                <td style="padding: 12px; text-align: right; color: #16a34a; font-weight: 600;">$${formatNumber(tour.revenue || 0)}</td>
              </tr>
            `;
          }).join('')}
        </tbody>
      </table>
    </div>
  `;
}

function renderUxImpact(impact) {
  const container = document.getElementById('uxImpact');
  if (!container) return;
  
  const stickyCta = impact.stickyCta || {};
  const urgency = impact.urgency || {};
  const byDevice = impact.byDevice || {};
  
  container.innerHTML = `
    <div style="display: flex; flex-direction: column; gap: 24px;">
      <!-- Sticky CTA Impact -->
      <div style="background: white; padding: 16px; border-radius: 8px; border: 1px solid #e5e7eb;">
        <div style="font-weight: 600; margin-bottom: 12px; color: #1f2937;">Sticky CTA</div>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
          <span style="color: #6b7280; font-size: 0.9rem;">Mostrado</span>
          <span style="font-weight: 600;">${formatNumber(stickyCta.shown || 0)}</span>
        </div>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
          <span style="color: #6b7280; font-size: 0.9rem;">Convirtió</span>
          <span style="font-weight: 600; color: #16a34a;">${formatNumber(stickyCta.converted || 0)}</span>
        </div>
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <span style="color: #6b7280; font-size: 0.9rem;">Tasa de Conversión</span>
          <span style="font-weight: 700; font-size: 1.2rem; color: ${(stickyCta.conversionRate || 0) > 10 ? '#16a34a' : '#f59e0b'};">
            ${(stickyCta.conversionRate || 0).toFixed(2)}%
          </span>
        </div>
      </div>
      
      <!-- Urgency Impact -->
      <div style="background: white; padding: 16px; border-radius: 8px; border: 1px solid #e5e7eb;">
        <div style="font-weight: 600; margin-bottom: 12px; color: #1f2937;">Urgencia</div>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
          <span style="color: #6b7280; font-size: 0.9rem;">Mostrado</span>
          <span style="font-weight: 600;">${formatNumber(urgency.shown || 0)}</span>
        </div>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
          <span style="color: #6b7280; font-size: 0.9rem;">Convirtió</span>
          <span style="font-weight: 600; color: #16a34a;">${formatNumber(urgency.converted || 0)}</span>
        </div>
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <span style="color: #6b7280; font-size: 0.9rem;">Tasa de Conversión</span>
          <span style="font-weight: 700; font-size: 1.2rem; color: ${(urgency.conversionRate || 0) > 10 ? '#16a34a' : '#f59e0b'};">
            ${(urgency.conversionRate || 0).toFixed(2)}%
          </span>
        </div>
      </div>
      
      <!-- Device Impact -->
      <div style="background: white; padding: 16px; border-radius: 8px; border: 1px solid #e5e7eb;">
        <div style="font-weight: 600; margin-bottom: 12px; color: #1f2937;">Por Dispositivo</div>
        <div style="display: flex; flex-direction: column; gap: 12px;">
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <span style="color: #6b7280;">📱 Mobile</span>
            <div style="text-align: right;">
              <div style="font-weight: 600;">${formatNumber(byDevice.mobile?.sessions || 0)} sesiones</div>
              <div style="font-size: 0.85rem; color: ${(byDevice.mobile?.conversionRate || 0) > 5 ? '#16a34a' : '#f59e0b'};">
                ${(byDevice.mobile?.conversionRate || 0).toFixed(2)}% conv.
              </div>
            </div>
          </div>
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <span style="color: #6b7280;">💻 Desktop</span>
            <div style="text-align: right;">
              <div style="font-weight: 600;">${formatNumber(byDevice.desktop?.sessions || 0)} sesiones</div>
              <div style="font-size: 0.85rem; color: ${(byDevice.desktop?.conversionRate || 0) > 5 ? '#16a34a' : '#f59e0b'};">
                ${(byDevice.desktop?.conversionRate || 0).toFixed(2)}% conv.
              </div>
            </div>
          </div>
          ${byDevice.tablet?.sessions > 0 ? `
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <span style="color: #6b7280;">📱 Tablet</span>
            <div style="text-align: right;">
              <div style="font-weight: 600;">${formatNumber(byDevice.tablet?.sessions || 0)} sesiones</div>
              <div style="font-size: 0.85rem; color: ${(byDevice.tablet?.conversionRate || 0) > 5 ? '#16a34a' : '#f59e0b'};">
                ${(byDevice.tablet?.conversionRate || 0).toFixed(2)}% conv.
              </div>
            </div>
          </div>
          ` : ''}
        </div>
      </div>
    </div>
  `;
}

function renderDeviceChart(deviceData) {
  const ctx = document.getElementById('deviceChart');
  if (!ctx) return;
  
  if (deviceChart) deviceChart.destroy();
  
  deviceChart = new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: deviceData.map(d => d.device || 'Desconocido'),
      datasets: [{
        data: deviceData.map(d => d.count),
        backgroundColor: ['#0ea5e9', '#6366f1', '#10b981']
      }]
    },
    options: {
      responsive: true,
      plugins: {
        legend: {
          position: 'bottom'
        }
      }
    }
  });
}

// Export Reports
async function exportReport(type, format) {
  try {
    const startDate = document.getElementById('reportStartDate')?.value;
    const endDate = document.getElementById('reportEndDate')?.value;
    
    const params = new URLSearchParams();
    params.append('type', type);
    params.append('format', format);
    if (startDate) params.append('startDate', startDate);
    if (endDate) params.append('endDate', endDate);
    
    const url = `/api/admin/reports/export?${params.toString()}`;
    
    // Crear link temporal para descarga
    const link = document.createElement('a');
    link.href = url;
    link.download = `reporte_${type}_${new Date().toISOString().split('T')[0]}.${format === 'excel' ? 'xlsx' : 'pdf'}`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    showSuccess(`Exportación iniciada. El archivo se descargará pronto.`);
  } catch (error) {
    console.error('Error exportando reporte:', error);
    showError('Error al exportar reporte. La funcionalidad está en desarrollo.');
  }
}
