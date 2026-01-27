using System.Collections.Concurrent;
using Microsoft.Extensions.Logging;

namespace PanamaTravelHub.Infrastructure.Services;

/// <summary>
/// Servicio para gestionar el contexto de conversación del chatbot
/// FASE 3 - Almacenamiento en memoria (sin persistencia en BD todavía)
/// </summary>
public interface IChatbotConversationService
{
    List<ChatMessage> GetConversationHistory(string sessionId);
    void AddMessage(string sessionId, string role, string content);
    void ClearConversation(string sessionId);
}

public class ChatbotConversationService : IChatbotConversationService
{
    // Almacenamiento en memoria por sesión
    // En producción, esto debería persistirse en BD o Redis
    private readonly ConcurrentDictionary<string, List<ChatMessage>> _conversations = new();
    private readonly ILogger<ChatbotConversationService> _logger;

    public ChatbotConversationService(ILogger<ChatbotConversationService> logger)
    {
        _logger = logger;
    }

    public List<ChatMessage> GetConversationHistory(string sessionId)
    {
        if (string.IsNullOrWhiteSpace(sessionId))
            return new List<ChatMessage>();

        if (_conversations.TryGetValue(sessionId, out var history))
        {
            // Limpiar conversaciones muy antiguas (más de 1 hora)
            var cutoff = DateTime.UtcNow.AddHours(-1);
            history.RemoveAll(m => m.Timestamp < cutoff);
            
            return history;
        }

        return new List<ChatMessage>();
    }

    public void AddMessage(string sessionId, string role, string content)
    {
        if (string.IsNullOrWhiteSpace(sessionId))
            return;

        var message = new ChatMessage
        {
            Role = role,
            Content = content,
            Timestamp = DateTime.UtcNow
        };

        _conversations.AddOrUpdate(
            sessionId,
            new List<ChatMessage> { message },
            (key, existing) =>
            {
                existing.Add(message);
                // Limitar historial a 20 mensajes por sesión
                if (existing.Count > 20)
                {
                    existing.RemoveAt(0);
                }
                return existing;
            });

        _logger.LogDebug("Mensaje agregado a conversación {SessionId}, rol: {Role}, total mensajes: {Count}",
            sessionId, role, _conversations[sessionId].Count);
    }

    public void ClearConversation(string sessionId)
    {
        if (string.IsNullOrWhiteSpace(sessionId))
            return;

        _conversations.TryRemove(sessionId, out _);
        _logger.LogDebug("Conversación {SessionId} limpiada", sessionId);
    }
}
