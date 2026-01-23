using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using System.Text.Encodings.Web;
using System.Text.Unicode;
using AspNetCoreRateLimit;
using Npgsql;
using PanamaTravelHub.API.Middleware;
using PanamaTravelHub.API.Filters;
using PanamaTravelHub.Application.Validators;
using PanamaTravelHub.Infrastructure;
using PanamaTravelHub.Infrastructure.Data;
using FluentValidation;
using Serilog;
using Serilog.Events;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.HttpOverrides;

// Configurar Npgsql para usar UTC para todos los DateTime
// Esto es necesario porque PostgreSQL requiere DateTime en UTC
AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", false);

var builder = WebApplication.CreateBuilder(args);

// Configurar Serilog ANTES de crear el host
// En Render, los logs deben ir a stdout/stderr para aparecer en la consola
var isProduction = builder.Environment.IsProduction();
var logsDirectory = Path.Combine(builder.Environment.ContentRootPath, "logs");

// Crear directorio de logs solo en desarrollo
if (!isProduction && !Directory.Exists(logsDirectory))
{
    Directory.CreateDirectory(logsDirectory);
}

var loggerConfiguration = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration) // Leer configuración desde appsettings.json
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.AspNetCore", LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.EntityFrameworkCore", LogEventLevel.Information)
    .MinimumLevel.Override("Microsoft.EntityFrameworkCore.Database.Command", LogEventLevel.Information)
    // Permitir logs de nuestros controladores y servicios
    .MinimumLevel.Override("PanamaTravelHub", LogEventLevel.Debug)
    .Enrich.FromLogContext()
    .Enrich.WithEnvironmentName()
    .Enrich.WithMachineName()
    .Enrich.WithThreadId();

// SIEMPRE escribir a consola (stdout) - Render captura esto
loggerConfiguration = loggerConfiguration.WriteTo.Console(
    outputTemplate: isProduction 
        ? "[{Timestamp:HH:mm:ss} {Level:u3}] [{SourceContext}] {Message:lj}{NewLine}{Exception}"
        : "[{Timestamp:HH:mm:ss} {Level:u3}] [{SourceContext}] {Message:lj} {Properties:j}{NewLine}{Exception}",
    formatProvider: System.Globalization.CultureInfo.InvariantCulture
);

// Solo escribir a archivo en desarrollo (no en Render)
if (!isProduction && Directory.Exists(logsDirectory))
{
    loggerConfiguration = loggerConfiguration.WriteTo.File(
        path: Path.Combine(logsDirectory, "panamatravelhub-.log"),
        rollingInterval: RollingInterval.Day,
        retainedFileCountLimit: 30,
        shared: true,
        flushToDiskInterval: TimeSpan.FromSeconds(1),
        outputTemplate: "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] [{SourceContext}] {Message:lj} {Properties:j}{NewLine}{Exception}"
    );
}

Log.Logger = loggerConfiguration.CreateLogger();

// Usar Serilog como logger - pasar el logger configurado explícitamente
builder.Host.UseSerilog(Log.Logger);

// Add services to the container
builder.Services.AddControllers(options =>
{
    // Agregar filtro de validación FluentValidation (el principal)
    // ValidationFilter solo hace logging, FluentValidationFilter hace la validación real
    options.Filters.Add<ValidationFilter>();
    options.Filters.Add<FluentValidationFilter>();
})
    .AddJsonOptions(options =>
    {
        // Configurar JSON para usar UTF-8 sin escapar caracteres Unicode
        options.JsonSerializerOptions.Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping;
        options.JsonSerializerOptions.PropertyNamingPolicy = null; // Mantener nombres originales
    })
    .ConfigureApiBehaviorOptions(options =>
    {
        // Deshabilitar validación automática del modelo para usar FluentValidation
        options.SuppressModelStateInvalidFilter = true;
    });

// Configurar FluentValidation
builder.Services.AddValidatorsFromAssemblyContaining<RegisterRequestValidator>();

// Agregar filtro de validación automática
builder.Services.AddScoped<FluentValidationFilter>();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configurar Exception Handler
builder.Services.AddExceptionHandler<GlobalExceptionHandlerMiddleware>();
builder.Services.AddProblemDetails();

// CORS para permitir el frontend
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        var allowedOrigins = new List<string>
        {
            "http://localhost:5000",
            "http://localhost:5001",
            "https://localhost:5001",
            "http://localhost:5018",
            "https://localhost:7009"
        };

        // Agregar dominio de Render si está configurado
        var renderUrl = builder.Configuration["RENDER_URL"];
        if (!string.IsNullOrEmpty(renderUrl))
        {
            allowedOrigins.Add(renderUrl);
        }

        // En producción, permitir cualquier origen de Render
        if (builder.Environment.IsProduction())
        {
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        }
        else
        {
            policy.WithOrigins(allowedOrigins.ToArray())
                  .AllowAnyMethod()
                  .AllowAnyHeader()
                  .AllowCredentials();
        }
    });
});

