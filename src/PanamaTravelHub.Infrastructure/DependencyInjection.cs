using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Npgsql;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Infrastructure.Data;
using PanamaTravelHub.Infrastructure.Repositories;
using PanamaTravelHub.Infrastructure.Services;

namespace PanamaTravelHub.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // Configurar Npgsql para usar UTC para todos los DateTime
        AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", false);
        
        // Configurar DbContext con PostgreSQL
        var connectionString = configuration.GetConnectionString("DefaultConnection");
        
        // Asegurar que la cadena de conexión incluya encoding UTF-8
        var connectionStringBuilder = new NpgsqlConnectionStringBuilder(connectionString)
        {
            Encoding = "UTF8"
        };
        
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseNpgsql(
                connectionStringBuilder.ConnectionString,
                npgsqlOptions => npgsqlOptions
                    .MigrationsAssembly(typeof(ApplicationDbContext).Assembly.FullName)
                    .EnableRetryOnFailure(
                        maxRetryCount: 5,
                        maxRetryDelay: TimeSpan.FromSeconds(30),
                        errorCodesToAdd: null)
            ));

        // Registrar DbContext como scoped
        services.AddScoped<ApplicationDbContext>();

        // Registrar repositorios
        services.AddScoped(typeof(IRepository<>), typeof(Repository<>));

        // Registrar servicios de aplicación
        services.AddScoped<IBookingService, BookingService>();
        services.AddScoped<InvoicePdfService>();
        services.AddScoped<IInvoiceService, InvoiceService>();

        // Registrar servicios de autenticación
        services.AddScoped<PanamaTravelHub.Application.Services.IPasswordHasher, PanamaTravelHub.Application.Services.PasswordHasher>();
        services.AddScoped<PanamaTravelHub.Application.Services.IJwtService, PanamaTravelHub.Application.Services.JwtService>();

        // Registrar proveedores de pago
        services.AddScoped<StripePaymentProvider>();
        services.AddScoped<PayPalPaymentProvider>();
        services.AddScoped<YappyPaymentProvider>();
        services.AddScoped<IPaymentProviderFactory, PaymentProviderFactory>();
        
        // Por defecto, usar Stripe (para compatibilidad con código existente)
        services.AddScoped<IPaymentProvider>(sp => sp.GetRequiredService<StripePaymentProvider>());

        // Registrar servicios de email
        services.AddScoped<IEmailService, EmailService>();
        services.AddScoped<IEmailTemplateService, EmailTemplateService>();
        services.AddScoped<IEmailNotificationService, EmailNotificationService>();
        
        // Registrar servicios de SMS
        services.AddScoped<ISmsNotificationService, SmsNotificationService>();
        
        // Registrar BackgroundService para procesar cola de emails
        services.AddHostedService<EmailQueueService>();

        // Registrar servicio de auditoría
        services.AddScoped<IAuditService, AuditService>();

        // Registrar HttpClientFactory para el chatbot
        services.AddHttpClient();

        // Registrar servicios del chatbot - FASE 3
        services.AddScoped<IChatbotAIService, ChatbotAIService>();
        services.AddSingleton<IChatbotConversationService, ChatbotConversationService>();

        return services;
    }
}
