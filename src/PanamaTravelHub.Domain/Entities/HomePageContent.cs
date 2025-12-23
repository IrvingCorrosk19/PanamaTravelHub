namespace PanamaTravelHub.Domain.Entities;

public class HomePageContent : BaseEntity
{
    // Hero Section
    public string HeroTitle { get; set; } = "Descubre Panamá";
    public string HeroSubtitle { get; set; } = "Explora los destinos más increíbles con nuestros tours exclusivos";
    public string HeroSearchPlaceholder { get; set; } = "Buscar tours...";
    public string HeroSearchButton { get; set; } = "Buscar";
    
    // Tours Section
    public string ToursSectionTitle { get; set; } = "Tours Disponibles";
    public string ToursSectionSubtitle { get; set; } = "Selecciona tu próxima aventura";
    public string LoadingToursText { get; set; } = "Cargando tours...";
    public string ErrorLoadingToursText { get; set; } = "Error al cargar los tours. Por favor, intenta de nuevo.";
    public string NoToursFoundText { get; set; } = "No se encontraron tours disponibles.";
    
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
    
    // SEO
    public string PageTitle { get; set; } = "ToursPanama — Descubre los Mejores Tours en Panamá";
    public string MetaDescription { get; set; } = "Plataforma moderna de reservas de tours en Panamá. Explora, reserva y disfruta de las mejores experiencias turísticas.";
}

