using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Infrastructure.Data;
using PanamaTravelHub.Infrastructure.Services;
using System.Text.RegularExpressions;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/chatbot")]
public class ChatbotController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<ChatbotController> _logger;
    private readonly IChatbotAIService _aiService;
    private readonly IChatbotConversationService _conversationService;

    public ChatbotController(
        ApplicationDbContext context, 
        ILogger<ChatbotController> logger,
        IChatbotAIService aiService,
        IChatbotConversationService conversationService)
    {
        _context = context;
        _logger = logger;
        _aiService = aiService;
        _conversationService = conversationService;
    }

    /// <summary>
    /// Endpoint simplificado para chat - FASE 3 (Integración con IA)
    /// </summary>
    [HttpPost("~/api/chat")]
    public async Task<ActionResult<ChatbotResponseDto>> Chat([FromBody] ChatRequestDto request)
    {
        try
        {
            // Validación básica
            if (string.IsNullOrWhiteSpace(request.Message))
            {
                return BadRequest(new ChatbotResponseDto
                {
                    Response = "Por favor, envía un mensaje válido.",
                    SessionId = request.SessionId ?? string.Empty
                });
            }

            // Validar sessionId
            if (string.IsNullOrWhiteSpace(request.SessionId))
            {
                return BadRequest(new ChatbotResponseDto
                {
                    Response = "SessionId es requerido para mantener el contexto de la conversación.",
                    SessionId = string.Empty
                });
            }

            _logger.LogInformation("Chat request recibido - SessionId: {SessionId}, Message: {Message}", 
                request.SessionId, request.Message);

            // Agregar mensaje del usuario al historial
            _conversationService.AddMessage(request.SessionId, "user", request.Message);

            // Obtener historial de conversación
            var conversationHistory = _conversationService.GetConversationHistory(request.SessionId);

            // Generar respuesta usando IA
            var response = await _aiService.GenerateResponseAsync(
                request.Message, 
                request.SessionId, 
                conversationHistory);

            // Agregar respuesta del bot al historial
            _conversationService.AddMessage(request.SessionId, "assistant", response);

            return Ok(new ChatbotResponseDto
            {
                Response = response,
                SessionId = request.SessionId
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error procesando mensaje del chat - SessionId: {SessionId}", request.SessionId);
            return StatusCode(500, new ChatbotResponseDto
            {
                Response = "Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo en un momento.",
                SessionId = request.SessionId ?? string.Empty
            });
        }
    }

    [HttpPost("message")]
    public async Task<ActionResult<ChatbotResponseDto>> ProcessMessage([FromBody] ChatbotRequestDto request)
    {
        try
        {
            var message = request.Message?.Trim().ToLower() ?? "";
            var response = await GenerateResponse(message, request.SessionId);

            return Ok(new ChatbotResponseDto
            {
                Response = response,
                SessionId = request.SessionId
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error procesando mensaje del chatbot");
            return Ok(new ChatbotResponseDto
            {
                Response = "Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo.",
                SessionId = request.SessionId
            });
        }
    }

    private async Task<string> GenerateResponse(string message, string sessionId)
    {
        // Detectar intención del usuario
        var intent = DetectIntent(message);

        switch (intent)
        {
            case Intent.Tours:
                return await GetToursResponse(message);
            
            case Intent.Pricing:
                return await GetPricingResponse(message);
            
            case Intent.Booking:
                return GetBookingResponse();
            
            case Intent.Contact:
                return GetContactResponse();
            
            case Intent.Greeting:
                return GetGreetingResponse();
            
            case Intent.Help:
                return GetHelpResponse();
            
            case Intent.Cancellation:
                return GetCancellationResponse();
            
            case Intent.Payment:
                return GetPaymentResponse();
            
            default:
                return GetDefaultResponse(message);
        }
    }

    private Intent DetectIntent(string message)
    {
        // Patrones para detectar intenciones
        if (Regex.IsMatch(message, @"\b(hola|hi|buenos|buenas|saludos|hey)\b", RegexOptions.IgnoreCase))
            return Intent.Greeting;

        if (Regex.IsMatch(message, @"\b(tour|tours|disponible|disponibles|ver|mostrar|listar|buscar|encontrar|recomendar)\b", RegexOptions.IgnoreCase))
            return Intent.Tours;

        if (Regex.IsMatch(message, @"\b(precio|precios|costo|costos|cuanto|cuánto|barato|económico|descuento|promoción|oferta)\b", RegexOptions.IgnoreCase))
            return Intent.Pricing;

        if (Regex.IsMatch(message, @"\b(reservar|reserva|booking|reservación|comprar|pagar|checkout)\b", RegexOptions.IgnoreCase))
            return Intent.Booking;

        if (Regex.IsMatch(message, @"\b(contacto|contactar|soporte|ayuda|hablar|llamar|email|correo|teléfono|telefono)\b", RegexOptions.IgnoreCase))
            return Intent.Contact;

        if (Regex.IsMatch(message, @"\b(ayuda|help|asistencia|información|info|qué|que|como|cómo)\b", RegexOptions.IgnoreCase))
            return Intent.Help;

        if (Regex.IsMatch(message, @"\b(cancelar|cancelación|reembolso|devolución|refund)\b", RegexOptions.IgnoreCase))
            return Intent.Cancellation;

        if (Regex.IsMatch(message, @"\b(pago|pagar|tarjeta|stripe|paypal|yappy|método|metodo)\b", RegexOptions.IgnoreCase))
            return Intent.Payment;

        return Intent.Unknown;
    }

    private async Task<string> GetToursResponse(string message)
    {
        try
        {
            // Buscar tours activos
            var tours = await _context.Tours
                .Where(t => t.IsActive)
                .Include(t => t.TourImages.Where(img => img.IsPrimary))
                .OrderBy(t => t.Name)
                .Take(5)
                .ToListAsync();

            if (!tours.Any())
            {
                return "Actualmente no tenemos tours disponibles. Por favor, contacta con nosotros para más información.";
            }

            var response = "¡Tenemos varios tours increíbles disponibles! 🎉\n\n";
            
            foreach (var tour in tours)
            {
                var price = tour.Price.ToString("C");
                var duration = tour.DurationHours > 0 ? $"{tour.DurationHours} horas" : "Duración variable";
                response += $"• **{tour.Name}** - {price} por persona ({duration})\n";
                if (!string.IsNullOrEmpty(tour.Description))
                {
                    var shortDesc = tour.Description.Length > 100 
                        ? tour.Description.Substring(0, 100) + "..." 
                        : tour.Description;
                    response += $"  {shortDesc}\n";
                }
                response += "\n";
            }

            response += "¿Te gustaría ver más detalles de algún tour en particular? Puedes buscarlo en nuestra página principal o preguntarme sobre precios, disponibilidad o cómo reservar.";

            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error obteniendo tours para chatbot");
            return "Puedo ayudarte a encontrar tours. Visita nuestra página principal para ver todas las opciones disponibles.";
        }
    }

    private async Task<string> GetPricingResponse(string message)
    {
        try
        {
            var tours = await _context.Tours
                .Where(t => t.IsActive)
                .OrderBy(t => t.Price)
                .ToListAsync();

            if (!tours.Any())
            {
                return "No tenemos información de precios disponible en este momento. Por favor, contacta con nosotros.";
            }

            var minPrice = tours.Min(t => t.Price);
            var maxPrice = tours.Max(t => t.Price);
            var avgPrice = tours.Average(t => t.Price);

            var response = $"💰 **Información de Precios:**\n\n";
            response += $"• Precio más económico: {minPrice:C}\n";
            response += $"• Precio más premium: {maxPrice:C}\n";
            response += $"• Precio promedio: {avgPrice:C}\n\n";

            // Buscar tours económicos
            var budgetTours = tours.Where(t => t.Price <= minPrice + 20).Take(3).ToList();
            if (budgetTours.Any())
            {
                response += "**Tours económicos:**\n";
                foreach (var tour in budgetTours)
                {
                    response += $"• {tour.Name} - {tour.Price:C}\n";
                }
                response += "\n";
            }

            response += "💡 **Consejo:** A veces tenemos descuentos y promociones especiales. ¿Te gustaría que te ayude a buscar un tour específico o tienes un presupuesto en mente?";

            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error obteniendo precios para chatbot");
            return "Los precios varían según el tour. Puedes ver todos los precios en nuestra página principal. ¿Hay algún tour específico que te interese?";
        }
    }

    private string GetBookingResponse()
    {
        return @"📅 **Cómo Reservar:**

1. **Explora los tours** - Navega por nuestra página y encuentra el tour que te gusta
2. **Selecciona fecha** - Elige la fecha que mejor te convenga
3. **Completa tus datos** - Ingresa la información de los participantes
4. **Elige método de pago** - Aceptamos Stripe, PayPal y Yappy
5. **Confirma tu reserva** - ¡Recibirás confirmación inmediata por email!

💡 **Tips:**
• Puedes reservar hasta 50 participantes por tour
• Cancelación flexible disponible
• Pago 100% seguro

¿Necesitas ayuda con algún paso específico del proceso de reserva?";
    }

    private string GetContactResponse()
    {
        return @"📞 **Información de Contacto:**

**Email:** info@panamatravelhub.com
**Horario de atención:** Lunes a Domingo, 8:00 AM - 8:00 PM (Hora de Panamá)

**¿Necesitas ayuda inmediata?**
• Revisa nuestras preguntas frecuentes
• Envíanos un email y te responderemos en menos de 24 horas
• También puedes contactarnos a través de nuestras redes sociales

¿Hay algo específico en lo que pueda ayudarte?";
    }

    private string GetGreetingResponse()
    {
        var greetings = new[]
        {
            "¡Hola! 👋 ¿En qué puedo ayudarte hoy?",
            "¡Bienvenido! 😊 Estoy aquí para ayudarte a encontrar el tour perfecto.",
            "Hola! 👋 ¿Buscas algún tour en particular o tienes alguna pregunta?",
            "¡Hola! 🎉 ¿Qué te gustaría saber sobre nuestros tours?"
        };
        
        return greetings[new Random().Next(greetings.Length)];
    }

    private string GetHelpResponse()
    {
        return @"🤖 **¿En qué puedo ayudarte?**

Puedo ayudarte con:
• 🎯 Buscar tours disponibles
• 💰 Información sobre precios y descuentos
• 📅 Cómo hacer una reserva
• ❓ Preguntas sobre cancelaciones
• 💳 Métodos de pago
• 📞 Información de contacto

Solo pregúntame lo que necesites. Por ejemplo:
• ""¿Qué tours tienen disponibles?""
• ""¿Cuánto cuesta un tour?""
• ""¿Cómo puedo reservar?""

¿Qué te gustaría saber?";
    }

    private string GetCancellationResponse()
    {
        return @"🔄 **Política de Cancelación:**

**Cancelación Flexible:**
• Puedes cancelar hasta 24 horas antes del tour
• Reembolso completo del 100%
• Sin cargos por cancelación

**Cómo cancelar:**
1. Ve a ""Mis Reservas"" en tu perfil
2. Selecciona la reserva que deseas cancelar
3. Haz clic en ""Cancelar Reserva""
4. Recibirás confirmación por email

**¿Necesitas cancelar una reserva?**
Si ya tienes una reserva, puedes cancelarla desde tu perfil. Si necesitas ayuda adicional, contáctanos.

¿Tienes alguna pregunta específica sobre cancelaciones?";
    }

    private string GetPaymentResponse()
    {
        return @"💳 **Métodos de Pago Aceptados:**

✅ **Stripe** - Tarjetas de crédito y débito (Visa, Mastercard, Amex)
✅ **PayPal** - Pago seguro con tu cuenta PayPal
✅ **Yappy** - Pago móvil en Panamá

**Seguridad:**
• Todos los pagos son 100% seguros
• No almacenamos información de tarjetas
• Procesamiento encriptado SSL

**¿Problemas con el pago?**
Si tienes problemas al realizar un pago, contacta con nuestro equipo de soporte. Estamos aquí para ayudarte.

¿Necesitas ayuda con algún método de pago específico?";
    }

    private string GetDefaultResponse(string message)
    {
        var defaultResponses = new[]
        {
            "Entiendo tu pregunta. ¿Podrías ser más específico? Por ejemplo, puedes preguntarme sobre tours, precios, reservas o contacto.",
            "No estoy seguro de entender completamente. ¿Te gustaría que te ayude a buscar tours, ver precios o explicarte cómo reservar?",
            "Puedo ayudarte con información sobre tours, precios, reservas y más. ¿Qué te gustaría saber específicamente?",
            "Hmm, no estoy seguro de cómo responder eso. ¿Podrías reformular tu pregunta? Puedo ayudarte con tours, precios, reservas o contacto."
        };

        return defaultResponses[new Random().Next(defaultResponses.Length)] + 
               "\n\n💡 **Tip:** Prueba preguntando:\n" +
               "• \"¿Qué tours tienen disponibles?\"\n" +
               "• \"¿Cuánto cuesta un tour?\"\n" +
               "• \"¿Cómo puedo reservar?\"";
    }

    /// <summary>
    /// Genera respuesta mock sin consultar BD (FASE 2)
    /// </summary>
    private async Task<string> GenerateMockResponse(string message, string sessionId)
    {
        // Simular delay de procesamiento
        await Task.Delay(500 + new Random().Next(500));

        var messageLower = message.Trim().ToLower();
        
        // Detectar intención simple
        if (Regex.IsMatch(messageLower, @"\b(hola|hi|buenos|buenas|saludos|hey)\b", RegexOptions.IgnoreCase))
        {
            var greetings = new[]
            {
                "¡Hola! 👋 Me alegra saludarte. ¿En qué puedo ayudarte hoy?",
                "¡Bienvenido! 😊 Estoy aquí para ayudarte a encontrar el tour perfecto.",
                "Hola! 👋 ¿Buscas algún tour en particular o tienes alguna pregunta?",
                "¡Hola! 🎉 ¿Qué te gustaría saber sobre nuestros tours?"
            };
            return greetings[new Random().Next(greetings.Length)];
        }

        if (Regex.IsMatch(messageLower, @"\b(tour|tours|disponible|disponibles|ver|mostrar|listar|buscar|encontrar|recomendar)\b", RegexOptions.IgnoreCase))
        {
            return "¡Excelente! Tenemos una amplia variedad de tours disponibles en Panamá. Puedes explorar tours de aventura, culturales, ecológicos y más. ¿Te gustaría que te recomiende alguno en particular? 🌴✨";
        }

        if (Regex.IsMatch(messageLower, @"\b(precio|precios|costo|costos|cuanto|cuánto|barato|económico|descuento|promoción|oferta)\b", RegexOptions.IgnoreCase))
        {
            return "Nuestros precios varían según el tipo de tour y la temporada. Ofrecemos descuentos especiales para grupos y reservas anticipadas. También tenemos cupones de descuento disponibles. ¿Quieres que te muestre las opciones? 💰";
        }

        if (Regex.IsMatch(messageLower, @"\b(reservar|reserva|booking|reservación|comprar|pagar|checkout)\b", RegexOptions.IgnoreCase))
        {
            return "¡Reservar es muy fácil! Solo necesitas: 1) Seleccionar el tour que te interesa, 2) Elegir la fecha, 3) Completar tus datos y 4) Realizar el pago. Todo el proceso toma menos de 5 minutos. ¿Necesitas ayuda con algún paso? 📅";
        }

        if (Regex.IsMatch(messageLower, @"\b(contacto|contactar|soporte|ayuda|hablar|llamar|email|correo|teléfono|telefono)\b", RegexOptions.IgnoreCase))
        {
            return "Puedes contactarnos por: 📧 Email: info@panamatravelhub.com 📱 Teléfono: +507 1234-5678 💬 Este chat (estamos aquí para ayudarte) También puedes visitarnos en nuestras oficinas. ¿En qué podemos ayudarte? 🤝";
        }

        if (Regex.IsMatch(messageLower, @"\b(gracias|muchas gracias|thank you|thanks)\b", RegexOptions.IgnoreCase))
        {
            return "¡De nada! 😊 Estoy aquí para ayudarte siempre que lo necesites. ¿Hay algo más en lo que pueda asistirte?";
        }

        // Respuesta genérica amigable
        return "Gracias por tu mensaje. Estoy aquí para ayudarte con información sobre nuestros tours, precios, reservas y más. ¿Hay algo específico en lo que pueda asistirte? 😊";
    }
}

// DTO simplificado para FASE 2
public class ChatRequestDto
{
    public string Message { get; set; } = string.Empty;
    public string SessionId { get; set; } = string.Empty;
}

// DTOs
public class ChatbotRequestDto
{
    public string Message { get; set; } = string.Empty;
    public string SessionId { get; set; } = string.Empty;
    public List<ChatbotMessageDto>? History { get; set; }
}

public class ChatbotMessageDto
{
    public string Role { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
}

public class ChatbotResponseDto
{
    public string Response { get; set; } = string.Empty;
    public string SessionId { get; set; } = string.Empty;
}

// Intenciones
public enum Intent
{
    Unknown,
    Greeting,
    Tours,
    Pricing,
    Booking,
    Contact,
    Help,
    Cancellation,
    Payment
}
