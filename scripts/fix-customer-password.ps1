# Reset password de cliente@panamatravelhub.com a Cliente123!
$ErrorActionPreference = 'Stop'
$connStr = "Host=localhost;Port=5432;Database=PanamaTravelHub;Username=postgres;Password=Panama2020`$"

$tempDir = Join-Path $env:TEMP "fix_pwd_$(Get-Date -Format 'yyyyMMddHHmmss')"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

$csproj = @'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net8.0</TargetFramework><Nullable>enable</Nullable></PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Npgsql" Version="8.0.0" />
    <PackageReference Include="BCrypt.Net-Next" Version="4.0.3" />
  </ItemGroup>
</Project>
'@

$code = @"
using System;
using System.Threading.Tasks;
using Npgsql;
using BCrypt.Net;

var connStr = "$connStr";
var hash = BCrypt.Net.BCrypt.HashPassword("Cliente123!");
var sql = "UPDATE users SET password_hash = @p, failed_login_attempts = 0, locked_until = NULL WHERE email = 'cliente@panamatravelhub.com'";

await using var c = new NpgsqlConnection(connStr);
await c.OpenAsync();
await using var cmd = new NpgsqlCommand(sql, c);
cmd.Parameters.AddWithValue("p", hash);
var n = await cmd.ExecuteNonQueryAsync();
Console.WriteLine(n > 0 ? "Password de cliente@ actualizado a Cliente123!" : "Usuario cliente@ no encontrado.");
"@

$csproj | Out-File (Join-Path $tempDir "FixPwd.csproj") -Encoding UTF8
$code | Out-File (Join-Path $tempDir "Program.cs") -Encoding UTF8

Push-Location $tempDir
try {
    dotnet restore 2>&1 | Out-Null
    dotnet run -c Release 2>&1
} finally { Pop-Location; Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
