using Microsoft.Extensions.DependencyInjection;
using PanamaTravelHub.Application.Services;
using PanamaTravelHub.Domain.Enums;

namespace PanamaTravelHub.Infrastructure.Services;

/// <summary>
/// Implementación del factory para obtener el proveedor de pago correcto según el tipo
/// </summary>
public class PaymentProviderFactory : IPaymentProviderFactory
{
    private readonly IServiceProvider _serviceProvider;

    public PaymentProviderFactory(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public IPaymentProvider GetProvider(PaymentProvider provider)
    {
        return provider switch
        {
            PaymentProvider.Stripe => _serviceProvider.GetRequiredService<StripePaymentProvider>(),
            PaymentProvider.PayPal => _serviceProvider.GetRequiredService<PayPalPaymentProvider>(),
            PaymentProvider.Yappy => _serviceProvider.GetRequiredService<YappyPaymentProvider>(),
            _ => throw new ArgumentException($"Proveedor de pago no soportado: {provider}")
        };
    }
}

