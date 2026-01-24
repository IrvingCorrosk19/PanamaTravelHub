# Prueba Completa del Flujo de Reserva desde el Frontend
$ErrorActionPreference = 'Continue'
$baseUrl = 'http://localhost:5018'
$results = @()

function Test-Endpoint {
    param([string]$Name, [string]$Method, [string]$Uri, [object]$Body, [string]$Token)
    Write-Host "`n[$Name] Probando $Method $Uri..." -ForegroundColor Yellow
    try {
        $params = @{ Uri = $Uri; Method = $Method }
        if ($Body) { 
            $params['Body'] = ($Body | ConvertTo-Json -Depth 6 -Compress)
            $params['ContentType'] = 'application/json'
        }
        if ($Token) { $params['Headers'] = @{ Authorization = "Bearer $Token" } }
        $response = Invoke-RestMethod @params -ErrorAction Stop
        Write-Host "  OK" -ForegroundColor Green
        $script:results += @{ Test = $Name; Status = "OK" }
        return $response
    } catch {
        $statusCode = 0
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
        }
        $errorMsg = $_.Exception.Message
        Write-Host "  ERROR: $statusCode - $errorMsg" -ForegroundColor Red
        $script:results += @{ Test = $Name; Status = "ERROR"; Code = $statusCode; Error = $errorMsg }
        return $null
    }
}

Write-Host "=== PRUEBA COMPLETA DEL FLUJO DE RESERVA ===" -ForegroundColor Cyan
Write-Host "Base URL: $baseUrl`n" -ForegroundColor Gray

# 1. Homepage Content
Write-Host "1. VERIFICANDO HOMEPAGE" -ForegroundColor Cyan
$homepageContent = Test-Endpoint -Name "Homepage Content" -Method "GET" -Uri "$baseUrl/api/tours/homepage-content"

# 2. Listar Tours
Write-Host "`n2. VERIFICANDO TOURS" -ForegroundColor Cyan
$tours = Test-Endpoint -Name "Listar Tours" -Method "GET" -Uri "$baseUrl/api/tours"
$tourId = $null
if ($tours -and $tours.Count -gt 0) {
    $tourId = $tours[0].id
    if (-not $tourId) { $tourId = $tours[0].Id }
    Write-Host "  Tour encontrado: $tourId" -ForegroundColor Gray
}

# 3. Buscar Tours
if (-not $tourId) {
    $searchResult = Test-Endpoint -Name "Buscar Tours" -Method "GET" -Uri "$baseUrl/api/tours/search?q=panama&page=1&pageSize=5"
    if ($searchResult -and $searchResult.tours -and $searchResult.tours.Count -gt 0) {
        $tourId = $searchResult.tours[0].id
    } elseif ($searchResult -and $searchResult.Tours -and $searchResult.Tours.Count -gt 0) {
        $tourId = $searchResult.Tours[0].id
    }
}

# 4. Detalle de Tour
if ($tourId) {
    Write-Host "`n3. VERIFICANDO DETALLE DE TOUR" -ForegroundColor Cyan
    $tourDetail = Test-Endpoint -Name "Detalle Tour" -Method "GET" -Uri "$baseUrl/api/tours/$tourId"
    $tourDates = Test-Endpoint -Name "Fechas del Tour" -Method "GET" -Uri "$baseUrl/api/tours/$tourId/dates"
}

# 5. Autenticacion
Write-Host "`n4. VERIFICANDO AUTENTICACION" -ForegroundColor Cyan
$loginBody = @{ email = 'admin@panamatravelhub.com'; password = 'Admin123!' }
$loginResp = Test-Endpoint -Name "Login" -Method "POST" -Uri "$baseUrl/api/auth/login" -Body $loginBody
$token = $null
if ($loginResp) {
    $token = $loginResp.accessToken
    if (-not $token) { $token = $loginResp.access_token }
    if ($token) {
        Write-Host "  Token obtenido" -ForegroundColor Gray
    }
}

# 6. Usuario Actual
if ($token) {
    $currentUser = Test-Endpoint -Name "Usuario Actual" -Method "GET" -Uri "$baseUrl/api/auth/me" -Token $token
}

# 7. Cupones
if ($token) {
    Write-Host "`n5. VERIFICANDO CUPONES" -ForegroundColor Cyan
    $coupons = Test-Endpoint -Name "Listar Cupones" -Method "GET" -Uri "$baseUrl/api/coupons" -Token $token
    if ($tourId) {
        $validateBody = @{ code = 'PRUEBA10'; purchaseAmount = 100; tourId = $tourId }
        $couponValidation = Test-Endpoint -Name "Validar Cupon" -Method "POST" -Uri "$baseUrl/api/coupons/validate" -Body $validateBody -Token $token
    }
}

# 8. Paises
Write-Host "`n6. VERIFICANDO PAISES" -ForegroundColor Cyan
$countries = Test-Endpoint -Name "Listar Paises" -Method "GET" -Uri "$baseUrl/api/tours/countries"

# 9. Crear Reserva
if ($tourId -and $token) {
    Write-Host "`n7. VERIFICANDO CREACION DE RESERVA" -ForegroundColor Cyan
    $participants = @(
        @{ firstName = 'Usuario'; lastName = 'Prueba'; email = 'admin@panamatravelhub.com'; phone = $null; dateOfBirth = $null }
    )
    $bookingBody = @{
        tourId               = $tourId
        tourDateId           = $null
        numberOfParticipants = 1
        countryId            = $null
        participants         = $participants
        couponCode           = $null
    }
    $booking = Test-Endpoint -Name "Crear Reserva" -Method "POST" -Uri "$baseUrl/api/bookings" -Body $bookingBody -Token $token
    if ($booking) {
        $bookingId = $booking.id
        if (-not $bookingId) { $bookingId = $booking.bookingId }
        if ($bookingId) {
            $getBooking = Test-Endpoint -Name "Obtener Reserva" -Method "GET" -Uri "$baseUrl/api/bookings/$bookingId" -Token $token
        }
    }
}

# 10. Mis Reservas
if ($token) {
    Write-Host "`n8. VERIFICANDO MIS RESERVAS" -ForegroundColor Cyan
    $myBookings = Test-Endpoint -Name "Mis Reservas" -Method "GET" -Uri "$baseUrl/api/bookings/my" -Token $token
}

# Resumen
Write-Host "`n=== RESUMEN DE PRUEBAS ===" -ForegroundColor Cyan
$passed = ($results | Where-Object { $_.Status -eq "OK" }).Count
$failed = ($results | Where-Object { $_.Status -eq "ERROR" }).Count
$total = $results.Count

Write-Host "Total de pruebas: $total" -ForegroundColor White
Write-Host "Exitosas: $passed" -ForegroundColor Green
Write-Host "Fallidas: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Gray" })

if ($failed -gt 0) {
    Write-Host "`nPruebas fallidas:" -ForegroundColor Yellow
    $results | Where-Object { $_.Status -eq "ERROR" } | ForEach-Object {
        Write-Host "  - $($_.Test): $($_.Error)" -ForegroundColor Red
    }
}

Write-Host "`n=== FIN DE PRUEBAS ===" -ForegroundColor Cyan
