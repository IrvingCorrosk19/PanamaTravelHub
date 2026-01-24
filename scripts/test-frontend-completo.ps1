# Prueba Completa del Frontend - Captura TODOS los errores
$ErrorActionPreference = 'Continue'
$baseUrl = 'http://localhost:5018'
$testResults = @()
$allErrors = @()

function Test-API {
    param([string]$Name, [string]$Method, [string]$Uri, [object]$Body, [hashtable]$Headers, [int[]]$AcceptStatuses = @())
    Write-Host "`n[$Name]" -ForegroundColor Yellow
    try {
        $params = @{ Uri = $Uri; Method = $Method; ErrorAction = 'Stop' }
        if ($Body) { 
            $params['Body'] = ($Body | ConvertTo-Json -Depth 6 -Compress)
            $params['ContentType'] = 'application/json'
        }
        if ($Headers) { $params['Headers'] = $Headers }
        $response = Invoke-RestMethod @params
        Write-Host "  [OK]" -ForegroundColor Green
        $script:testResults += @{ Test = $Name; Status = "OK" }
        return $response
    } catch {
        $statusCode = 0
        $errorMsg = $_.Exception.Message
        $responseBody = ""
        
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
            try {
                $stream = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($stream)
                $responseBody = $reader.ReadToEnd()
                $reader.Close()
                $stream.Close()
            } catch {}
        }
        
        if ($AcceptStatuses -and $statusCode -in $AcceptStatuses) {
            Write-Host "  [OK] $statusCode (acceso OK, cupon no existe)" -ForegroundColor Green
            $script:testResults += @{ Test = $Name; Status = "OK" }
            return $null
        }
        
        Write-Host "  [ERROR] $statusCode - $errorMsg" -ForegroundColor Red
        if ($responseBody) {
            Write-Host "  Respuesta: $responseBody" -ForegroundColor Gray
        }
        
        $script:allErrors += @{ 
            Test = $Name
            StatusCode = $statusCode
            Error = $errorMsg
            Response = $responseBody
        }
        $script:testResults += @{ Test = $Name; Status = "ERROR"; Code = $statusCode; Error = $errorMsg }
        return $null
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PRUEBA COMPLETA DEL FLUJO DE RESERVA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Base URL: $baseUrl`n" -ForegroundColor Gray

# 1. Homepage
$homepage = Test-API -Name "1. Homepage Content" -Method "GET" -Uri "$baseUrl/api/tours/homepage-content"

# 2. Tours
$tours = Test-API -Name "2. Listar Tours" -Method "GET" -Uri "$baseUrl/api/tours"
$tourId = $null
if ($tours -and $tours.Count -gt 0) {
    $tourId = $tours[0].id
    if (-not $tourId) { $tourId = $tours[0].Id }
    Write-Host "  Tour ID: $tourId" -ForegroundColor Gray
}

if (-not $tourId) {
    $searchUri = "$baseUrl/api/tours/search" + '?q=panama&page=1&pageSize=5'
    $searchResult = Test-API -Name "2b. Buscar Tours" -Method "GET" -Uri $searchUri
    if ($searchResult) {
        if ($searchResult.tours -and $searchResult.tours.Count -gt 0) {
            $tourId = $searchResult.tours[0].id
        } elseif ($searchResult.Tours -and $searchResult.Tours.Count -gt 0) {
            $tourId = $searchResult.Tours[0].id
        }
        if ($tourId) { Write-Host "  Tour ID encontrado: $tourId" -ForegroundColor Gray }
    }
}

# 3. Detalle Tour
$tourDetail = $null
$tourDates = $null
if ($tourId) {
    $tourDetail = Test-API -Name "3. Detalle Tour" -Method "GET" -Uri "$baseUrl/api/tours/$tourId"
    $tourDates = Test-API -Name "3b. Fechas Tour" -Method "GET" -Uri "$baseUrl/api/tours/$tourId/dates"
}

# 4. Login
$loginBody = @{ email = 'admin@panamatravelhub.com'; password = 'Admin123!' }
$loginResp = Test-API -Name "4. Login" -Method "POST" -Uri "$baseUrl/api/auth/login" -Body $loginBody
$token = $null
if ($loginResp) {
    $token = $loginResp.accessToken
    if (-not $token) { $token = $loginResp.access_token }
    if ($token) {
        Write-Host "  Token: $($token.Substring(0, [Math]::Min(30, $token.Length)))..." -ForegroundColor Gray
    }
}

# 5. Usuario Actual
$currentUser = $null
if ($token) {
    $currentUser = Test-API -Name "4b. Usuario Actual" -Method "GET" -Uri "$baseUrl/api/auth/me" -Headers @{ Authorization = "Bearer $token" }
}

# 6. Cupones
$coupons = $null
$couponValidation = $null
$couponCode = $null
if ($token) {
    $coupons = Test-API -Name "5. Listar Cupones" -Method "GET" -Uri "$baseUrl/api/coupons" -Headers @{ Authorization = "Bearer $token" }
    
    if ($tourId) {
        $validateBody = @{ code = 'PRUEBA10'; purchaseAmount = 100; tourId = $tourId }
        $couponValidation = Test-API -Name "5b. Validar Cupon" -Method "POST" -Uri "$baseUrl/api/coupons/validate" -Body $validateBody -Headers @{ Authorization = "Bearer $token" } -AcceptStatuses @(400)
        if ($couponValidation -and $couponValidation.isValid -eq $true) {
            $couponCode = 'PRUEBA10'
            Write-Host "  Cupon PRUEBA10 valido" -ForegroundColor Green
        }
    }
}

# 7. Paises
$countries = Test-API -Name "6. Listar Paises" -Method "GET" -Uri "$baseUrl/api/tours/countries"

# 8. Crear Reserva
$booking = $null
$bookingId = $null
if ($tourId -and $token) {
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
    $booking = Test-API -Name "7. Crear Reserva" -Method "POST" -Uri "$baseUrl/api/bookings" -Body $bookingBody -Headers @{ Authorization = "Bearer $token" }
    
    if ($booking) {
        $bookingId = $booking.id
        if (-not $bookingId) { $bookingId = $booking.bookingId }
        if ($bookingId) {
            Write-Host "  Reserva ID: $bookingId" -ForegroundColor Green
            $getBooking = Test-API -Name "7b. Obtener Reserva" -Method "GET" -Uri "$baseUrl/api/bookings/$bookingId" -Headers @{ Authorization = "Bearer $token" }
        }
    }
} else {
    Write-Host "`n[7. Crear Reserva] OMITIDO" -ForegroundColor Yellow
    Write-Host "  Razón: $(if (-not $tourId) { 'No hay tourId' } else { 'No hay token' })" -ForegroundColor Gray
}

