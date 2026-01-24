# Prueba Completa del Frontend - Captura TODOS los errores
$ErrorActionPreference = 'Continue'
$baseUrl = 'http://localhost:5018'
$testResults = @()
$errors = @()

function Test-Step {
    param([string]$StepName, [scriptblock]$TestScript)
    Write-Host "`n[$StepName]" -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor Gray
    try {
        $result = & $TestScript
        Write-Host "[OK] $StepName" -ForegroundColor Green
        $script:testResults += @{ Step = $StepName; Status = "OK"; Result = $result }
        return $result
    } catch {
        $errorMsg = $_.Exception.Message
        Write-Host "[ERROR] $StepName" -ForegroundColor Red
        Write-Host "   $errorMsg" -ForegroundColor Red
        $script:errors += @{ Step = $StepName; Error = $errorMsg; Exception = $_ }
        $script:testResults += @{ Step = $StepName; Status = "ERROR"; Error = $errorMsg }
        return $null
    }
}

function Invoke-Api {
    param([string]$Method, [string]$Uri, [object]$Body, [hashtable]$Headers)
    $params = @{ Uri = $Uri; Method = $Method; ErrorAction = 'Stop' }
    if ($Body) { 
        $params['Body'] = ($Body | ConvertTo-Json -Depth 6 -Compress)
        $params['ContentType'] = 'application/json'
    }
    if ($Headers) { $params['Headers'] = $Headers }
    return Invoke-RestMethod @params
}

Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  PRUEBA COMPLETA DEL FLUJO DE RESERVA - FRONTEND         ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ============================================
# PASO 1: HOMEPAGE
# ============================================
$homepageContent = Test-Step "1. Homepage Content" {
    Invoke-Api -Method "GET" -Uri "$baseUrl/api/tours/homepage-content"
}

# ============================================
# PASO 2: TOURS
# ============================================
$tours = Test-Step "2. Listar Tours" {
    Invoke-Api -Method "GET" -Uri "$baseUrl/api/tours"
}

$tourId = $null
if ($tours -and $tours.Count -gt 0) {
    $tourId = $tours[0].id
    if (-not $tourId) { $tourId = $tours[0].Id }
    Write-Host "   Tour encontrado: $tourId" -ForegroundColor Gray
}

if (-not $tourId) {
    $searchResult = Test-Step "2b. Buscar Tours" {
        $searchUri = "$baseUrl/api/tours/search?q=panama" + '&page=1' + '&pageSize=5'
        Invoke-Api -Method "GET" -Uri $searchUri
    }
    if ($searchResult) {
        if ($searchResult.tours -and $searchResult.tours.Count -gt 0) {
            $tourId = $searchResult.tours[0].id
        } elseif ($searchResult.Tours -and $searchResult.Tours.Count -gt 0) {
            $tourId = $searchResult.Tours[0].id
        }
    }
}

# ============================================
# PASO 3: DETALLE DE TOUR
# ============================================
$tourDetail = $null
$tourDates = $null
if ($tourId) {
    $tourDetail = Test-Step "3. Detalle del Tour" {
        Invoke-Api -Method "GET" -Uri "$baseUrl/api/tours/$tourId"
    }
    
    $tourDates = Test-Step "3b. Fechas del Tour" {
        Invoke-Api -Method "GET" -Uri "$baseUrl/api/tours/$tourId/dates"
    }
} else {
    Write-Host "⚠️  No se puede probar detalle de tour (no hay tourId)" -ForegroundColor Yellow
}

# ============================================
# PASO 4: AUTENTICACIÓN
# ============================================
$token = $null
$loginResp = Test-Step "4. Login" {
    $body = @{ email = 'admin@panamatravelhub.com'; password = 'Admin123!' }
    Invoke-Api -Method "POST" -Uri "$baseUrl/api/auth/login" -Body $body
}

if ($loginResp) {
    $token = $loginResp.accessToken
    if (-not $token) { $token = $loginResp.access_token }
    if ($token) {
        Write-Host "   Token obtenido: $($token.Substring(0, [Math]::Min(30, $token.Length)))..." -ForegroundColor Gray
    }
}

$currentUser = $null
if ($token) {
    $currentUser = Test-Step "4b. Usuario Actual" {
        Invoke-Api -Method "GET" -Uri "$baseUrl/api/auth/me" -Headers @{ Authorization = "Bearer $token" }
    }
}

# ============================================
# PASO 5: CUPONES
# ============================================
$coupons = $null
$couponValidation = $null
$couponCode = $null

