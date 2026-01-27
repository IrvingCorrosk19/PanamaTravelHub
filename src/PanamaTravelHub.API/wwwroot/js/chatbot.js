// ============================================
// CHATBOT UI/UX - Solo Interfaz (Sin Backend)
// Diseño Premium y Emocional
// ============================================

class Chatbot {
  constructor() {
    this.isOpen = false;
    this.isTyping = false;
    this.messageHistory = [];
    this.sessionId = null; // SessionId para mantener contexto
    
    // Respuestas de ejemplo para acciones rápidas (fallback)
    this.demoResponses = {
      'tours': '¡Excelente! Tenemos una amplia variedad de tours disponibles en Panamá. Puedes explorar tours de aventura, culturales, ecológicos y más. ¿Te gustaría que te recomiende alguno en particular? 🌴✨',
      'pricing': 'Nuestros precios varían según el tipo de tour y la temporada. Ofrecemos descuentos especiales para grupos y reservas anticipadas. También tenemos cupones de descuento disponibles. ¿Quieres que te muestre las opciones? 💰',
      'booking': '¡Reservar es muy fácil! Solo necesitas: 1) Seleccionar el tour que te interesa, 2) Elegir la fecha, 3) Completar tus datos y 4) Realizar el pago. Todo el proceso toma menos de 5 minutos. ¿Necesitas ayuda con algún paso? 📅',
      'contact': 'Puedes contactarnos por: 📧 Email: info@panamatravelhub.com 📱 Teléfono: +507 1234-5678 💬 Este chat (estamos aquí para ayudarte) También puedes visitarnos en nuestras oficinas. ¿En qué podemos ayudarte? 🤝'
    };
    
    this.init();
  }

  init() {
    this.createWidget();
    this.attachEvents();
    this.loadWelcomeMessage();
  }

  createWidget() {
    const container = document.createElement('div');
    container.className = 'chatbot-container';
    container.innerHTML = `
      <div class="chatbot-window" id="chatbotWindow">
        <div class="chatbot-header">
          <div class="chatbot-header-info">
            <div class="chatbot-header-avatar">🤖</div>
            <div class="chatbot-header-text">
              <h3>Asistente Virtual</h3>
              <p>Estamos aquí para ayudarte</p>
            </div>
          </div>
          <button class="chatbot-close" id="chatbotClose" aria-label="Cerrar chat">×</button>
        </div>
        <div class="chatbot-messages" id="chatbotMessages"></div>
        <div class="chatbot-quick-actions" id="chatbotQuickActions">
          <button class="chatbot-quick-action" data-action="tours">Ver tours disponibles</button>
          <button class="chatbot-quick-action" data-action="pricing">Precios y descuentos</button>
          <button class="chatbot-quick-action" data-action="booking">Cómo reservar</button>
          <button class="chatbot-quick-action" data-action="contact">Contacto</button>
        </div>
        <div class="chatbot-input-container">
          <textarea 
            class="chatbot-input" 
            id="chatbotInput" 
            placeholder="Escribe tu pregunta..."
            rows="1"
            aria-label="Escribe tu mensaje"
          ></textarea>
          <button class="chatbot-send" id="chatbotSend" type="button" aria-label="Enviar mensaje">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z"/>
            </svg>
          </button>
        </div>
      </div>
      <button class="chatbot-button" id="chatbotButton" type="button" aria-label="Abrir chat">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
        </svg>
      </button>
    `;
    
    document.body.appendChild(container);
    
    // Agregar estilos si no están cargados
    if (!document.querySelector('link[href*="chatbot.css"]')) {
      const link = document.createElement('link');
      link.rel = 'stylesheet';
      link.href = '/css/chatbot.css';
      document.head.appendChild(link);
    }
  }

