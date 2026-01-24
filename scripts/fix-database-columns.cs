using System;
using System.IO;
using System.Threading.Tasks;
using Npgsql;

class Program
{
    static async Task Main(string[] args)
    {
        var connectionString = "Host=localhost;Port=5432;Database=PanamaTravelHub;Username=postgres;Password=Panama2020$";
        
        var scriptPath = Path.Combine(Directory.GetCurrentDirectory(), "..", "database", "fix_all_missing_columns.sql");
        if (!File.Exists(scriptPath))
        {
            Console.WriteLine($"Error: No se encuentra el archivo {scriptPath}");
            return;
        }

        var sql = await File.ReadAllTextAsync(scriptPath);
        
        Console.WriteLine("Conectando a la base de datos...");
        await using var conn = new NpgsqlConnection(connectionString);
        await conn.OpenAsync();
        Console.WriteLine("Conectado exitosamente.");

        Console.WriteLine("Ejecutando script SQL...");
        await using var cmd = new NpgsqlCommand(sql, conn);
        
        try
        {
            await cmd.ExecuteNonQueryAsync();
            Console.WriteLine("Script ejecutado exitosamente.");
            Console.WriteLine("Todas las columnas faltantes han sido agregadas.");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error al ejecutar el script: {ex.Message}");
            Console.WriteLine($"Stack trace: {ex.StackTrace}");
        }
    }
}
