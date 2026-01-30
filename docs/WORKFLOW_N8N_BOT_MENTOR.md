# Workflow n8n — Bot Mentor (PT)

Flujo: Webhook → Decisión humana (FAST/THINK) → Rama A (sin IA) o Rama B (IA) → Respond to Webhook.

---

## NODO 1 — Webhook (ENTRADA)

| | |
|---|---|
| **Tipo** | Webhook |
| **Método** | POST |
| **Path** | `/pt/bot` |

**URL final:** `http://164.68.99.83:8083/webhook/pt/bot`

**Body esperado:**
```json
{
  "message": "texto del usuario",
  "sessionId": "uuid-o-random",
  "page": "tour-detail",
  "tourId": "29ba9240-93ec-4c61-b0f5-a1bba83bd21b"
}
```

---

## NODO 2 — Function: MENTOR_BRAIN_DECISION

**Tipo:** Function  
**Nombre:** MENTOR_BRAIN_DECISION

```javascript
const msg = $json.message.toLowerCase();

const quickIntents = [
  'precio',
  'cuesta',
  'horario',
  'incluye',
  'duración',
  'cancelar',
  'cancelación',
  'niños',
  'edad',
  'dónde',
  'ubicación'
];

const isQuick = quickIntents.some(k => msg.includes(k));

return [{
  ...$json,
  intentType: isQuick ? 'FAST' : 'THINK'
}];
```

---

## NODO 3 — Switch

**Switch sobre:** `intentType`  
- **FAST** → Rama A (INTENT_ENGINE)  
- **THINK** → Rama B (MENTOR_AI)

---

## RAMA A — HTTP Request: INTENT_ENGINE

| | |
|---|---|
| **Método** | POST |
| **URL** | `http://164.68.99.83:8082/api/chatbot/message` |

**Body:**
```json
{
  "message": "{{ $json.message }}",
  "sessionId": "{{ $json.sessionId }}"
}
```

Respuesta del API: `{ "response": "...", "sessionId": "..." }`

---

## RAMA B — HTTP Request: MENTOR_AI

| | |
|---|---|
| **Método** | POST |
| **URL** | `http://164.68.99.83:8082/api/chat` |

**Body:**
```json
{
  "message": "{{ $json.message }}",
  "sessionId": "{{ $json.sessionId }}"
}
```

Respuesta del API: `{ "response": "...", "sessionId": "..." }`

---

## NODO FINAL — Respond to Webhook

El backend devuelve **`response`**, no `reply`. Usa esto:

```json
{
  "reply": "{{ $json.response }}",
  "sessionId": "{{ $json.sessionId }}"
}
```

Si en n8n el nodo HTTP Request devuelve el body en otro objeto (p.ej. bajo un key), ajusta la ruta: p.ej. `{{ $json.body.response }}` o el path que veas en la salida del nodo.

---

## Prueba desde PowerShell

```powershell
Invoke-RestMethod `
  -Method POST `
  -Uri "http://164.68.99.83:8083/webhook/pt/bot" `
  -ContentType "application/json" `
  -Body '{"message":"¿Cuánto cuesta este tour?","sessionId":"test-mentor-001","page":"tour-detail"}'
```

Si el workflow está activo y el webhook correcto, la respuesta incluirá `reply` y `sessionId`.

---

## Resumen URLs (mismo VPS)

| Quién | URL |
|-------|-----|
| Webhook n8n (entrada) | `http://164.68.99.83:8083/webhook/pt/bot` |
| API bot sin IA (Rama A) | `http://164.68.99.83:8082/api/chatbot/message` |
| API bot con IA (Rama B) | `http://164.68.99.83:8082/api/chat` |