  attachEvents() {
    const button = document.getElementById('chatbotButton');
    const window = document.getElementById('chatbotWindow');
    const close = document.getElementById('chatbotClose');
    const send = document.getElementById('chatbotSend');
    const input = document.getElementById('chatbotInput');
    const quickActions = document.getElementById('chatbotQuickActions');

    button.addEventListener('click', () => this.toggle());
    close.addEventListener('click', () => this.close());
    
    // Cerrar al hacer clic fuera (opcional, solo en mobile)
    if (window.innerWidth <= 480) {
      window.addEventListener('click', (e) => {
        if (e.target === window && this.isOpen) {
          this.close();
        }
      });
    }
    
    send.addEventListener('click', () => this.sendMessage());
    
    input.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        this.sendMessage();
      }
    });

    input.addEventListener('input', () => {
      // Auto-resize textarea
      input.style.height = 'auto';
      input.style.height = Math.min(input.scrollHeight, 120) + 'px';
      
      // Habilitar/deshabilitar botón de envío
      send.disabled = !input.value.trim() || this.isTyping;
    });

    // Quick actions
    quickActions.querySelectorAll('.chatbot-quick-action').forEach(btn => {
      btn.addEventListener('click', () => {
        const action = btn.dataset.action;
        this.handleQuickAction(action);
      });
    });

    // Inicializar estado del botón
    send.disabled = true;
  }

  toggle() {
    this.isOpen = !this.isOpen;
    const window = document.getElementById('chatbotWindow');
    const button = document.getElementById('chatbotButton');
    
    if (this.isOpen) {
      window.classList.add('open');
      document.getElementById('chatbotInput').focus();
      button.setAttribute('aria-expanded', 'true');
    } else {
      window.classList.remove('open');
      button.setAttribute('aria-expanded', 'false');
    }
  }

  close() {
    this.isOpen = false;
    const window = document.getElementById('chatbotWindow');
    const button = document.getElementById('chatbotButton');
    window.classList.remove('open');
    button.setAttribute('aria-expanded', 'false');
  }

  loadWelcomeMessage() {
    const messages = document.getElementById('chatbotMessages');
    this.addMessage('bot', '¡Hola! 👋 Soy tu asistente virtual de PanamaTravelHub. ¿En qué puedo ayudarte hoy? Puedo ayudarte a encontrar tours, responder preguntas sobre reservas, precios y más. ¡Estoy aquí para hacer tu experiencia más fácil! ✨');
  }

  addMessage(sender, text, isTyping = false) {
    const messages = document.getElementById('chatbotMessages');
    
    if (isTyping) {
      const typingDiv = document.createElement('div');
      typingDiv.className = 'chatbot-message bot';
      typingDiv.setAttribute('data-typing', 'true');
      typingDiv.innerHTML = `
        <div class="chatbot-message-avatar">🤖</div>
        <div class="chatbot-message-typing">
          <div class="chatbot-typing-dot"></div>
          <div class="chatbot-typing-dot"></div>
          <div class="chatbot-typing-dot"></div>
        </div>
      `;
      messages.appendChild(typingDiv);
      this.scrollToBottom();
      return typingDiv;
    }

    const messageDiv = document.createElement('div');
    messageDiv.className = `chatbot-message ${sender}`;
    messageDiv.innerHTML = `
      <div class="chatbot-message-avatar">${sender === 'bot' ? '🤖' : '👤'}</div>
      <div class="chatbot-message-content">${this.formatMessage(text)}</div>
    `;
    
    messages.appendChild(messageDiv);
    this.scrollToBottom();
    
    // Guardar en historial
    this.messageHistory.push({ sender, text, timestamp: Date.now() });
    
    return messageDiv;
  }

  formatMessage(text) {
    // Escapar HTML para seguridad
    const div = document.createElement('div');
    div.textContent = text;
    let safeText = div.innerHTML;
    
    // Convertir URLs a enlaces
    const urlRegex = /(https?:\/\/[^\s]+)/g;
    safeText = safeText.replace(urlRegex, '<a href="$1" target="_blank" rel="noopener noreferrer">$1</a>');
    
    // Convertir saltos de línea
    safeText = safeText.replace(/\n/g, '<br>');
    
    // Convertir emojis simples (ya están en el texto)
    return safeText;
  }

  scrollToBottom() {
    const messages = document.getElementById('chatbotMessages');
    // Usar requestAnimationFrame para suavizar el scroll
    requestAnimationFrame(() => {
      messages.scrollTo({
        top: messages.scrollHeight,
        behavior: 'smooth'
      });
    });
  }

  async sendMessage() {
    const input = document.getElementById('chatbotInput');
    const send = document.getElementById('chatbotSend');
    const message = input.value.trim();
    
    if (!message || this.isTyping) return;
    
    // Agregar mensaje del usuario
    this.addMessage('user', message);
    input.value = '';
    input.style.height = 'auto';
    send.disabled = true;
    
    // Mostrar typing indicator
    const typingIndicator = this.addMessage('bot', '', true);
    this.isTyping = true;
    send.disabled = true;
    
    try {
      // Obtener o generar sessionId
      if (!this.sessionId) {
        this.sessionId = this.generateSessionId();
      }
      
      // Enviar mensaje al backend
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: message,
          sessionId: this.sessionId
        })
      });

      // Remover typing indicator
      typingIndicator.remove();
      this.isTyping = false;
      send.disabled = false;

      if (!response.ok) {
        // Manejar errores HTTP
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.response || `Error ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      
      // Actualizar sessionId si viene en la respuesta
      if (data.sessionId) {
        this.sessionId = data.sessionId;
      }
      
      // Agregar respuesta del bot
      this.addMessage('bot', data.response || 'Lo siento, no pude procesar tu mensaje.');
      
    } catch (error) {
      console.error('Error al enviar mensaje:', error);
      
      // Remover typing indicator en caso de error
      typingIndicator.remove();
      this.isTyping = false;
      send.disabled = false;
      
      // Mostrar mensaje de error amigable
      this.addMessage('bot', 'Lo siento, hubo un problema al procesar tu mensaje. Por favor, intenta de nuevo en un momento. Si el problema persiste, contáctanos directamente.');
    }
  }

  generateSessionId() {
    return 'chat-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9);
  }


  async handleQuickAction(action) {
    const input = document.getElementById('chatbotInput');
    const send = document.getElementById('chatbotSend');
    
    // Deshabilitar acciones rápidas mientras se procesa
    const quickActions = document.getElementById('chatbotQuickActions');
    quickActions.querySelectorAll('.chatbot-quick-action').forEach(btn => {
      btn.disabled = true;
    });
    
    // Agregar mensaje del usuario
    const actionText = quickActions.querySelector(`[data-action="${action}"]`).textContent;
    this.addMessage('user', actionText);
    
    // Mostrar typing indicator
    const typingIndicator = this.addMessage('bot', '', true);
    this.isTyping = true;
    send.disabled = true;
    
    try {
      // Obtener o generar sessionId
      if (!this.sessionId) {
        this.sessionId = this.generateSessionId();
      }
      
      // Enviar mensaje al backend
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: actionText,
          sessionId: this.sessionId
        })
      });

      // Remover typing indicator
      typingIndicator.remove();
      this.isTyping = false;
      send.disabled = false;

      if (!response.ok) {
        throw new Error(`Error ${response.status}`);
      }

      const data = await response.json();
      
      // Actualizar sessionId si viene en la respuesta
      if (data.sessionId) {
        this.sessionId = data.sessionId;
      }
      
      // Agregar respuesta del bot
      this.addMessage('bot', data.response || this.demoResponses[action] || 'Gracias por tu interés. ¿Hay algo más en lo que pueda ayudarte?');
      
    } catch (error) {
      console.error('Error al procesar acción rápida:', error);
      
      // Remover typing indicator
      typingIndicator.remove();
      this.isTyping = false;
      send.disabled = false;
      
      // Usar respuesta de fallback
      const fallbackResponse = this.demoResponses[action] || 'Gracias por tu interés. ¿Hay algo más en lo que pueda ayudarte?';
      this.addMessage('bot', fallbackResponse);
    } finally {
      // Rehabilitar acciones rápidas
      quickActions.querySelectorAll('.chatbot-quick-action').forEach(btn => {
        btn.disabled = false;
      });
    }
  }
}

// Inicializar chatbot cuando el DOM esté listo
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    window.chatbot = new Chatbot();
  });
} else {
  window.chatbot = new Chatbot();
}