// Add Infrastructure (DbContext, Repositories, etc.)
builder.Services.AddInfrastructure(builder.Configuration);

// Configurar Razor Pages
builder.Services.AddRazorPages();

// Configurar Data Protection
// En Docker: usar FileSystem cuando ASPNETCORE_DATAPROTECTION_PATH está configurado
// En Render: usar DbContext como fallback
var dataProtectionPath = Environment.GetEnvironmentVariable("ASPNETCORE_DATAPROTECTION_PATH");

var dataProtectionBuilder = builder.Services.AddDataProtection()
    .SetApplicationName("PanamaTravelHub")
    .SetDefaultKeyLifetime(TimeSpan.FromDays(90)); // Keys válidas por 90 días

if (!string.IsNullOrEmpty(dataProtectionPath))
{
    // Docker: usar FileSystem con ruta única por aplicación
    if (!Directory.Exists(dataProtectionPath))
    {
        Directory.CreateDirectory(dataProtectionPath);
    }
    dataProtectionBuilder.PersistKeysToFileSystem(new DirectoryInfo(dataProtectionPath));
}
else
{
    // Render o desarrollo: usar DbContext
    dataProtectionBuilder.PersistKeysToDbContext<ApplicationDbContext>();
}

// Configurar JWT Authentication
var jwtSecretKey = builder.Configuration["Jwt:SecretKey"] ?? throw new InvalidOperationException("JWT SecretKey no configurada");
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "PanamaTravelHub";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "PanamaTravelHub";

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecretKey)),
        ValidateIssuer = true,
        ValidIssuer = jwtIssuer,
        ValidateAudience = true,
        ValidAudience = jwtAudience,
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero // Sin tolerancia de tiempo
    };
});

// Configurar autorización con policies
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
    options.AddPolicy("CustomerOnly", policy => policy.RequireRole("Customer"));
    options.AddPolicy("AdminOrCustomer", policy => policy.RequireRole("Admin", "Customer"));
});

// Configurar Rate Limiting para endpoints de autenticación
builder.Services.AddMemoryCache();
builder.Services.Configure<IpRateLimitOptions>(options =>
{
    options.EnableEndpointRateLimiting = true;
    options.StackBlockedRequests = false;
    options.HttpStatusCode = 429;
    options.RealIpHeader = "X-Real-IP";
    options.ClientIdHeader = "X-ClientId";
    options.GeneralRules = new List<RateLimitRule>
    {
        new RateLimitRule
        {
            Endpoint = "POST:/api/auth/login",
            Period = "1m",
            Limit = 5
        },
        new RateLimitRule
        {
            Endpoint = "POST:/api/auth/register",
            Period = "1m",
            Limit = 3
        },
        new RateLimitRule
        {
            Endpoint = "POST:/api/auth/refresh",
            Period = "1m",
            Limit = 10
        }
    };
});

builder.Services.AddInMemoryRateLimiting();
builder.Services.AddSingleton<IRateLimitConfiguration, RateLimitConfiguration>();

// Configurar Health Checks (debe ir ANTES de builder.Build())
builder.Services.AddHealthChecks()
    .AddNpgSql(
        connectionString: builder.Configuration.GetConnectionString("DefaultConnection") ?? "",
        name: "postgresql",
        tags: new[] { "db", "postgresql" },
        timeout: TimeSpan.FromSeconds(5));

// Health check UI removido - requiere base de datos adicional
// Los endpoints básicos /health, /health/ready, /health/live siguen funcionando

// Alternativa más simple: Rate limiting básico sin paquete externo
// Se puede implementar con middleware personalizado si AspNetCoreRateLimit da problemas

var app = builder.Build();

// Configure the HTTP request pipeline

