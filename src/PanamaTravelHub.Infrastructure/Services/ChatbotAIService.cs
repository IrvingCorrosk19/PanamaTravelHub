using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json.Serialization;

namespace PanamaTravelHub.Infrastructure.Services;

/// <summary>
/// Servicio de IA para el chatbot - FASE 3
/// Integración con OpenAI para respuestas conversacionales naturales
/// </summary>
public interface IChatbotAIService
{
    Task<string> GenerateResponseAsync(string userMessage, string sessionId, List<ChatMessage>? conversationHistory = null);
}

public class ChatbotAIService : IChatbotAIService
{
    private readonly HttpClient? _httpClient;
    private readonly ILogger<ChatbotAIService> _logger;
    private readonly string _apiKey;
    private readonly string _systemPrompt;
    private readonly string _model;
    private readonly int _maxTokens;
    private readonly float _temperature;

    public ChatbotAIService(ILogger<ChatbotAIService> logger, IConfiguration configuration, IHttpClientFactory httpClientFactory)
    {
        _logger = logger;
        
        // Obtener API Key de configuración
        _apiKey = configuration["OpenAI:ApiKey"] ?? "";
        _model = configuration["OpenAI:Model"] ?? "gpt-4o-mini";
        _maxTokens = int.Parse(configuration["OpenAI:MaxTokens"] ?? "300");
        _temperature = float.Parse(configuration["OpenAI:Temperature"] ?? "0.7");
        
        if (string.IsNullOrWhiteSpace(_apiKey) || _apiKey == "YOUR_OPENAI_API_KEY")
        {
            _logger.LogWarning("OpenAI API Key no configurada. El chatbot usará respuestas mock.");
            _httpClient = null;
        }
        else
        {
            _httpClient = httpClientFactory.CreateClient();
            _httpClient.BaseAddress = new Uri("https://api.openai.com/v1/");
            _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {_apiKey}");
        }

        // Prompt del sistema - Define el comportamiento del bot
        _systemPrompt = BuildSystemPrompt();
    }

    /// <summary>
    /// Construye el prompt del sistema para el bot turístico
    /// </summary>
    private string BuildSystemPrompt()
    {
        var prompt = new StringBuilder();
        
        prompt.AppendLine("Eres un asistente virtual amable y profesional de PanamaTravelHub, una plataforma de tours turísticos en Panamá.");
        prompt.AppendLine();
        prompt.AppendLine("TU PERSONALIDAD:");
        prompt.AppendLine("- Eres cálido, cercano y humano");
        prompt.AppendLine("- Hablas como un asesor turístico experimentado");
        prompt.AppendLine("- Eres entusiasta pero profesional");
        prompt.AppendLine("- Usas un tono conversacional, no robótico");
        prompt.AppendLine();
        prompt.AppendLine("TUS OBJETIVOS:");
        prompt.AppendLine("1. Ayudar a los usuarios a encontrar tours que se ajusten a sus intereses");
        prompt.AppendLine("2. Responder preguntas sobre precios, disponibilidad y características de los tours");
        prompt.AppendLine("3. Guiar a los usuarios hacia el proceso de reserva cuando muestren interés");
        prompt.AppendLine("4. Proporcionar información útil sobre Panamá y turismo");
        prompt.AppendLine();
        prompt.AppendLine("REGLAS IMPORTANTES:");
        prompt.AppendLine("- Responde siempre en español");
        prompt.AppendLine("- Sé breve y claro (máximo 3-4 párrafos)");
        prompt.AppendLine("- Haz preguntas cortas y relevantes para entender mejor las necesidades del usuario");
        prompt.AppendLine("- NO inventes información sobre tours, precios o fechas");
        prompt.AppendLine("- Si no sabes algo, admítelo y ofrece contactar con el equipo");
        prompt.AppendLine("- NO ofrezcas precios específicos a menos que tengas esa información en el contexto");
        prompt.AppendLine("- NO cierres ventas automáticamente, solo guía hacia la reserva");
        prompt.AppendLine("- Usa emojis con moderación (1-2 por respuesta máximo)");
        prompt.AppendLine("- Mantén el contexto de la conversación");
        prompt.AppendLine();
        prompt.AppendLine("CUANDO EL USUARIO PREGUNTE SOBRE:");
        prompt.AppendLine("- Tours: Pregunta sobre sus intereses (aventura, cultura, naturaleza, etc.)");
        prompt.AppendLine("- Precios: Menciona que varían según el tour y ofrece ayudar a encontrar opciones");
        prompt.AppendLine("- Reservas: Explica el proceso simple y ofrece guiar paso a paso");
        prompt.AppendLine("- Disponibilidad: Indica que depende de la fecha y ofrece ayudar a verificar");
        prompt.AppendLine();
        prompt.AppendLine("SI EL USUARIO MUESTRA INTERÉS EN RESERVAR:");
        prompt.AppendLine("- Confirma qué tour le interesa");
        prompt.AppendLine("- Pregunta sobre fecha preferida y número de personas");
        prompt.AppendLine("- Guía hacia la página de reserva sin ser insistente");
        prompt.AppendLine();
        prompt.AppendLine("FORMATO DE RESPUESTAS:");
        prompt.AppendLine("- Usa párrafos cortos");
        prompt.AppendLine("- Haz preguntas al final para mantener la conversación");
        prompt.AppendLine("- Sé natural, como si estuvieras hablando con un amigo");
        
        return prompt.ToString();
    }

