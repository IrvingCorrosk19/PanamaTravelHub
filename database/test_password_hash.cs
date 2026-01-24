using System;
using BCrypt.Net;

class Program
{
    static void Main()
    {
        string password = "Admin123!";
        string hash = "$2a$12$kaxsUszZmsDNBElMIhwRseRWzyKXoC06h/pCxptQaE/FkB9IL226u";
        
        Console.WriteLine($"Password: {password}");
        Console.WriteLine($"Hash: {hash}");
        Console.WriteLine();
        
        bool isValid = BCrypt.Net.BCrypt.Verify(password, hash);
        Console.WriteLine($"Verificación: {(isValid ? "✅ VÁLIDO" : "❌ INVÁLIDO")}");
        
        if (!isValid) {
            Console.WriteLine();
            Console.WriteLine("Generando nuevo hash...");
            string newHash = BCrypt.Net.BCrypt.HashPassword(password, 12);
            Console.WriteLine($"Nuevo hash: {newHash}");
            bool newIsValid = BCrypt.Net.BCrypt.Verify(password, newHash);
            Console.WriteLine($"Verificación nuevo hash: {(newIsValid ? "✅ VÁLIDO" : "❌ INVÁLIDO")}");
        }
    }
}