# 9. Mis Reservas
$myBookings = $null
if ($token) {
    $myBookings = Test-API -Name "8. Mis Reservas" -Method "GET" -Uri "$baseUrl/api/bookings/my" -Headers @{ Authorization = "Bearer $token" }
}

# RESUMEN
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RESUMEN DE PRUEBAS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
$passed = ($testResults | Where-Object { $_.Status -eq "OK" }).Count
$failed = ($testResults | Where-Object { $_.Status -eq "ERROR" }).Count
$total = $testResults.Count

Write-Host "Total: $total | OK: $passed | ERROR: $failed" -ForegroundColor White
Write-Host ""

if ($allErrors.Count -gt 0) {
    Write-Host "ERRORES DETALLADOS:" -ForegroundColor Red
    Write-Host "----------------------------------------" -ForegroundColor Red
    foreach ($err in $allErrors) {
        Write-Host "`n[$($err.Test)]" -ForegroundColor Yellow
        Write-Host "  Status: $($err.StatusCode)" -ForegroundColor Red
        Write-Host "  Error: $($err.Error)" -ForegroundColor Red
        if ($err.Response) {
            Write-Host "  Respuesta: $($err.Response)" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

Write-Host "ESTADO FINAL:" -ForegroundColor Cyan
Write-Host "  Tour ID: $(if ($tourId) { $tourId } else { 'No disponible' })" -ForegroundColor White
Write-Host "  Token: $(if ($token) { 'Obtenido' } else { 'No disponible' })" -ForegroundColor White
Write-Host "  Reserva: $(if ($bookingId) { $bookingId } else { 'No creada' })" -ForegroundColor White
Write-Host "  Cupon: $(if ($couponCode) { $couponCode } else { 'No aplicado' })" -ForegroundColor White
Write-Host ""

if ($bookingId) {
    Write-Host "URLs:" -ForegroundColor Cyan
    Write-Host "  Reserva: $baseUrl/booking-success.html?bookingId=$bookingId" -ForegroundColor White
    Write-Host "  Mis Reservas: $baseUrl/reservas.html" -ForegroundColor White
}

# Guardar resultados
$resultsFile = "test-results-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$testResults | ConvertTo-Json -Depth 5 | Out-File $resultsFile -Encoding UTF8
Write-Host "`nResultados guardados en: $resultsFile" -ForegroundColor Gray
