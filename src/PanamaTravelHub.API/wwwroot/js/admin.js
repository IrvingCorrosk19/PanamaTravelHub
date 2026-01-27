// Admin Panel JavaScript
let revenueChart, bookingsStatusChart, topToursChart, timeseriesChart, toursReportChart;

// Inicialización
document.addEventListener('DOMContentLoaded', async () => {
  // Verificar autenticación
  const token = localStorage.getItem('accessToken');
  if (!token) {
    window.location.href = '/login.html';
    return;
  }

  // Verificar rol admin
  try {
    const user = await api.getCurrentUser();
    if (!user.roles || !user.roles.includes('Admin')) {
      alert('No tienes permisos para acceder al panel administrativo');
      window.location.href = '/';
      return;
    }
  } catch (error) {
    console.error('Error verificando usuario:', error);
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
      'homepage': 'Contenido de Homepage',
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
    
    // Actualizar estadísticas
    document.getElementById('statTotalBookings').textContent = summary.bookings?.total || 0;
    document.getElementById('statTotalRevenue').textContent = `$${formatNumber(summary.revenue?.total || 0)}`;
    document.getElementById('statActiveTours').textContent = summary.tours?.active || 0;
    document.getElementById('statActiveUsers').textContent = summary.users?.total || 0;
    
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
    
    revenueChart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: timeseries.data?.map(d => formatDate(d.date)) || [],
        datasets: [{
          label: 'Ingresos',
          data: timeseries.data?.map(d => d.revenue) || [],
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
    
    bookingsStatusChart = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: ['Confirmadas', 'Pendientes', 'Canceladas'],
        datasets: [{
          data: [
            summary.bookings?.confirmed || 0,
            summary.bookings?.pending || 0,
            summary.bookings?.cancelled || 0
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
    
    const top10 = (toursReport.tours || []).slice(0, 10);
    
    topToursChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: top10.map(t => t.tourName),
        datasets: [{
          label: 'Ventas',
          data: top10.map(t => t.totalBookings),
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
    const tours = await api.getAdminTours();
    const tbody = document.getElementById('toursTableBody');
    if (!tbody) return;
    
    if (tours.length === 0) {
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
    const bookings = await api.getAdminBookings();
    const tbody = document.getElementById('bookingsTableBody');
    if (!tbody) return;
    
    if (bookings.length === 0) {
      tbody.innerHTML = '<tr><td colspan="7" class="loading">No hay reservas</td></tr>';
      return;
    }
    
    tbody.innerHTML = bookings.map(booking => `
      <tr>
        <td>${booking.id.substring(0, 8)}...</td>
        <td>${escapeHtml(booking.tourName || '-')}</td>
        <td>${escapeHtml(booking.userEmail || '-')}</td>
        <td>${formatDate(booking.tourDate)}</td>
        <td>$${formatNumber(booking.totalAmount)}</td>
        <td>${getBookingStatusBadge(booking.status)}</td>
        <td>
          <button class="btn btn-secondary" onclick="viewBooking('${booking.id}')">Ver</button>
        </td>
      </tr>
    `).join('');
  } catch (error) {
    console.error('Error cargando reservas:', error);
    showError('Error al cargar reservas');
  }
}

// Users
async function loadUsers() {
  try {
    const users = await api.getAdminUsers();
    const tbody = document.getElementById('usersTableBody');
    if (!tbody) return;
    
    if (users.length === 0) {
      tbody.innerHTML = '<tr><td colspan="5" class="loading">No hay usuarios</td></tr>';
      return;
    }
    
    tbody.innerHTML = users.map(user => `
      <tr>
        <td>${escapeHtml(user.email)}</td>
        <td>${escapeHtml(`${user.firstName || ''} ${user.lastName || ''}`.trim() || '-')}</td>
        <td>${user.isActive ? '<span class="badge badge-success">Activo</span>' : '<span class="badge badge-danger">Inactivo</span>'}</td>
        <td>${user.roles?.includes('Admin') ? '<span class="badge badge-info">Admin</span>' : '<span class="badge badge-secondary">Usuario</span>'}</td>
        <td>
          <button class="btn btn-secondary" onclick="editUser('${user.id}')">Editar</button>
        </td>
      </tr>
    `).join('');
  } catch (error) {
    console.error('Error cargando usuarios:', error);
    showError('Error al cargar usuarios');
  }
}

// Coupons
async function loadCoupons() {
  try {
    const coupons = await api.getCoupons();
    const tbody = document.getElementById('couponsTableBody');
    if (!tbody) return;
    
    if (coupons.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="loading">No hay cupones</td></tr>';
      return;
    }
    
    tbody.innerHTML = coupons.map(coupon => `
      <tr>
        <td><strong>${escapeHtml(coupon.code)}</strong></td>
        <td>${coupon.discountType === 1 ? 'Porcentaje' : 'Monto Fijo'}</td>
        <td>${coupon.discountType === 1 ? `${coupon.discountValue}%` : `$${formatNumber(coupon.discountValue)}`}</td>
        <td>${coupon.currentUses} / ${coupon.maxUses || '∞'}</td>
        <td>${coupon.isActive ? '<span class="badge badge-success">Activo</span>' : '<span class="badge badge-danger">Inactivo</span>'}</td>
        <td>
          <button class="btn btn-secondary" onclick="editCoupon('${coupon.id}')">Editar</button>
          <button class="btn btn-danger" onclick="deleteCoupon('${coupon.id}')">Eliminar</button>
        </td>
      </tr>
    `).join('');
  } catch (error) {
    console.error('Error cargando cupones:', error);
    showError('Error al cargar cupones');
  }
}

// Reviews
async function loadReviews() {
  try {
    const reviews = await api.getAllReviews();
    const tbody = document.getElementById('reviewsTableBody');
    if (!tbody) return;
    
    if (!reviews.reviews || reviews.reviews.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="loading">No hay reviews</td></tr>';
      return;
    }
    
    tbody.innerHTML = reviews.reviews.map(review => `
      <tr>
        <td>${escapeHtml(review.tourName || '-')}</td>
        <td>${escapeHtml(review.userName || review.userEmail || '-')}</td>
        <td>${'⭐'.repeat(review.rating)} (${review.rating}/5)</td>
        <td>${escapeHtml(review.comment?.substring(0, 50) || review.title || '-')}...</td>
        <td>${review.isApproved ? '<span class="badge badge-success">Aprobada</span>' : '<span class="badge badge-warning">Pendiente</span>'}</td>
        <td>
          ${!review.isApproved ? `<button class="btn btn-success" onclick="approveReview('${review.id}', '${review.tourId}')">Aprobar</button>` : ''}
          ${review.isApproved ? `<button class="btn btn-danger" onclick="rejectReview('${review.id}', '${review.tourId}')">Rechazar</button>` : ''}
        </td>
      </tr>
    `).join('');
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
    const waitlist = await api.getWaitlist();
    const tbody = document.getElementById('waitlistTableBody');
    if (!tbody) return;
    
    if (waitlist.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="loading">No hay entradas en waitlist</td></tr>';
      return;
    }
    
    tbody.innerHTML = waitlist.map(entry => `
      <tr>
        <td>${escapeHtml(entry.tourName || '-')}</td>
        <td>${escapeHtml(entry.userEmail || '-')}</td>
        <td>${formatDate(entry.requestedDate)}</td>
        <td>${entry.priority || 0}</td>
        <td>${entry.isActive ? '<span class="badge badge-success">Activo</span>' : '<span class="badge badge-danger">Inactivo</span>'}</td>
        <td>
          <button class="btn btn-danger" onclick="removeFromWaitlist('${entry.id}')">Remover</button>
        </td>
      </tr>
    `).join('');
  } catch (error) {
    console.error('Error cargando waitlist:', error);
    showError('Error al cargar waitlist');
  }
}

// Blog Comments
// Homepage Content
async function loadHomepageContent() {
  try {
    const content = await api.getAdminHomePageContent();
    const form = document.getElementById('homepageForm');
    
    if (!form) return;
    
    // Normalizar propiedades (PascalCase o camelCase)
    const heroTitle = content.HeroTitle || content.heroTitle || '';
    const heroSubtitle = content.HeroSubtitle || content.heroSubtitle || '';
    const heroImageUrl = content.HeroImageUrl || content.heroImageUrl || '';
    const heroSearchPlaceholder = content.HeroSearchPlaceholder || content.heroSearchPlaceholder || '';
    const toursSectionTitle = content.ToursSectionTitle || content.toursSectionTitle || '';
    const toursSectionSubtitle = content.ToursSectionSubtitle || content.toursSectionSubtitle || '';
    const pageTitle = content.PageTitle || content.pageTitle || '';
    const metaDescription = content.MetaDescription || content.metaDescription || '';
    const logoUrl = content.LogoUrl || content.logoUrl || '';
    const faviconUrl = content.FaviconUrl || content.faviconUrl || '';
    
    form.innerHTML = `
      <div class="form-group">
        <label>Hero Title</label>
        <input type="text" id="homepageHeroTitle" value="${escapeHtml(heroTitle)}" class="form-input" />
      </div>
      <div class="form-group">
        <label>Hero Subtitle</label>
        <textarea id="homepageHeroSubtitle" class="form-input" rows="3">${escapeHtml(heroSubtitle)}</textarea>
      </div>
      <div class="form-group">
        <label>Hero Image URL</label>
        <input type="url" id="homepageHeroImageUrl" value="${escapeHtml(heroImageUrl)}" class="form-input" />
      </div>
      <div class="form-group">
        <label>Hero Search Placeholder</label>
        <input type="text" id="homepageHeroSearchPlaceholder" value="${escapeHtml(heroSearchPlaceholder)}" class="form-input" />
      </div>
      <div class="form-group">
        <label>Tours Section Title</label>
        <input type="text" id="homepageToursSectionTitle" value="${escapeHtml(toursSectionTitle)}" class="form-input" />
      </div>
      <div class="form-group">
        <label>Tours Section Subtitle</label>
        <input type="text" id="homepageToursSectionSubtitle" value="${escapeHtml(toursSectionSubtitle)}" class="form-input" />
      </div>
      <div class="form-group">
        <label>Page Title (SEO)</label>
        <input type="text" id="homepagePageTitle" value="${escapeHtml(pageTitle)}" class="form-input" />
      </div>
      <div class="form-group">
        <label>Meta Description (SEO)</label>
        <textarea id="homepageMetaDescription" class="form-input" rows="3">${escapeHtml(metaDescription)}</textarea>
      </div>
      <div class="form-group">
        <label>Logo URL</label>
        <input type="url" id="homepageLogoUrl" value="${escapeHtml(logoUrl)}" class="form-input" />
      </div>
      <div class="form-group">
        <label>Favicon URL</label>
        <input type="url" id="homepageFaviconUrl" value="${escapeHtml(faviconUrl)}" class="form-input" />
      </div>
    `;
  } catch (error) {
    console.error('Error cargando homepage content:', error);
    showError('Error al cargar el contenido de la homepage');
  }
}

async function saveHomepageContent() {
  try {
    const data = {
      HeroTitle: document.getElementById('homepageHeroTitle')?.value || '',
      HeroSubtitle: document.getElementById('homepageHeroSubtitle')?.value || '',
      HeroImageUrl: document.getElementById('homepageHeroImageUrl')?.value || '',
      HeroSearchPlaceholder: document.getElementById('homepageHeroSearchPlaceholder')?.value || '',
      ToursSectionTitle: document.getElementById('homepageToursSectionTitle')?.value || '',
      ToursSectionSubtitle: document.getElementById('homepageToursSectionSubtitle')?.value || '',
      PageTitle: document.getElementById('homepagePageTitle')?.value || '',
      MetaDescription: document.getElementById('homepageMetaDescription')?.value || '',
      LogoUrl: document.getElementById('homepageLogoUrl')?.value || '',
      FaviconUrl: document.getElementById('homepageFaviconUrl')?.value || ''
    };
    
    await api.updateAdminHomePageContent(data);
    showSuccess('Contenido de la homepage guardado exitosamente');
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
    
    if (!media || media.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="loading">No hay archivos de media</td></tr>';
      return;
    }
    
    tbody.innerHTML = media.map(file => `
      <tr>
        <td>
          ${file.isImage ? `<img src="${file.fileUrl}" alt="${file.altText || ''}" style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;" />` : '📄'}
          <span style="margin-left: 10px;">${file.fileName}</span>
        </td>
        <td>${file.category || '-'}</td>
        <td>${file.isImage ? 'Imagen' : 'Archivo'}</td>
        <td>${formatFileSize(file.fileSize)}</td>
        <td>${new Date(file.createdAt).toLocaleDateString()}</td>
        <td>
          <button class="btn btn-danger btn-sm" onclick="deleteMediaFile('${file.id}')">🗑️ Eliminar</button>
        </td>
      </tr>
    `).join('');
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
  if (!confirm('¿Estás seguro de eliminar este archivo?')) return;
  
  try {
    await api.deleteMediaFile(mediaId);
    showSuccess('Archivo eliminado exitosamente');
    await loadMedia();
  } catch (error) {
    console.error('Error eliminando archivo:', error);
    showError('Error al eliminar el archivo');
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
    const comments = await api.getAllBlogComments(1, 50, statusFilter ? parseInt(statusFilter) : null);
    const tbody = document.getElementById('blogCommentsTableBody');
    if (!tbody) return;
    
    if (!comments.comments || comments.comments.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="loading">No hay comentarios</td></tr>';
      return;
    }
    
    tbody.innerHTML = comments.comments.map(comment => {
      const statusBadges = {
        0: '<span class="badge badge-warning">Pendiente</span>',
        1: '<span class="badge badge-success">Aprobado</span>',
        2: '<span class="badge badge-danger">Rechazado</span>',
        3: '<span class="badge badge-danger">Spam</span>'
      };
      
      return `
        <tr>
          <td>${escapeHtml(comment.blogPostTitle || '-')}</td>
          <td>${escapeHtml(comment.authorName)}</td>
          <td>${escapeHtml(comment.content.substring(0, 50))}...</td>
          <td>${statusBadges[comment.status] || '-'}</td>
          <td>${formatDate(comment.createdAt)}</td>
          <td>
            ${comment.status === 0 ? `<button class="btn btn-success" onclick="moderateComment('${comment.id}', 1)">Aprobar</button>` : ''}
            ${comment.status !== 2 ? `<button class="btn btn-danger" onclick="moderateComment('${comment.id}', 2)">Rechazar</button>` : ''}
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
    
    // Mostrar resumen
    const summaryDiv = document.getElementById('reportsSummary');
    if (summaryDiv) {
      summaryDiv.innerHTML = `
        <div class="stats-grid">
          <div class="stat-card">
            <h3>Total Reservas</h3>
            <div class="value">${summary.bookings?.total || 0}</div>
          </div>
          <div class="stat-card">
            <h3>Ingresos Totales</h3>
            <div class="value">$${formatNumber(summary.revenue?.total || 0)}</div>
          </div>
          <div class="stat-card">
            <h3>Ticket Promedio</h3>
            <div class="value">$${formatNumber(summary.revenue?.averageTicket || 0)}</div>
          </div>
          <div class="stat-card">
            <h3>Tasa de Conversión</h3>
            <div class="value">${summary.conversionRate?.toFixed(2) || 0}%</div>
          </div>
        </div>
      `;
    }
    
    // Gráfico de series temporales
    const ctx1 = document.getElementById('timeseriesChart');
    if (ctx1) {
      if (timeseriesChart) timeseriesChart.destroy();
      timeseriesChart = new Chart(ctx1, {
        type: 'line',
        data: {
          labels: timeseries.data?.map(d => formatDate(d.date)) || [],
          datasets: [{
            label: 'Ingresos',
            data: timeseries.data?.map(d => d.revenue) || [],
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
      const top10 = (toursReport.tours || []).slice(0, 10);
      toursReportChart = new Chart(ctx2, {
        type: 'bar',
        data: {
          labels: top10.map(t => t.tourName),
          datasets: [{
            label: 'Ventas',
            data: top10.map(t => t.totalBookings),
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
  return new Intl.NumberFormat('es-PA').format(num);
}

function formatDate(date) {
  if (!date) return '-';
  return new Date(date).toLocaleDateString('es-PA');
}

function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

function getBookingStatusBadge(status) {
  const badges = {
    'Pending': '<span class="badge badge-warning">Pendiente</span>',
    'Confirmed': '<span class="badge badge-success">Confirmada</span>',
    'Cancelled': '<span class="badge badge-danger">Cancelada</span>',
    'Completed': '<span class="badge badge-info">Completada</span>'
  };
  return badges[status] || status;
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
  }
}

function closeTourModal() {
  const modal = document.getElementById('tourModal');
  modal.classList.remove('active');
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
        <label>Descripción *</label>
        <textarea id="tourDescription" class="form-input" rows="6" required></textarea>
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
  
  const tourData = {
    name: document.getElementById('tourName').value,
    description: description,
    itinerary: document.getElementById('tourItinerary').value,
    includes: document.getElementById('tourIncludes').value,
    price: parseFloat(document.getElementById('tourPrice').value),
    durationHours: parseInt(document.getElementById('tourDuration').value),
    maxCapacity: parseInt(document.getElementById('tourCapacity').value),
    location: document.getElementById('tourLocation').value,
    isActive: document.getElementById('tourIsActive').checked
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