    public async Task<string> GenerateResponseAsync(string userMessage, string sessionId, List<ChatMessage>? conversationHistory = null)
    {
        // Si no hay API Key configurada, retornar respuesta mock
        if (_httpClient == null || string.IsNullOrWhiteSpace(_apiKey))
        {
            _logger.LogWarning("OpenAI no configurado, usando respuesta mock para sesión {SessionId}", sessionId);
            return GenerateFallbackResponse(userMessage);
        }

        try
        {
            // Construir historial de mensajes para la API de OpenAI
            var messages = new List<object>();

            // Agregar prompt del sistema
            messages.Add(new { role = "system", content = _systemPrompt });

            // Agregar historial de conversación si existe
            if (conversationHistory != null && conversationHistory.Any())
            {
                foreach (var msg in conversationHistory.TakeLast(10)) // Últimos 10 mensajes para mantener contexto
                {
                    messages.Add(new { role = msg.Role, content = msg.Content });
                }
            }

            // Agregar mensaje actual del usuario
            messages.Add(new { role = "user", content = userMessage });

            // Construir request body
            var requestBody = new
            {
                model = _model,
                messages = messages,
                temperature = _temperature,
                max_tokens = _maxTokens
            };

            // Llamar a la API de OpenAI usando HttpClient
            var response = await _httpClient.PostAsJsonAsync("chat/completions", requestBody);
            
            if (!response.IsSuccessStatusCode)
            {
                var errorContent = await response.Content.ReadAsStringAsync();
                _logger.LogError("Error en API de OpenAI: {StatusCode} - {Error}", response.StatusCode, errorContent);
                return GenerateFallbackResponse(userMessage);
            }

            var responseContent = await response.Content.ReadFromJsonAsync<OpenAIResponse>();

            var assistantMessage = responseContent?.Choices?.FirstOrDefault()?.Message?.Content?.Trim() ?? "";

            if (string.IsNullOrWhiteSpace(assistantMessage))
            {
                _logger.LogWarning("Respuesta vacía de OpenAI para sesión {SessionId}", sessionId);
                return GenerateFallbackResponse(userMessage);
            }

            _logger.LogInformation("Respuesta generada exitosamente para sesión {SessionId}, longitud: {Length}", 
                sessionId, assistantMessage.Length);

            return assistantMessage;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al generar respuesta con IA para sesión {SessionId}", sessionId);
            return GenerateFallbackResponse(userMessage);
        }
    }

    /// <summary>
    /// Genera respuesta de fallback cuando la IA no está disponible
    /// </summary>
    private string GenerateFallbackResponse(string userMessage)
    {
        var messageLower = userMessage.ToLower();

        if (messageLower.Contains("hola") || messageLower.Contains("buenos") || messageLower.Contains("buenas"))
        {
            return "¡Hola! 👋 Me alegra saludarte. ¿En qué puedo ayudarte hoy? Puedo ayudarte a encontrar tours, responder preguntas sobre precios, reservas y más.";
        }

        if (messageLower.Contains("tour") || messageLower.Contains("disponible"))
        {
            return "¡Excelente! Tenemos una amplia variedad de tours disponibles en Panamá. ¿Te interesa algún tipo de tour en particular? Por ejemplo, aventura, cultura, naturaleza...";
        }

        if (messageLower.Contains("precio") || messageLower.Contains("costo"))
        {
            return "Los precios varían según el tour y la temporada. ¿Hay algún tour específico que te interese? Puedo ayudarte a encontrar opciones que se ajusten a tu presupuesto.";
        }

        if (messageLower.Contains("reservar") || messageLower.Contains("reserva"))
        {
            return "¡Reservar es muy fácil! ¿Ya tienes en mente algún tour? Si me dices cuál te interesa, puedo guiarte paso a paso en el proceso de reserva.";
        }

        return "Gracias por tu mensaje. Estoy aquí para ayudarte con información sobre nuestros tours, precios, reservas y más. ¿Hay algo específico en lo que pueda asistirte? 😊";
    }
}

/// <summary>
/// Modelo para historial de conversación
/// </summary>
public class ChatMessage
{
    public string Role { get; set; } = string.Empty; // "user" o "assistant"
    public string Content { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
}

/// <summary>
/// Modelos para deserializar respuesta de OpenAI
/// </summary>
internal class OpenAIResponse
{
    [JsonPropertyName("choices")]
    public List<OpenAIChoice>? Choices { get; set; }
}

internal class OpenAIChoice
{
    [JsonPropertyName("message")]
    public OpenAIMessage? Message { get; set; }
}

internal class OpenAIMessage
{
    [JsonPropertyName("content")]
    public string? Content { get; set; }
}
