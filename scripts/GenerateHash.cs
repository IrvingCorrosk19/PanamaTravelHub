using System;
using BCrypt.Net;

namespace GenerateHash
{
    class Program
    {
        static void Main(string[] args)
        {
            string password = args.Length > 0 ? args[0] : "123456";
            string hash = BCrypt.Net.BCrypt.HashPassword(password, 11);
            
            Console.WriteLine($"Password: {password}");
            Console.WriteLine($"Hash: {hash}");
        }
    }
}

