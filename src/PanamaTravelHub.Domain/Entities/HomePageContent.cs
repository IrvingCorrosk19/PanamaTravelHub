namespace PanamaTravelHub.Domain.Entities;

public class HomePageContent : BaseEntity
{
    // Hero Section
    public string HeroTitle { get; set; } = "Descubre Panamá";
    public string HeroSubtitle { get; set; } = "Explora los destinos más increíbles con nuestros tours exclusivos";
    public string HeroSearchPlaceholder { get; set; } = "Buscar tours...";
    
    // Tours Section
    public string ToursSectionTitle { get; set; } = "Tours Disponibles";
    public string ToursSectionSubtitle { get; set; } = "Selecciona tu próxima aventura";
    
    // Footer
    public string FooterBrandText { get; set; } = "ToursPanama";
    public string FooterDescription { get; set; } = "Tu plataforma de confianza para descubrir Panamá";
    public string FooterCopyright { get; set; } = "© 2024 ToursPanama. Todos los derechos reservados.";
    
    // Navigation
    public string NavBrandText { get; set; } = "ToursPanama";
    public string NavToursLink { get; set; } = "Tours";
    public string NavBookingsLink { get; set; } = "Mis Reservas";
    public string NavLoginLink { get; set; } = "Iniciar Sesión";
    public string NavLogoutButton { get; set; } = "Cerrar Sesión";
}

