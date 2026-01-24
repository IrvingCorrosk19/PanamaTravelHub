namespace PanamaTravelHub.Domain.Entities;

/// <summary>
/// Configuración SMTP/Email (singleton por entorno). Se edita desde el panel admin.
/// </summary>
public class EmailSettings : BaseEntity
{
    public string SmtpHost { get; set; } = "smtp.gmail.com";
    public int SmtpPort { get; set; } = 587;
    public string? SmtpUsername { get; set; }
    public string? SmtpPassword { get; set; }
    public string FromAddress { get; set; } = "noreply@panamatravelhub.com";
    public string FromName { get; set; } = "Panama Travel Hub";
    public bool EnableSsl { get; set; } = true;
}
