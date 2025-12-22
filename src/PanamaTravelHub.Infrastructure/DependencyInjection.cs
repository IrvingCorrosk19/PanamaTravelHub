using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
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
        // Configurar DbContext con PostgreSQL
        var connectionString = configuration.GetConnectionString("DefaultConnection");
        
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseNpgsql(
                connectionString,
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

        return services;
    }
}
