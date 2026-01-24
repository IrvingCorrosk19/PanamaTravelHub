// ============================================
// CHATBOT CON IA - Cliente Frontend
// ============================================

class Chatbot {
  constructor() {
    this.isOpen = false;
    this.sessionId = this.generateSessionId();
    this.messageHistory = [];
    this.isTyping = false;
    
    this.init();
  }

  generateSessionId() {
    return 'chatbot-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9);
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
          <button class="chatbot-close" id="chatbotClose">×</button>
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
          ></textarea>
          <button class="chatbot-send" id="chatbotSend" type="button">
            <svg viewBox="0 0 24 24">
              <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
            </svg>
          </button>
        </div>
      </div>
      <button class="chatbot-button" id="chatbotButton" type="button">
        <svg viewBox="0 0 24 24">
          <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z"/>
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
      input.style.height = Math.min(input.scrollHeight, 100) + 'px';
    });

    // Quick actions
    quickActions.querySelectorAll('.chatbot-quick-action').forEach(btn => {
      btn.addEventListener('click', () => {
        const action = btn.dataset.action;
        this.handleQuickAction(action);
      });
    });
  }

  toggle() {
    this.isOpen = !this.isOpen;
    const window = document.getElementById('chatbotWindow');
    if (this.isOpen) {
      window.classList.add('open');
      document.getElementById('chatbotInput').focus();
    } else {
      window.classList.remove('open');
    }
  }

  close() {
    this.isOpen = false;
    document.getElementById('chatbotWindow').classList.remove('open');
  }

  loadWelcomeMessage() {
    const messages = document.getElementById('chatbotMessages');
    this.addMessage('bot', '¡Hola! 👋 Soy tu asistente virtual de PanamaTravelHub. ¿En qué puedo ayudarte hoy? Puedo ayudarte a encontrar tours, responder preguntas sobre reservas, precios y más.');
  }

  addMessage(sender, text, isTyping = false) {
    const messages = document.getElementById('chatbotMessages');
    
    if (isTyping) {
      const typingDiv = document.createElement('div');
      typingDiv.className = 'chatbot-message bot';
      typingDiv.innerHTML = `
        <div class="chatbot-message-avatar">🤖</div>
        <div class="chatbot-message-typing">
          <div class="chatbot-typing-dot"></div>
          <div class="chatbot-typing-dot"></div>
          <div class="chatbot-typing-dot"></div>
        </div>
      `;
      messages.appendChild(typingDiv);
      messages.scrollTop = messages.scrollHeight;
      return typingDiv;
    }

    const messageDiv = document.createElement('div');
    messageDiv.className = `chatbot-message ${sender}`;
    messageDiv.innerHTML = `
      <div class="chatbot-message-avatar">${sender === 'bot' ? '🤖' : '👤'}</div>
      <div class="chatbot-message-content">${this.formatMessage(text)}</div>
    `;
    
    messages.appendChild(messageDiv);
    messages.scrollTop = messages.scrollHeight;
    
    return messageDiv;
  }

  formatMessage(text) {
    // Convertir URLs a enlaces
    const urlRegex = /(https?:\/\/[^\s]+)/g;
    text = text.replace(urlRegex, '<a href="$1" target="_blank" rel="noopener">$1</a>');
    
    // Convertir saltos de línea
    text = text.replace(/\n/g, '<br>');
    
    return text;
  }

  async sendMessage() {
    const input = document.getElementById('chatbotInput');
    const message = input.value.trim();
    
    if (!message || this.isTyping) return;
    
    // Agregar mensaje del usuario
    this.addMessage('user', message);
    input.value = '';
    input.style.height = 'auto';
    
    // Mostrar typing indicator
    const typingIndicator = this.addMessage('bot', '', true);
    this.isTyping = true;
    
    try {
      const response = await fetch('/api/chatbot/message', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: message,
          sessionId: this.sessionId,
          history: this.messageHistory.slice(-5) // Últimos 5 mensajes para contexto
        })
      });

      if (!response.ok) {
        throw new Error('Error en la respuesta del servidor');
      }

      const data = await response.json();
      
      // Remover typing indicator
      typingIndicator.remove();
      this.isTyping = false;
      
      // Agregar respuesta del bot
      this.addMessage('bot', data.response);
      
      // Guardar en historial
      this.messageHistory.push({ role: 'user', content: message });
      this.messageHistory.push({ role: 'assistant', content: data.response });
      
    } catch (error) {
      console.error('Error al enviar mensaje:', error);
      typingIndicator.remove();
      this.isTyping = false;
      this.addMessage('bot', 'Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo.');
    }
  }

  async handleQuickAction(action) {
    const actions = {
      'tours': '¿Qué tours tienen disponibles?',
      'pricing': '¿Cuáles son los precios y descuentos disponibles?',
      'booking': '¿Cómo puedo hacer una reserva?',
      'contact': '¿Cómo puedo contactar con soporte?'
    };

    const message = actions[action] || action;
    document.getElementById('chatbotInput').value = message;
    this.sendMessage();
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
