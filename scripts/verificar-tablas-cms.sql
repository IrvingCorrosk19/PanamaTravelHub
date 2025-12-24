-- Verificar tablas de CMS
SELECT 
    'media_files' as tabla,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'media_files'
    ) THEN 'EXISTE' ELSE 'NO EXISTE' END as estado,
    (SELECT COUNT(*) FROM media_files) as registros
UNION ALL
SELECT 
    'pages' as tabla,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'pages'
    ) THEN 'EXISTE' ELSE 'NO EXISTE' END as estado,
    (SELECT COUNT(*) FROM pages) as registros;

-- Verificar estructura de media_files
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'media_files'
ORDER BY ordinal_position;

-- Verificar estructura de pages
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'pages'
ORDER BY ordinal_position;


