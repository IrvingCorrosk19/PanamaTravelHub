using PanamaTravelHub.Domain.Enums;

namespace PanamaTravelHub.Application.Services;

/// <summary>
/// Factory para obtener el proveedor de pago correcto según el tipo
/// </summary>
public interface IPaymentProviderFactory
{
    IPaymentProvider GetProvider(PaymentProvider provider);
}

