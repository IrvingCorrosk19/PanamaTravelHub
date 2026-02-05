using System.Text;
using Microsoft.AspNetCore.Hosting;

namespace PanamaTravelHub.API.Services;

/// <summary>
/// Escribe todos los errores del módulo administrador (admin.html) en un archivo físico
/// para tener un único lugar donde revisar fallos del panel admin.
/// </summary>
public class AdminErrorsFileLogger
{
    private readonly string _filePath;
    private static readonly object Lock = new();

    public AdminErrorsFileLogger(IWebHostEnvironment env)
    {
        var logsDir = Path.Combine(env.ContentRootPath, "logs");
        if (!Directory.Exists(logsDir))
            Directory.CreateDirectory(logsDir);
        _filePath = Path.Combine(logsDir, "admin-errors.log");
    }

    /// <summary>Registra un error (excepción o respuesta 4xx/5xx) del módulo admin.</summary>
    public void Log(string method, string path, int? statusCode, string message, string? exceptionType = null, string? stackTrace = null)
    {
        var line = new StringBuilder();
        line.Append(DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss.fff"));
        line.Append(" | ");
        line.Append(method);
        line.Append(" ");
        line.Append(path);
        if (statusCode.HasValue)
            line.Append(" | ").Append(statusCode);
        line.Append(" | ").Append(message);
        if (!string.IsNullOrEmpty(exceptionType))
            line.Append(" | Exception: ").Append(exceptionType);
        if (!string.IsNullOrEmpty(stackTrace))
            line.Append(Environment.NewLine).Append(stackTrace);

        try
        {
            lock (Lock)
            {
                File.AppendAllText(_filePath, line + Environment.NewLine, Encoding.UTF8);
            }
        }
        catch
        {
            // No fallar la request si no se puede escribir el log
        }
    }
}
