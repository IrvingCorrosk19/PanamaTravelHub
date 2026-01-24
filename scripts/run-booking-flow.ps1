# Flujo de reserva de cupo - Ejecuta como un usuario real
# Uso: .\run-booking-flow.ps1
$ErrorActionPreference = 'Stop'
$baseUrl = 'http://localhost:5018'

function Invoke-Api {
    param([string]$Method, [string]$Uri, [object]$Body, [string]$Token)
    $parms = @{ Uri = $Uri; Method = $Method }
    if ($Body) { $parms['Body'] = ($Body | ConvertTo-Json -Depth 6 -Compress); $parms['ContentType'] = 'application/json' }
    if ($Token) { $parms['Headers'] = @{ Authorization = "Bearer $Token" } }
    Invoke-RestMethod @parms
}

Write-Host "=== Flujo de Reserva de Cupo ===" -ForegroundColor Cyan
Write-Host ""

# 1. Buscar tours (GET /api/tours o /api/tours/search)
Write-Host "1. Buscando tours..." -ForegroundColor Yellow
$tours = @()
$tourId = $null
try {
    $toursResp = Invoke-Api -Method Get -Uri "$baseUrl/api/tours"
    if ($toursResp) { $tours = @($toursResp) }
} catch { }
if ($tours.Count -eq 0) {
    try {
        $toursResp = Invoke-Api -Method Get -Uri "$baseUrl/api/tours/search?q=panama&page=1&pageSize=5"
        $tours = @($toursResp.tours)
        if (-not $tours) { $tours = @($toursResp.Tours) }
    } catch {
        Write-Host "   API de tours no disponible (500). Si falta available_languages en tours, ejecuta:" -ForegroundColor Gray
        Write-Host "   psql -h localhost -U postgres -d PanamaTravelHub -f database\fix_missing_tour_columns.sql" -ForegroundColor Gray
    }
}
foreach ($t in $tours) {
    $tid = $t.id; if (-not $tid) { $tid = $t.Id }
    if ($tid) { $tourId = $tid; break }
}
if (-not $tourId) {
    Write-Host "   Sin tours. Se hará solo login + cupón. Reserva omitida." -ForegroundColor Yellow
    $skipBooking = $true
} else {
    Write-Host "   Tour elegido: $tourId" -ForegroundColor Green
    $skipBooking = $false
}
Write-Host ""

# 2. Login
Write-Host "2. Iniciando sesión..." -ForegroundColor Yellow
$loginBody = @{ email = 'admin@panamatravelhub.com'; password = 'Admin123!' }
try {
    $loginResp = Invoke-Api -Method Post -Uri "$baseUrl/api/auth/login" -Body $loginBody
} catch {
    Write-Host "   ERROR: Login falló. Verifica credenciales (admin@panamatravelhub.com / Admin123!)" -ForegroundColor Red
    exit 1
}
$token = $loginResp.accessToken; if (-not $token) { $token = $loginResp.access_token }
if (-not $token) {
    Write-Host "   ERROR: No se obtuvo token de acceso." -ForegroundColor Red
    exit 1
}
Write-Host "   Sesión iniciada OK." -ForegroundColor Green
Write-Host ""

# 3. Validar cupón (opcional)
Write-Host "3. Validando cupón (opcional)..." -ForegroundColor Yellow
$couponCode = $null
try {
    $validateBody = @{ code = 'PRUEBA10'; purchaseAmount = 100; tourId = $tourId }
    $couponResp = Invoke-Api -Method Post -Uri "$baseUrl/api/coupons/validate" -Body $validateBody -Token $token
    if ($couponResp -and ($couponResp.isValid -eq $true)) {
        $couponCode = 'PRUEBA10'
        Write-Host "   Cupón PRUEBA10 válido." -ForegroundColor Green
    } else { Write-Host "   Sin cupón válido, continuamos sin descuento." -ForegroundColor Gray }
} catch {
    Write-Host "   Sin cupón válido, continuamos sin descuento." -ForegroundColor Gray
}
Write-Host ""

# 4. Crear reserva (si hay tour)
$bookingId = $null
if (-not $skipBooking) {
    Write-Host "4. Creando reserva..." -ForegroundColor Yellow
    $participants = @(
        @{ firstName = 'Usuario'; lastName = 'Prueba'; email = 'admin@panamatravelhub.com'; phone = $null; dateOfBirth = $null }
    )
    $bookingBody = @{
        tourId               = $tourId
        tourDateId           = $null
        numberOfParticipants = 1
        countryId            = $null
        participants         = $participants
        couponCode           = $couponCode
    }
    try {
        $booking = Invoke-Api -Method Post -Uri "$baseUrl/api/bookings" -Body $bookingBody -Token $token
        $bookingId = $booking.id; if (-not $bookingId) { $bookingId = $booking.bookingId }
        Write-Host "   Reserva creada: $bookingId" -ForegroundColor Green
    } catch {
        $ex = $_.Exception
        $msg = $ex.Message
        if ($ex.Response) {
            try {
                $reader = New-Object System.IO.StreamReader($ex.Response.GetResponseStream())
                $msg = $reader.ReadToEnd()
            } catch {}
        }
        Write-Host "   ERROR al crear reserva: $msg" -ForegroundColor Red
    }
} else {
    Write-Host "4. Creando reserva... omitido (sin tour)" -ForegroundColor Gray
}
Write-Host ""

# 5. Resumen
Write-Host "=== Flujo completado ===" -ForegroundColor Cyan
Write-Host "  Tour:     $(if ($tourId) { $tourId } else { 'n/a' })"
Write-Host "  Reserva:  $(if ($bookingId) { $bookingId } else { 'n/a' })"
Write-Host "  Cupón:    $(if ($couponCode) { $couponCode } else { 'ninguno' })"
Write-Host ""
if ($bookingId) {
    Write-Host "Ver reserva: $baseUrl/booking-success.html?bookingId=$bookingId" -ForegroundColor Cyan
    Write-Host "Mis reservas: $baseUrl/reservas.html" -ForegroundColor Cyan
} else {
    Write-Host "Mis reservas: $baseUrl/reservas.html" -ForegroundColor Cyan
}
