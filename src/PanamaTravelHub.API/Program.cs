using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
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

// Configurar Npgsql para usar UTC para todos los DateTime
// Esto es necesario porque PostgreSQL requiere DateTime en UTC
AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", false);

// Configurar Serilog
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.EntityFrameworkCore", LogEventLevel.Information)
    .Enrich.FromLogContext()
    .Enrich.WithEnvironmentName()
    .Enrich.WithMachineName()
    .Enrich.WithThreadId()
    .WriteTo.Console(
        outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj} {Properties:j}{NewLine}{Exception}")
    .WriteTo.File(
        path: "logs/panamatravelhub-.log",
        rollingInterval: RollingInterval.Day,
        retainedFileCountLimit: 30,
        outputTemplate: "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] {Message:lj} {Properties:j}{NewLine}{Exception}")
    .CreateLogger();

var builder = WebApplication.CreateBuilder(args);

// Usar Serilog como logger
builder.Host.UseSerilog();

// Add services to the container
builder.Services.AddControllers(options =>
{
    // Agregar filtro de validación FluentValidation (el principal)
    // ValidationFilter solo hace logging, FluentValidationFilter hace la validación real
    options.Filters.Add<ValidationFilter>();
    options.Filters.Add<FluentValidationFilter>();
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

// Alternativa más simple: Rate limiting básico sin paquete externo
// Se puede implementar con middleware personalizado si AspNetCoreRateLimit da problemas

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Habilitar archivos estáticos para el frontend
app.UseDefaultFiles();
app.UseStaticFiles();

app.UseHttpsRedirection();

// Exception Handler debe ir temprano en el pipeline
app.UseExceptionHandler();

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

// CORS debe ir antes de UseAuthorization
app.UseCors("AllowFrontend");

// Rate Limiting
app.UseIpRateLimiting();

// Authentication debe ir antes de Authorization
app.UseAuthentication();
app.UseAuthorization();

// Audit middleware (debe ir después de authentication para tener acceso al usuario)
app.UseMiddleware<AuditMiddleware>();
app.MapControllers();

// Configurar Health Checks
builder.Services.AddHealthChecks()
    .AddNpgSql(
        connectionString: builder.Configuration.GetConnectionString("DefaultConnection") ?? "",
        name: "postgresql",
        tags: new[] { "db", "postgresql" },
        timeout: TimeSpan.FromSeconds(5));

// Health check UI (solo en desarrollo)
if (builder.Environment.IsDevelopment())
{
    builder.Services.AddHealthChecksUI(setup =>
    {
        setup.SetEvaluationTimeInSeconds(10);
        setup.MaximumHistoryEntriesPerEndpoint(50);
    }).AddInMemoryStorage();
}

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

app.Run();
