# Script: Pasar workflow n8n a Claude para revisión
# Uso:
#   .\claude-review-workflow.ps1                    # imprime prompt + JSON (luego copia y pega en Claude)
#   .\claude-review-workflow.ps1 | Set-Clipboard     # copia todo al portapapeles para pegar en Claude
#   .\claude-review-workflow.ps1 -OutFile prompt.txt # guarda prompt + JSON en archivo

param(
    [string]$WorkflowPath = (Join-Path $PSScriptRoot "workflow-pt-bot-mentor.json"),
    [string]$OutFile = ""
)

$prompt = @"
Revisa este workflow de n8n para la versión **n8n 2.3.6**.

**Objetivo:** Validar que el JSON sea correcto para importar en n8n 2.3.6, que los nodos (Webhook, Code, Switch, HTTP Request, Respond to Webhook) usen los parámetros y typeVersion adecuados, y que las expresiones y el flujo de datos sean correctos.

**Tareas:**
1. Comprueba que cada nodo tenga parámetros válidos para n8n 2.3.x (nombres de parámetros, estructura de rules en Switch, etc.).
2. Verifica que el Code node use sintaxis válida de n8n (\$input.first().json, return con formato correcto).
3. Verifica que los HTTP Request envíen body JSON correctamente (contentType, jsonBody, specifyBody).
4. Verifica que Respond to Webhook use el campo que devuelve el API (response, no reply) y que la expresión sea correcta.
5. Si algo no es compatible con n8n 2.3.6 o puede fallar al importar/ejecutar, indícalo y sugiere la corrección exacta (fragmento JSON o texto a reemplazar).

Responde en español. Si todo está bien, dilo explícitamente. Si hay correcciones, dame los cambios concretos (patches o reemplazos).

---
WORKFLOW JSON (archivo: workflow-pt-bot-mentor.json):
---
"@

$json = Get-Content -Path $WorkflowPath -Raw -Encoding UTF8
$fullOutput = $prompt + "`n`n" + $json

if ($OutFile) {
    $fullOutput | Set-Content -Path $OutFile -Encoding UTF8 -NoNewline
    Write-Host "Prompt + workflow guardado en: $OutFile" -ForegroundColor Green
    Write-Host "Abre ese archivo y pega su contenido en Claude." -ForegroundColor Cyan
} else {
    Write-Host $fullOutput
}
