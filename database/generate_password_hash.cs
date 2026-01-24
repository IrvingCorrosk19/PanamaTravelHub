using System;
using BCrypt.Net;

class Program
{
    static void Main()
    {
        string password = "Admin123!";
        string hash = BCrypt.Net.BCrypt.HashPassword(password, 12);
        Console.WriteLine($"Password: {password}");
        Console.WriteLine($"Hash: {hash}");
        Console.WriteLine();
        Console.WriteLine("SQL para actualizar:");
        Console.WriteLine($"UPDATE users SET password_hash = '{hash}' WHERE email = 'admin@panamatravelhub.com';");
    }
}
