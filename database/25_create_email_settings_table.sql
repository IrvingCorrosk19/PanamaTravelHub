-- ============================================
-- TABLA: email_settings
-- Configuración SMTP/Email (singleton). Se gestiona desde el panel admin.
-- ============================================
CREATE TABLE IF NOT EXISTS email_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    smtp_host VARCHAR(200) NOT NULL DEFAULT 'smtp.gmail.com',
    smtp_port INTEGER NOT NULL DEFAULT 587,
    smtp_username VARCHAR(255),
    smtp_password VARCHAR(500),
    from_address VARCHAR(255) NOT NULL DEFAULT 'noreply@panamatravelhub.com',
    from_name VARCHAR(200) NOT NULL DEFAULT 'Panama Travel Hub',
    enable_ssl BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

COMMENT ON TABLE email_settings IS 'Configuración SMTP para envío de emails. Una sola fila por entorno.';
COMMENT ON COLUMN email_settings.smtp_password IS 'Contraseña o app password. No se expone en GET.';
