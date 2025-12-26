# Script PowerShell para eliminar el tour de la base de datos
$env:PGPASSWORD = "Panama2020$"
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d PanamaTravelHub -f delete_tour.sql
$env:PGPASSWORD = $null

