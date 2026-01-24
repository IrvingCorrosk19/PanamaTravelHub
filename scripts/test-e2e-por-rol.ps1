# =============================================================================
# PRUEBAS E2E POR ROL - PanamaTravelHub
# Ejecuta flujo completo end-to-end para cada rol: Publico, Customer, Admin
# =============================================================================
$ErrorActionPreference = 'Continue'
$baseUrl = 'http://localhost:5018'
$script:results = @()
$script:errors = @()

function Test-API {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Uri,
        [object]$Body,
        [hashtable]$Headers,
        [int]$ExpectStatus = 0,
        [int[]]$AcceptStatuses = @()
    )
    Write-Host "  [$Name]" -ForegroundColor Yellow -NoNewline
    try {
        $params = @{ Uri = $Uri; Method = $Method; ErrorAction = 'Stop' }
        if ($Body) {
            $params['Body'] = ($Body | ConvertTo-Json -Depth 6 -Compress)
            $params['ContentType'] = 'application/json'
        }
        if ($Headers) { $params['Headers'] = $Headers }
        $response = Invoke-RestMethod @params
        $statusCode = 200
        if ($ExpectStatus -gt 0 -and $ExpectStatus -ne 200) {
            Write-Host " [ERROR] Esperaba $ExpectStatus, obtuvo 200" -ForegroundColor Red
            $script:results += @{ Rol = $script:currentRole; Test = $Name; Status = "FAIL"; Expect = $ExpectStatus; Got = 200 }
            $script:errors += @{ Rol = $script:currentRole; Test = $Name; Msg = "Debia fallar con $ExpectStatus" }
            return $null
        }
        Write-Host " [OK]" -ForegroundColor Green
        $script:results += @{ Rol = $script:currentRole; Test = $Name; Status = "OK" }
        return $response
    } catch {
        $statusCode = 0
        if ($_.Exception.Response) { $statusCode = $_.Exception.Response.StatusCode.value__ }
        $responseBody = ""
        try {
            if ($_.Exception.Response) {
                $stream = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($stream)
                $responseBody = $reader.ReadToEnd()
                $reader.Close(); $stream.Close()
            }
        } catch {}
        if ($ExpectStatus -gt 0 -and $ExpectStatus -eq $statusCode) {
            Write-Host " [OK] $statusCode esperado" -ForegroundColor Green
            $script:results += @{ Rol = $script:currentRole; Test = $Name; Status = "OK"; Expect = $ExpectStatus; Got = $statusCode }
            return $null
        }
        if ($AcceptStatuses -and $statusCode -in $AcceptStatuses) {
            Write-Host " [OK] $statusCode (acceso OK)" -ForegroundColor Green
            $script:results += @{ Rol = $script:currentRole; Test = $Name; Status = "OK"; Got = $statusCode }
            return $null
        }
        Write-Host " [ERROR] $statusCode" -ForegroundColor Red
        $script:results += @{ Rol = $script:currentRole; Test = $Name; Status = "ERROR"; Code = $statusCode; Error = $_.Exception.Message }
        $script:errors += @{ Rol = $script:currentRole; Test = $Name; Code = $statusCode; Msg = $_.Exception.Message; Response = $responseBody }
        return $null
    }
}

function Get-TourId {
    $t = Invoke-RestMethod -Uri "$baseUrl/api/tours" -Method GET -ErrorAction SilentlyContinue
    if ($t -and $t.Count -gt 0) {
        $id = $t[0].id; if (-not $id) { $id = $t[0].Id }; return $id
    }
    $s = Invoke-RestMethod -Uri "$baseUrl/api/tours/search" + '?q=panama&page=1&pageSize=5' -Method GET -ErrorAction SilentlyContinue
    if ($s) {
        if ($s.tours -and $s.tours.Count -gt 0) { return $s.tours[0].id }
        if ($s.Tours -and $s.Tours.Count -gt 0) { return $s.Tours[0].id }
    }
    return $null
}

# ---------- PUBLICO (sin login) ----------
$script:currentRole = "Publico"
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "E2E ROL: PUBLICO (sin autenticacion)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$null = Test-API -Name "Homepage" -Method GET -Uri "$baseUrl/api/tours/homepage-content"
$null = Test-API -Name "Listar Tours" -Method GET -Uri "$baseUrl/api/tours"
$null = Test-API -Name "Buscar Tours" -Method GET -Uri ($baseUrl + '/api/tours/search?q=panama&page=1&pageSize=5')
$tourId = Get-TourId
if ($tourId) {
    $null = Test-API -Name "Detalle Tour" -Method GET -Uri "$baseUrl/api/tours/$tourId"
    $null = Test-API -Name "Fechas Tour" -Method GET -Uri "$baseUrl/api/tours/$tourId/dates"
}
$null = Test-API -Name "Paises" -Method GET -Uri "$baseUrl/api/tours/countries"

