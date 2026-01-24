namespace PanamaTravelHub.Infrastructure.Services;

public static class InvoiceTexts
{
    public static string Get(string key, string lang)
    {
        return lang switch
        {
            "EN" => En.TryGetValue(key, out var enValue) ? enValue : key,
            _ => Es.TryGetValue(key, out var esValue) ? esValue : key
        };
    }

    private static readonly Dictionary<string, string> Es = new()
    {
        ["Invoice"] = "Factura",
        ["IssuedAt"] = "Fecha de emisión",
        ["Customer"] = "Cliente",
        ["Email"] = "Correo electrónico",
        ["Phone"] = "Teléfono",
        ["Tour"] = "Tour",
        ["TourDate"] = "Fecha del tour",
        ["Location"] = "Ubicación",
        ["Participants"] = "Participantes",
        ["Subtotal"] = "Subtotal",
        ["Discount"] = "Descuento",
        ["Taxes"] = "Impuestos",
        ["Total"] = "Total",
        ["ThankYou"] = "Gracias por tu reserva",
        ["InvoiceDetails"] = "Detalles de la Factura",
        ["CustomerInfo"] = "Información del Cliente",
        ["TourInfo"] = "Información del Tour",
        ["PaymentSummary"] = "Resumen de Pago"
    };

    private static readonly Dictionary<string, string> En = new()
    {
        ["Invoice"] = "Invoice",
        ["IssuedAt"] = "Issue date",
        ["Customer"] = "Customer",
        ["Email"] = "Email",
        ["Phone"] = "Phone",
        ["Tour"] = "Tour",
        ["TourDate"] = "Tour date",
        ["Location"] = "Location",
        ["Participants"] = "Participants",
        ["Subtotal"] = "Subtotal",
        ["Discount"] = "Discount",
        ["Taxes"] = "Taxes",
        ["Total"] = "Total",
        ["ThankYou"] = "Thank you for your booking",
        ["InvoiceDetails"] = "Invoice Details",
        ["CustomerInfo"] = "Customer Information",
        ["TourInfo"] = "Tour Information",
        ["PaymentSummary"] = "Payment Summary"
    };
}
