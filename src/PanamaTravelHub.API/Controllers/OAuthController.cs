using Microsoft.AspNetCore.Authentication;
// using Microsoft.AspNetCore.Authentication.Google; // TODO: Instalar paquete si se necesita OAuth de Google
// using Microsoft.AspNetCore.Authentication.Facebook; // TODO: Instalar paquete si se necesita OAuth de Facebook
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PanamaTravelHub.Domain.Entities;
using PanamaTravelHub.Infrastructure.Data;
using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using BCrypt.Net;

namespace PanamaTravelHub.API.Controllers;

[ApiController]
[Route("api/auth/oauth")]
public class OAuthController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly ILogger<OAuthController> _logger;

    public OAuthController(
        ApplicationDbContext context,
        IConfiguration configuration,
        ILogger<OAuthController> logger)
    {
        _context = context;
        _configuration = configuration;
        _logger = logger;
    }

    /// <summary>
    /// Inicia el flujo de autenticación con Google
    /// </summary>
    [HttpGet("google")]
    public IActionResult GoogleLogin()
    {
        return BadRequest(new { message = "OAuth de Google no está configurado. Instale el paquete Microsoft.AspNetCore.Authentication.Google" });
        // TODO: Descomentar cuando se instale Microsoft.AspNetCore.Authentication.Google
        // var redirectUrl = Url.Action(nameof(GoogleCallback), "OAuth", null, Request.Scheme);
        // var properties = new AuthenticationProperties { RedirectUri = redirectUrl };
        // return Challenge(properties, GoogleDefaults.AuthenticationScheme);
    }

    /// <summary>
    /// Callback de Google OAuth
    /// </summary>
    [HttpGet("google/callback")]
    public IActionResult GoogleCallback()
    {
        return BadRequest(new { message = "OAuth de Google no está configurado" });
        // TODO: Descomentar cuando se instale Microsoft.AspNetCore.Authentication.Google
        /*
        var result = await HttpContext.AuthenticateAsync(GoogleDefaults.AuthenticationScheme);
        if (!result.Succeeded)
        {
            return Redirect($"/login.html?error=oauth_failed");
        }

        var claims = result.Principal?.Claims.ToList();
        var email = claims?.FirstOrDefault(c => c.Type == ClaimTypes.Email || c.Type == "email")?.Value;
        var firstName = claims?.FirstOrDefault(c => c.Type == ClaimTypes.GivenName || c.Type == "given_name")?.Value;
        var lastName = claims?.FirstOrDefault(c => c.Type == ClaimTypes.Surname || c.Type == "family_name")?.Value;
        var googleId = claims?.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;

        if (string.IsNullOrEmpty(email))
        {
            return Redirect($"/login.html?error=oauth_email_missing");
        }

        var user = await _context.Users
            .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
            .FirstOrDefaultAsync(u => u.Email == email);

        if (user == null)
        {
            // Crear nuevo usuario
            var customerRole = await _context.Roles.FirstOrDefaultAsync(r => r.Name == "Customer");
            if (customerRole == null)
            {
                return Redirect($"/login.html?error=role_not_found");
            }

            user = new User
            {
                Email = email,
                FirstName = firstName ?? "Usuario",
                LastName = lastName ?? "Google",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(Guid.NewGuid().ToString()), // Password aleatorio
                IsActive = true,
                EmailVerified = true, // Google ya verificó el email
                EmailVerifiedAt = DateTime.UtcNow
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            // Asignar rol Customer
            _context.UserRoles.Add(new UserRole
            {
                UserId = user.Id,
                RoleId = customerRole.Id
            });
            await _context.SaveChangesAsync();
        }

        // Generar tokens JWT
        var tokens = GenerateTokens(user);
        
        // Guardar refresh token
        var refreshToken = new RefreshToken
        {
            UserId = user.Id,
            Token = tokens.RefreshToken,
            ExpiresAt = DateTime.UtcNow.AddDays(30),
            CreatedAt = DateTime.UtcNow
        };
        _context.RefreshTokens.Add(refreshToken);
        await _context.SaveChangesAsync();

        // Redirigir con tokens en query string (en producción usar cookies httpOnly)
        return Redirect($"/login.html?oauth=success&accessToken={tokens.AccessToken}&refreshToken={tokens.RefreshToken}");
        */
    }

    /// <summary>
    /// Inicia el flujo de autenticación con Facebook
    /// TODO: Instalar paquete Microsoft.AspNetCore.Authentication.Facebook para habilitar
    /// </summary>
    [HttpGet("facebook")]
    public IActionResult FacebookLogin()
    {
        return BadRequest(new { message = "OAuth de Facebook no está configurado. Instale el paquete Microsoft.AspNetCore.Authentication.Facebook" });
        // var redirectUrl = Url.Action(nameof(FacebookCallback), "OAuth", null, Request.Scheme);
        // var properties = new AuthenticationProperties { RedirectUri = redirectUrl };
        // return Challenge(properties, FacebookDefaults.AuthenticationScheme);
    }

    /// <summary>
    /// Callback de Facebook OAuth
    /// TODO: Instalar paquete Microsoft.AspNetCore.Authentication.Facebook para habilitar
    /// </summary>
    [HttpGet("facebook/callback")]
    public IActionResult FacebookCallback()
    {
        return BadRequest(new { message = "OAuth de Facebook no está configurado" });
        /* var result = await HttpContext.AuthenticateAsync(FacebookDefaults.AuthenticationScheme);
        if (!result.Succeeded)
        {
            return Redirect($"/login.html?error=oauth_failed");
        }

        var claims = result.Principal?.Claims.ToList();
        var email = claims?.FirstOrDefault(c => c.Type == ClaimTypes.Email || c.Type == "email")?.Value;
        var name = claims?.FirstOrDefault(c => c.Type == ClaimTypes.Name)?.Value;
        var facebookId = claims?.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;

        if (string.IsNullOrEmpty(email))
        {
            return Redirect($"/login.html?error=oauth_email_missing");
        }

        var nameParts = (name ?? "Usuario Facebook").Split(' ');
        var firstName = nameParts[0];
        var lastName = nameParts.Length > 1 ? string.Join(" ", nameParts.Skip(1)) : "Facebook";

        var user = await _context.Users
            .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
            .FirstOrDefaultAsync(u => u.Email == email);

        if (user == null)
        {
            var customerRole = await _context.Roles.FirstOrDefaultAsync(r => r.Name == "Customer");
            if (customerRole == null)
            {
                return Redirect($"/login.html?error=role_not_found");
            }

            user = new User
            {
                Email = email,
                FirstName = firstName,
                LastName = lastName,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(Guid.NewGuid().ToString()),
                IsActive = true,
                EmailVerified = true,
                EmailVerifiedAt = DateTime.UtcNow
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            _context.UserRoles.Add(new UserRole
            {
                UserId = user.Id,
                RoleId = customerRole.Id
            });
            await _context.SaveChangesAsync();
        }

        var tokens = GenerateTokens(user);
        
        var refreshToken = new RefreshToken
        {
            UserId = user.Id,
            Token = tokens.RefreshToken,
            ExpiresAt = DateTime.UtcNow.AddDays(30),
            CreatedAt = DateTime.UtcNow
        };
        _context.RefreshTokens.Add(refreshToken);
        await _context.SaveChangesAsync();

        return Redirect($"/login.html?oauth=success&accessToken={tokens.AccessToken}&refreshToken={tokens.RefreshToken}");
        */
    }

    private (string AccessToken, string RefreshToken) GenerateTokens(User user)
    {
        var roles = user.UserRoles.Select(ur => ur.Role.Name).ToList();
        var isAdmin = roles.Contains("Admin");

        var claims = new List<Claim>
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim(ClaimTypes.Name, $"{user.FirstName} {user.LastName}"),
            new Claim(ClaimTypes.Role, isAdmin ? "Admin" : "Customer")
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"] ?? throw new InvalidOperationException("JWT Key not configured")));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _configuration["Jwt:Issuer"],
            audience: _configuration["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddHours(1),
            signingCredentials: creds
        );

        var accessToken = new JwtSecurityTokenHandler().WriteToken(token);
        var refreshToken = Guid.NewGuid().ToString();

        return (accessToken, refreshToken);
    }
}