// ForwardedHeaders para Render (detectar HTTPS desde el proxy)
if (!app.Environment.IsDevelopment())
{
    app.UseForwardedHeaders(new ForwardedHeadersOptions
    {
        ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
    });
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Habilitar archivos estáticos para CSS, JS, imágenes
app.UseStaticFiles();

// En Render, el proxy ya maneja HTTPS, así que solo redirigir en desarrollo
if (app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

// Exception Handler debe ir temprano en el pipeline
app.UseExceptionHandler();

// Security Headers Middleware
app.Use(async (context, next) =>
{
    // Headers de seguridad
    context.Response.Headers["X-Content-Type-Options"] = "nosniff";
    context.Response.Headers["X-Frame-Options"] = "DENY";
    context.Response.Headers["X-XSS-Protection"] = "1; mode=block";
    context.Response.Headers["Referrer-Policy"] = "strict-origin-when-cross-origin";
    context.Response.Headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=()";
    
    // HSTS solo en producción con HTTPS
    if (app.Environment.IsProduction() && context.Request.IsHttps)
    {
        context.Response.Headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains; preload";
    }
    
    // Content Security Policy (CSP) - Ajustar según necesidades
    var csp = "default-src 'self'; " +
              "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.jsdelivr.net https://cdnjs.cloudflare.com; " +
              "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; " +
              "font-src 'self' https://fonts.gstatic.com; " +
              "img-src 'self' data: https: blob:; " +
              "connect-src 'self' https://api.stripe.com; " +
              "frame-src 'self' https://js.stripe.com; " +
              "object-src 'none'; " +
              "base-uri 'self'; " +
              "form-action 'self'; " +
              "frame-ancestors 'none';";
    
    context.Response.Headers["Content-Security-Policy"] = csp;
    
    await next();
});

// Correlation ID middleware (debe ir temprano)
app.Use(async (context, next) =>
{
    var correlationId = context.Request.Headers["X-Correlation-Id"].FirstOrDefault() 
                       ?? Guid.NewGuid().ToString();
    context.Request.Headers["X-Correlation-Id"] = correlationId;
    context.Response.Headers["X-Correlation-Id"] = correlationId;
    context.TraceIdentifier = correlationId;
    await next();
});

// Request Logging Middleware (debe ir después de Correlation ID pero antes de otros middlewares)
app.UseMiddleware<RequestLoggingMiddleware>();

// Middleware para asegurar charset=utf-8 en respuestas JSON
app.Use(async (context, next) =>
{
    await next();
    
    // Asegurar charset=utf-8 en respuestas JSON
    if (context.Response.ContentType?.StartsWith("application/json", StringComparison.OrdinalIgnoreCase) == true)
    {
        if (!context.Response.ContentType.Contains("charset="))
        {
            context.Response.ContentType += "; charset=utf-8";
        }
    }
});

// CORS debe ir antes de UseAuthorization
app.UseCors("AllowFrontend");

// Rate Limiting
app.UseIpRateLimiting();

// Authentication debe ir antes de Authorization
app.UseAuthentication();
app.UseAuthorization();

// Mapear Razor Pages
app.MapRazorPages();

// Audit middleware (debe ir después de authentication para tener acceso al usuario)
app.UseMiddleware<AuditMiddleware>();
app.MapControllers();

// Health check endpoints
app.MapHealthChecks("/health", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
{
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";
        var result = System.Text.Json.JsonSerializer.Serialize(new
        {
            status = report.Status.ToString(),
            timestamp = DateTime.UtcNow,
            checks = report.Entries.Select(e => new
            {
                name = e.Key,
                status = e.Value.Status.ToString(),
                description = e.Value.Description,
                duration = e.Value.Duration.TotalMilliseconds
            })
        });
        await context.Response.WriteAsync(result);
    }
});

app.MapHealthChecks("/health/ready", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("db")
});

app.MapHealthChecks("/health/live", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
{
    Predicate = _ => false // Solo verifica que la app esté viva
});

// Fallback para SPA
app.MapFallbackToFile("index.html");

// Log de inicio de aplicación
Log.Information("=== Iniciando PanamaTravelHub API ===");
Log.Information("Environment: {Environment}", app.Environment.EnvironmentName);
Log.Information("Content Root: {ContentRoot}", app.Environment.ContentRootPath);
if (!isProduction)
{
    Log.Information("Logs Directory: {LogsDirectory}", logsDirectory);
}
Log.Information("Serilog configurado correctamente. Los logs se escriben a stdout/stderr para Render.");

// Aplicar migraciones automáticamente
// En desarrollo y producción, se aplican migraciones automáticamente
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var logger = services.GetRequiredService<ILogger<Program>>();
    var context = services.GetRequiredService<ApplicationDbContext>();
    
    try
    {
        logger.LogInformation("Aplicando migraciones a la base de datos...");
        await context.Database.MigrateAsync();
        logger.LogInformation("Migraciones aplicadas exitosamente!");
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Error al aplicar migraciones. Continuando sin migraciones...");
        // No lanzamos excepción para permitir continuar
        // Si la tabla no existe, se puede crear manualmente con el script SQL
    }
}

Log.Information("=== Aplicación iniciada correctamente ===");
Log.Information("Escuchando requests en los endpoints configurados...");

try
{
    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "=== Error fatal al iniciar la aplicación ===");
    throw;
}
finally
{
    Log.Information("=== Cerrando aplicación ===");
    Log.CloseAndFlush();
}
