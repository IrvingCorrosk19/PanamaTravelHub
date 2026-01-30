# Workflow PT Bot Mentor — Importación manual

## Versión n8n

Workflow creado y revisado para **n8n 2.3.6** (campo `meta.n8nVersionTarget` en el JSON). Si importas en otra versión, n8n puede ofrecer migrar nodos; acepta para que funcione.

**Revisión (compatibilidad 2.3.6):**
- **Code (MENTOR_BRAIN_DECISION):** acceso seguro a `message` (evita error si falta; usa `item.message != null`).
- **HTTP Request (INTENT_ENGINE / MENTOR_AI):** añadido `contentType: "json"` para enviar `Content-Type: application/json`; body con `|| ''` por si faltan campos.
- **Respond to Webhook:** valores por defecto si faltan `response` o `sessionId` para evitar respuestas rotas.

## Archivo

- **`workflow-pt-bot-mentor.json`** — Workflow listo para importar en n8n.

## Cómo subirlo manualmente en n8n

1. Abre n8n: `http://164.68.99.83:8083`
2. Menú **⋯** (arriba a la derecha) → **Import from File**
3. Elige el archivo **`workflow-pt-bot-mentor.json`**
4. Revisa que los nodos se vean bien (Webhook → MENTOR_BRAIN_DECISION → Switch → INTENT_ENGINE / MENTOR_AI → Respond_to_Webhook)
5. **Activa** el workflow (toggle **Active** en ON)
6. Prueba con:

```powershell
Invoke-RestMethod -Method POST -Uri "http://164.68.99.83:8083/webhook/pt/bot" -ContentType "application/json" -Body '{"message":"¿Cuánto cuesta este tour?","sessionId":"test-001","page":"tour-detail"}'
```

## Si algo falla al importar

- **Versión de nodos:** n8n puede pedir “actualizar” nodos; acepta la migración.
- **Respond to Webhook:** Si la respuesta no llega, comprueba en el nodo que el cuerpo use `{{ $json.response }}` y `{{ $json.sessionId }}` (el API devuelve `response`, no `reply`).
- **HTTP Request:** Las URLs apuntan a `http://164.68.99.83:8082`. Si tu app está en otro host/puerto, edita los nodos INTENT_ENGINE y MENTOR_AI.

## Flujo resumido

| Nodo | Tipo | Función |
|------|------|--------|
| Webhook | Webhook | POST `/pt/bot` — recibe message, sessionId, page, tourId |
| MENTOR_BRAIN_DECISION | Code | Marca FAST o THINK según palabras clave |
| Switch | Switch | FAST → Rama A, THINK → Rama B |
| INTENT_ENGINE | HTTP Request | POST `/api/chatbot/message` (sin IA) |
| MENTOR_AI | HTTP Request | POST `/api/chat` (con IA) |
| Respond_to_Webhook | Respond to Webhook | Devuelve `reply` + `sessionId` al cliente |
