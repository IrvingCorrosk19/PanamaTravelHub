using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace PanamaTravelHub.API.Pages;

[Authorize]
public class AdminModel : PageModel
{
    public IActionResult OnGet()
    {
        return RedirectPermanent("/admin.html");
    }
}

