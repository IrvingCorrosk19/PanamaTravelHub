#!/bin/bash
# Build script for Render deployment

echo "Restoring NuGet packages..."
dotnet restore

echo "Building solution..."
dotnet build -c Release --no-restore

echo "Publishing application..."
dotnet publish src/PanamaTravelHub.API/PanamaTravelHub.API.csproj -c Release -o ./publish --no-build

echo "Build completed successfully!"

