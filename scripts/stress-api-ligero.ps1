# =============================================================================
# STRESS LIGERO API - PanamaTravelHub
# 50-100 requests en ventana de 30-60s. NO toca codigo de la app.
# Uso: .\stress-api-ligero.ps1 [-BaseUrl "http://localhost:5018"] [-DurationSec 30]
# =============================================================================
param(
    [string]$BaseUrl = 'http://localhost:5018',
    [int]$DurationSec = 30
)

$ErrorActionPreference = 'Continue'

function Get-TourId {
    try {
        $t = Invoke-RestMethod -Uri "$BaseUrl/api/tours" -Method GET -TimeoutSec 5 -ErrorAction Stop
        if ($t -and $t.Count -gt 0) { $id = $t[0].id; if (-not $id) { $id = $t[0].Id }; return $id }
    } catch {}
    try {
        $s = Invoke-RestMethod -Uri "$BaseUrl/api/tours/search?q=panama&page=1&pageSize=5" -Method GET -TimeoutSec 5 -ErrorAction Stop
        if ($s.tours -and $s.tours.Count -gt 0) { return $s.tours[0].id }; if ($s.Tours -and $s.Tours.Count -gt 0) { return $s.Tours[0].Id }
    } catch {}
    return $null
}

function Get-Token {
    $body = @{ email = 'cliente@panamatravelhub.com'; password = 'Cliente123!' } | ConvertTo-Json
    try {
        $r = Invoke-RestMethod -Method POST -Uri "$BaseUrl/api/auth/login" -Body $body -ContentType 'application/json' -TimeoutSec 5 -ErrorAction Stop
        $t = $r.accessToken; if (-not $t) { $t = $r.access_token }; return $t
    } catch {}
    return $null
}

Write-Host "=== Stress ligero API ===" -ForegroundColor Cyan
Write-Host "BaseUrl: $BaseUrl | Duracion: ${DurationSec}s" -ForegroundColor Gray
Write-Host ""

$tourId = Get-TourId
if (-not $tourId) { Write-Host "No se pudo obtener tourId (API puede estar caida)." -ForegroundColor Yellow }
$token = Get-Token
if (-not $token) { Write-Host "No se pudo obtener token (login fallido)." -ForegroundColor Yellow }
$authHeaders = @{ Authorization = "Bearer $token" }

$uris = @(
    @{ Uri = "$BaseUrl/api/tours"; Headers = $null; Kind = 1 },
    @{ Uri = "$BaseUrl/api/tours/$tourId"; Headers = $null; Kind = 2 },
    @{ Uri = "$BaseUrl/api/tours/$tourId/dates"; Headers = $null; Kind = 3 },
    @{ Uri = "$BaseUrl/api/bookings/my"; Headers = $authHeaders; Kind = 4 }
)

$script:results = [System.Collections.ArrayList]::new()
$end = [DateTime]::UtcNow.AddSeconds($DurationSec)
$sent = 0
while ([DateTime]::UtcNow -lt $end) {
    $u = $uris[$sent % $uris.Count]
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $status = 0
    try {
        $p = @{ Uri = $u.Uri; Method = 'GET'; TimeoutSec = 10; ErrorAction = 'Stop' }
        if ($u.Headers) { $p['Headers'] = $u.Headers }
        $null = Invoke-RestMethod @p
        $status = 200
    } catch {
        if ($_.Exception.Response) { $status = [int]$_.Exception.Response.StatusCode }
    }
    $sw.Stop()
    [void]$script:results.Add(@{ ms = $sw.ElapsedMilliseconds; status = $status; kind = $u.Kind })
    $sent++
}
$all = @($script:results)

$total = $all.Count
$ok = ($all | Where-Object { $_.status -eq 200 }).Count
$fivexx = ($all | Where-Object { $_.status -ge 500 }).Count
$timeouts = ($all | Where-Object { $_.status -eq 0 -or $_.ms -ge 10000 }).Count
$avgMs = 0; if ($total -gt 0) { $avgMs = [int](($all | ForEach-Object { $_.ms } | Measure-Object -Average).Average) }

Write-Host ""
Write-Host "--- Resultados ---" -ForegroundColor Cyan
Write-Host "  Requests enviados: $sent"
Write-Host "  Respuestas 200:    $ok"
Write-Host "  Errores 5xx:       $fivexx"
Write-Host "  Timeouts/fallos:   $timeouts"
Write-Host "  Tiempo medio:      ${avgMs} ms"

$result = "FAIL"
if ($total -eq 0) { $result = "FAIL" }
elseif ($fivexx -gt 0 -or $timeouts -gt [Math]::Max(1, $total * 0.1)) { $result = "FAIL" }
elseif ($fivexx -eq 0 -and $timeouts -eq 0 -and $avgMs -lt 5000) { $result = "OK" }
elseif ($avgMs -lt 5000 -and $timeouts -eq 0) { $result = "DEGRADED" }

Write-Host ""
Write-Host "Resultado general: $result" -ForegroundColor $(if ($result -eq 'OK') { 'Green' } elseif ($result -eq 'DEGRADED') { 'Yellow' } else { 'Red' })

$report = @{
    Endpoints = @('GET /api/tours', 'GET /api/tours/{id}', 'GET /api/tours/{id}/dates', 'GET /api/bookings/my')
    Load     = "~$sent requests en ${DurationSec}s"
    Result   = $result
    Total    = $sent
    Ok       = $ok
    Fivexx   = $fivexx
    Timeouts = $timeouts
    AvgMs    = $avgMs
}
$report | ConvertTo-Json | Set-Content -Path "stress-ligero-resultado.json" -Encoding UTF8
Write-Host "Detalle: stress-ligero-resultado.json" -ForegroundColor Gray
