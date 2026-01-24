-- Reset password de Customer a Cliente123!
-- El hash debe generarse con BCrypt (Cliente123!)
-- Ejecutar desde fix-customer-password.ps1 que usa .NET para generar el hash

-- Ejemplo de uso manual (reemplazar HASH_BCRYPT por el hash real):
-- UPDATE users SET password_hash = 'HASH_BCRYPT', failed_login_attempts = 0, locked_until = NULL
-- WHERE email = 'cliente@panamatravelhub.com';

-- Para generar hash: dotnet run en proyecto que use BCrypt.Net-Next
-- BCrypt.Net.BCrypt.HashPassword("Cliente123!")
