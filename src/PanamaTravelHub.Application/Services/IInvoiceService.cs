using PanamaTravelHub.Domain.Entities;

namespace PanamaTravelHub.Application.Services;

public interface IInvoiceService
{
    Task<Invoice> GenerateInvoiceAsync(Booking booking, string language = "ES");
    Task<List<Invoice>> GetMyInvoicesAsync(Guid userId);
    Task<Invoice?> GetByIdAsync(Guid id, Guid userId);
}
