using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using PanamaTravelHub.Application.DTOs;

namespace PanamaTravelHub.Infrastructure.Services;

public class InvoicePdfDocument : IDocument
{
    private readonly InvoiceViewModel _vm;

    public InvoicePdfDocument(InvoiceViewModel vm)
    {
        _vm = vm;
    }

    public DocumentMetadata GetMetadata() => DocumentMetadata.Default;

    public void Compose(IDocumentContainer container)
    {
        container.Page(page =>
        {
            page.Size(PageSizes.A4);
            page.Margin(40);
            page.DefaultTextStyle(x => x.FontSize(11).FontFamily(Fonts.Arial));

            page.Content().Column(col =>
            {
                // Header
                col.Item().Row(row =>
                {
                    row.RelativeColumn().Column(c =>
                    {
                        c.Item().Text("PanamaTravelHub")
                            .FontSize(18)
                            .Bold()
                            .FontColor(Colors.Blue.Darken2);
                        c.Item().Text("Tours en Panamá")
                            .FontSize(12)
                            .FontColor(Colors.Grey.Darken1);
                    });

                    row.ConstantColumn(200).AlignRight().Column(c =>
                    {
                        c.Item().Text($"{InvoiceTexts.Get("Invoice", _vm.Language)} {_vm.InvoiceNumber}")
                            .FontSize(16)
                            .Bold();
                        c.Item().Text($"{InvoiceTexts.Get("IssuedAt", _vm.Language)}: {_vm.IssuedAt:dd/MM/yyyy}")
                            .FontSize(10)
                            .FontColor(Colors.Grey.Darken1);
                    });
                });

                col.Item().PaddingVertical(20);

                // Información del Cliente
                col.Item().Text(InvoiceTexts.Get("CustomerInfo", _vm.Language))
                    .FontSize(12)
                    .Bold()
                    .FontColor(Colors.Blue.Darken2);

                col.Item().PaddingVertical(5);

                col.Item().Column(customerCol =>
                {
                    customerCol.Item().Text($"{InvoiceTexts.Get("Customer", _vm.Language)}: {_vm.CustomerName}");
                    customerCol.Item().Text($"{InvoiceTexts.Get("Email", _vm.Language)}: {_vm.CustomerEmail}");
                    if (!string.IsNullOrEmpty(_vm.CustomerPhone))
                    {
                        customerCol.Item().Text($"{InvoiceTexts.Get("Phone", _vm.Language)}: {_vm.CustomerPhone}");
                    }
                });

                col.Item().PaddingVertical(15);

                // Información del Tour
                col.Item().Text(InvoiceTexts.Get("TourInfo", _vm.Language))
                    .FontSize(12)
                    .Bold()
                    .FontColor(Colors.Blue.Darken2);

                col.Item().PaddingVertical(5);

                col.Item().Column(tourCol =>
                {
                    tourCol.Item().Text($"{InvoiceTexts.Get("Tour", _vm.Language)}: {_vm.TourName}");
                    if (_vm.TourDate.HasValue)
                    {
                        tourCol.Item().Text($"{InvoiceTexts.Get("TourDate", _vm.Language)}: {_vm.TourDate.Value:dd/MM/yyyy}");
                    }
                    if (!string.IsNullOrEmpty(_vm.TourLocation))
                    {
                        tourCol.Item().Text($"{InvoiceTexts.Get("Location", _vm.Language)}: {_vm.TourLocation}");
                    }
                    tourCol.Item().Text($"{InvoiceTexts.Get("Participants", _vm.Language)}: {_vm.Participants}");
                });

                col.Item().PaddingVertical(20);

                // Resumen de Pago
                col.Item().Text(InvoiceTexts.Get("PaymentSummary", _vm.Language))
                    .FontSize(12)
                    .Bold()
                    .FontColor(Colors.Blue.Darken2);

                col.Item().PaddingVertical(10);

                col.Item().Table(table =>
                {
                    table.ColumnsDefinition(c =>
                    {
                        c.RelativeColumn(3);
                        c.ConstantColumn(120);
                    });

                    void Row(string label, decimal value, bool isBold = false)
                    {
                        var labelText = table.Cell().Text(InvoiceTexts.Get(label, _vm.Language));
                        if (isBold) labelText.Bold();

                        var valueText = table.Cell()
                            .AlignRight()
                            .Text($"{_vm.Currency} {value:N2}");
                        if (isBold) valueText.Bold();
                    }

                    Row("Subtotal", _vm.Subtotal);
                    
                    if (_vm.Discount > 0)
                    {
                        Row("Discount", _vm.Discount);
                    }
                    
                    if (_vm.Taxes > 0)
                    {
                        Row("Taxes", _vm.Taxes);
                    }

                    table.Cell().Element(e => e.PaddingTop(5).BorderTop(1).BorderColor(Colors.Grey.Lighten1));
                    table.Cell().Element(e => e.PaddingTop(5).BorderTop(1).BorderColor(Colors.Grey.Lighten1));

                    Row("Total", _vm.Total, isBold: true);
                });

                col.Item().PaddingTop(30);

                // Footer
                col.Item().AlignCenter().Text(InvoiceTexts.Get("ThankYou", _vm.Language))
                    .FontSize(11)
                    .Italic()
                    .FontColor(Colors.Grey.Darken1);

                col.Item().PaddingTop(10);

                col.Item().AlignCenter().Text("PanamaTravelHub - ToursPanama")
                    .FontSize(9)
                    .FontColor(Colors.Grey.Darken2);
            });
        });
    }
}