if ($token) {
    $coupons = Test-Step "5. Listar Cupones" {
        Invoke-Api -Method "GET" -Uri "$baseUrl/api/coupons" -Headers @{ Authorization = "Bearer $token" }
    }
    
    if ($tourId) {
        $couponValidation = Test-Step "5b. Validar Cupón PRUEBA10" {
            $body = @{ code = 'PRUEBA10'; purchaseAmount = 100; tourId = $tourId }
            Invoke-Api -Method "POST" -Uri "$baseUrl/api/coupons/validate" -Body $body -Headers @{ Authorization = "Bearer $token" }
        }
        if ($couponValidation -and $couponValidation.isValid -eq $true) {
            $couponCode = 'PRUEBA10'
                        Write-Host "   Cupon PRUEBA10 es valido" -ForegroundColor Green
        }
    }
}

# ============================================
# PASO 6: PAÍSES
# ============================================
$countries = Test-Step "6. Listar Países" {
    Invoke-Api -Method "GET" -Uri "$baseUrl/api/tours/countries"
}

# ============================================
# PASO 7: CREAR RESERVA
# ============================================
$booking = $null
$bookingId = $null

if ($tourId -and $token) {
    $booking = Test-Step "7. Crear Reserva" {
        $participants = @(
            @{ firstName = 'Usuario'; lastName = 'Prueba'; email = 'admin@panamatravelhub.com'; phone = $null; dateOfBirth = $null }
        )
        $body = @{
            tourId               = $tourId
            tourDateId           = $null
            numberOfParticipants = 1
            countryId            = $null
            participants         = $participants
            couponCode           = $couponCode
        }
        Invoke-Api -Method "POST" -Uri "$baseUrl/api/bookings" -Body $body -Headers @{ Authorization = "Bearer $token" }
    }
    
    if ($booking) {
        $bookingId = $booking.id
        if (-not $bookingId) { $bookingId = $booking.bookingId }
        if ($bookingId) {
            Write-Host "   Reserva creada: $bookingId" -ForegroundColor Green
            
            $getBooking = Test-Step "7b. Obtener Reserva Creada" {
                Invoke-Api -Method "GET" -Uri "$baseUrl/api/bookings/$bookingId" -Headers @{ Authorization = "Bearer $token" }
            }
        }
    }
} else {
    Write-Host "⚠️  No se puede crear reserva (falta tourId o token)" -ForegroundColor Yellow
}

# ============================================
# PASO 8: MIS RESERVAS
# ============================================
$myBookings = $null
if ($token) {
    $myBookings = Test-Step "8. Mis Reservas" {
        Invoke-Api -Method "GET" -Uri "$baseUrl/api/bookings/my" -Headers @{ Authorization = "Bearer $token" }
    }
}

# ============================================
# RESUMEN FINAL
# ============================================
Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  RESUMEN DE PRUEBAS                                       ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$passed = ($testResults | Where-Object { $_.Status -eq "OK" }).Count
$failed = ($testResults | Where-Object { $_.Status -eq "ERROR" }).Count
$total = $testResults.Count

Write-Host "Total de pruebas: $total" -ForegroundColor White
Write-Host "[OK] Exitosas: $passed" -ForegroundColor Green
Write-Host "[ERROR] Fallidas: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Gray" })
Write-Host ""

if ($failed -gt 0) {
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "ERRORES ENCONTRADOS:" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Red
    $errors | ForEach-Object {
        Write-Host "`n[$($_.Step)]" -ForegroundColor Yellow
        Write-Host "Error: $($_.Error)" -ForegroundColor Red
        if ($_.Exception.Response) {
            try {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $responseBody = $reader.ReadToEnd()
                Write-Host "Respuesta: $responseBody" -ForegroundColor Gray
            } catch {}
        }
    }
    Write-Host ""
}

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "DETALLES DE LA PRUEBA:" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Tour ID: $(if ($tourId) { $tourId } else { 'No disponible' })" -ForegroundColor White
Write-Host "Token: $(if ($token) { 'Obtenido' } else { 'No disponible' })" -ForegroundColor White
Write-Host "Reserva ID: $(if ($bookingId) { $bookingId } else { 'No creada' })" -ForegroundColor White
Write-Host "Cupón: $(if ($couponCode) { $couponCode } else { 'No aplicado' })" -ForegroundColor White
Write-Host ""

if ($bookingId) {
    Write-Host "URLs:" -ForegroundColor Cyan
    Write-Host "   Ver reserva: $baseUrl/booking-success.html?bookingId=$bookingId" -ForegroundColor White
    Write-Host "   Mis reservas: $baseUrl/reservas.html" -ForegroundColor White
}

Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  FIN DE PRUEBAS                                          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Guardar resultados en archivo
$resultsFile = "test-results-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$testResults | ConvertTo-Json -Depth 5 | Out-File $resultsFile
Write-Host "`nResultados guardados en: $resultsFile" -ForegroundColor Gray
