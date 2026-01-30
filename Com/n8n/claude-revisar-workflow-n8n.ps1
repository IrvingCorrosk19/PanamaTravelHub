# Revisar workflow n8n con Claude (arquitecto senior)
# Por defecto revisa: Com\n8n\workflow-pt-bot-mentor.json (este proyecto)
# Uso: .\claude-revisar-workflow-n8n.ps1
#      .\claude-revisar-workflow-n8n.ps1 -WorkflowDir "C:\Proyectos\n8n\workflows" -FileName "PT_BOT_MASTER_V1.json"

param(
    [string]$WorkflowDir = (Join-Path $PSScriptRoot ""),
    [string]$FileName = "workflow-pt-bot-mentor.json"
)

$prompt = @"
Eres un arquitecto senior en n8n y sistemas de bots conversacionales.

Objetivo:
Revisar el workflow JSON de n8n adjunto y validar que:
1) La estructura del workflow sea válida para n8n v2.3.6.
2) Los nodos estén correctamente conectados.
3) Los webhooks, métodos HTTP y paths sean coherentes.
4) No haya errores comunes (credenciales faltantes, expresiones inválidas, IDs rotos).
5) El flujo sea correcto para un bot conversacional (entrada → decisión → respuesta).

Instrucciones estrictas:
- NO refactorizar el workflow completo.
- NO proponer arquitecturas nuevas.
- SOLO:
  - señalar errores reales,
  - corregirlos si son necesarios,
  - y devolver el JSON corregido si hubo cambios.
- Si el workflow está correcto, indícalo explícitamente.

Archivo a revisar:
$FileName
(Ruta: $WorkflowDir\$FileName)
"@

$workflowPath = Join-Path $WorkflowDir $FileName
if (-not (Test-Path $workflowPath)) {
    Write-Host "No existe: $workflowPath" -ForegroundColor Red
    exit 1
}

Set-Location $WorkflowDir
# Claude CLI: prompt + archivo (si tu CLI no acepta archivo al final, quita $workflowPath)
& claude -p $prompt --allowedTools "Read,Edit" --permission-mode acceptEdits $workflowPath