# ---------- CUSTOMER ----------
$script:currentRole = "Customer"
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "E2E ROL: CUSTOMER (cliente@panamatravelhub.com)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$custCredentials = @(
    @{ email = 'cliente@panamatravelhub.com'; password = 'Cliente123!' },
    @{ email = 'cliente@panamatravelhub.com'; password = 'Test123!' },
    @{ email = 'test1@panamatravelhub.com'; password = 'Test123!' }
)
$custLogin = $null
foreach ($c in $custCredentials) {
    try {
        $custLogin = Invoke-RestMethod -Method POST -Uri "$baseUrl/api/auth/login" -Body ($c | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop
        break
    } catch { }
}
$custToken = $null
if ($custLogin) {
    $custToken = $custLogin.accessToken; if (-not $custToken) { $custToken = $custLogin.access_token }
}
$custHeaders = @{ Authorization = "Bearer $custToken" }

if (-not $custToken) {
    Write-Host "  [Login Customer] [ERROR] No se pudo iniciar sesion. Probar: cliente@ / Cliente123! o test1@ / Test123!" -ForegroundColor Red
    $script:results += @{ Rol = $script:currentRole; Test = "Login"; Status = "ERROR" }
    $script:errors += @{ Rol = $script:currentRole; Test = "Login"; Msg = "Login fallido (401). Verificar password en BD." }
} else {
    Write-Host "  [Login Customer] [OK]" -ForegroundColor Green
    $script:results += @{ Rol = $script:currentRole; Test = "Login"; Status = "OK" }

    $null = Test-API -Name "Auth Me" -Method GET -Uri "$baseUrl/api/auth/me" -Headers $custHeaders
    $validateBody = @{ code = 'FAKE'; purchaseAmount = 100 }
    if ($tourId) { $validateBody['tourId'] = $tourId }
    $null = Test-API -Name "Validar Cupon (acceso)" -Method POST -Uri "$baseUrl/api/coupons/validate" -Body $validateBody -Headers $custHeaders -AcceptStatuses @(400)
    $null = Test-API -Name "Mis Reservas" -Method GET -Uri "$baseUrl/api/bookings/my" -Headers $custHeaders

    if ($tourId) {
        $participants = @( @{ firstName = 'Cliente'; lastName = 'E2E'; email = 'cliente@panamatravelhub.com'; phone = $null; dateOfBirth = $null } )
        $bookingBody = @{ tourId = $tourId; tourDateId = $null; numberOfParticipants = 1; countryId = $null; participants = $participants; couponCode = $null }
        $bk = Test-API -Name "Crear Reserva" -Method POST -Uri "$baseUrl/api/bookings" -Body $bookingBody -Headers $custHeaders
        $bid = $null
        if ($bk) { $bid = $bk.id; if (-not $bid) { $bid = $bk.bookingId } }
        if ($bid) { $null = Test-API -Name "Obtener Reserva" -Method GET -Uri "$baseUrl/api/bookings/$bid" -Headers $custHeaders }
    }

    $null = Test-API -Name "Admin Tours (debe 403)" -Method GET -Uri "$baseUrl/api/admin/tours" -Headers $custHeaders -ExpectStatus 403
    $null = Test-API -Name "Admin Bookings (debe 403)" -Method GET -Uri "$baseUrl/api/admin/bookings" -Headers $custHeaders -ExpectStatus 403
    $null = Test-API -Name "Admin Stats (debe 403)" -Method GET -Uri "$baseUrl/api/admin/stats" -Headers $custHeaders -ExpectStatus 403
    $null = Test-API -Name "Admin Homepage (debe 403)" -Method GET -Uri "$baseUrl/api/admin/homepage-content" -Headers $custHeaders -ExpectStatus 403
}

# ---------- ADMIN ----------
$script:currentRole = "Admin"
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "E2E ROL: ADMIN (admin@panamatravelhub.com)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$adminBody = @{ email = 'admin@panamatravelhub.com'; password = 'Admin123!' }
$adminLogin = $null
try {
    $adminLogin = Invoke-RestMethod -Method POST -Uri "$baseUrl/api/auth/login" -Body ($adminBody | ConvertTo-Json) -ContentType 'application/json'
} catch { }
$adminToken = $null
if ($adminLogin) {
    $adminToken = $adminLogin.accessToken; if (-not $adminToken) { $adminToken = $adminLogin.access_token }
}
$adminHeaders = @{ Authorization = "Bearer $adminToken" }

if (-not $adminToken) {
    Write-Host "  [Login Admin] [ERROR] No se pudo iniciar sesion como Admin." -ForegroundColor Red
    $script:results += @{ Rol = $script:currentRole; Test = "Login"; Status = "ERROR" }
    $script:errors += @{ Rol = $script:currentRole; Test = "Login"; Msg = "Login fallido" }
} else {
    Write-Host "  [Login Admin] [OK]" -ForegroundColor Green
    $script:results += @{ Rol = $script:currentRole; Test = "Login"; Status = "OK" }

    $null = Test-API -Name "Auth Me" -Method GET -Uri "$baseUrl/api/auth/me" -Headers $adminHeaders
    $null = Test-API -Name "Cupones" -Method GET -Uri "$baseUrl/api/coupons" -Headers $adminHeaders
    $null = Test-API -Name "Mis Reservas" -Method GET -Uri "$baseUrl/api/bookings/my" -Headers $adminHeaders

    $null = Test-API -Name "Admin Tours" -Method GET -Uri "$baseUrl/api/admin/tours" -Headers $adminHeaders
    $null = Test-API -Name "Admin Bookings" -Method GET -Uri "$baseUrl/api/admin/bookings" -Headers $adminHeaders
    $null = Test-API -Name "Admin Stats" -Method GET -Uri "$baseUrl/api/admin/stats" -Headers $adminHeaders
    $null = Test-API -Name "Admin Homepage Content" -Method GET -Uri "$baseUrl/api/admin/homepage-content" -Headers $adminHeaders
    $null = Test-API -Name "Admin Media" -Method GET -Uri "$baseUrl/api/admin/media" -Headers $adminHeaders
    $null = Test-API -Name "Admin Pages" -Method GET -Uri "$baseUrl/api/admin/pages" -Headers $adminHeaders
    $null = Test-API -Name "Admin Users" -Method GET -Uri "$baseUrl/api/admin/users" -Headers $adminHeaders
    $null = Test-API -Name "Admin Roles" -Method GET -Uri "$baseUrl/api/admin/roles" -Headers $adminHeaders

    if ($tourId) {
        $participants = @( @{ firstName = 'Admin'; lastName = 'E2E'; email = 'admin@panamatravelhub.com'; phone = $null; dateOfBirth = $null } )
        $bookingBody = @{ tourId = $tourId; tourDateId = $null; numberOfParticipants = 1; countryId = $null; participants = $participants; couponCode = $null }
        $bk = Test-API -Name "Crear Reserva" -Method POST -Uri "$baseUrl/api/bookings" -Body $bookingBody -Headers $adminHeaders
        $bid = $null
        if ($bk) { $bid = $bk.id; if (-not $bid) { $bid = $bk.bookingId } }
        if ($bid) { $null = Test-API -Name "Obtener Reserva" -Method GET -Uri "$baseUrl/api/bookings/$bid" -Headers $adminHeaders }
    }
}

# ---------- RESUMEN ----------
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RESUMEN E2E POR ROL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

foreach ($rol in @('Publico','Customer','Admin')) {
    $g = $script:results | Where-Object { $_.Rol -eq $rol }
    if ($g) {
        $ok = ($g | Where-Object { $_.Status -eq "OK" }).Count
        $fail = ($g | Where-Object { $_.Status -eq "FAIL" }).Count
        $err = ($g | Where-Object { $_.Status -eq "ERROR" }).Count
        $total = @($g).Count
        $color = if ($err -gt 0 -or $fail -gt 0) { "Red" } else { "Green" }
        Write-Host "  $rol : $ok OK, $fail FAIL, $err ERROR (total $total)" -ForegroundColor $color
    }
}

$totalOk = ($script:results | Where-Object { $_.Status -eq "OK" }).Count
$totalErr = ($script:results | Where-Object { $_.Status -eq "ERROR" }).Count
$totalFail = ($script:results | Where-Object { $_.Status -eq "FAIL" }).Count
$totalAll = $script:results.Count
Write-Host "`n  GLOBAL: $totalOk OK | $totalFail FAIL | $totalErr ERROR | $totalAll pruebas" -ForegroundColor White

if ($script:errors.Count -gt 0) {
    Write-Host "`nERRORES DETALLADOS:" -ForegroundColor Red
    foreach ($e in $script:errors) {
        Write-Host "  [$($e.Rol)] $($e.Test): $($e.Msg)" -ForegroundColor Gray
        if ($e.Code) { Write-Host "    HTTP $($e.Code)" -ForegroundColor Gray }
    }
}

$outFile = "test-e2e-rol-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$script:results | ConvertTo-Json -Depth 5 | Out-File $outFile -Encoding UTF8
Write-Host "`nResultados: $outFile" -ForegroundColor Gray
