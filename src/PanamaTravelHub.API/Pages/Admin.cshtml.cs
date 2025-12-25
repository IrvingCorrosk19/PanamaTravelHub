using Microsoft.AspNetCore.Mvc.RazorPages;

namespace PanamaTravelHub.API.Pages;

public class AdminModel : PageModel
{
    public void OnGet()
    {
        // La autorización se maneja en el frontend con JWT tokens
        // El usuario debe estar autenticado y tener rol Admin para acceder
    }
}

