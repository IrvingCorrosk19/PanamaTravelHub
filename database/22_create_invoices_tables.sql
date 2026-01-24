-- ============================================
-- MIGRACIÓN: Tablas de Facturación (Invoices)
-- ============================================

-- Tabla de secuencias de factura por año
CREATE TABLE IF NOT EXISTS invoice_sequences (
    year INTEGER PRIMARY KEY,
    current_value INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT chk_year_positive CHECK (year > 2000 AND year < 2100),
    CONSTRAINT chk_current_value_positive CHECK (current_value >= 0)
);

-- Tabla de facturas
CREATE TABLE IF NOT EXISTS invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    subtotal DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    taxes DECIMAL(10, 2) NOT NULL DEFAULT 0,
    total DECIMAL(10, 2) NOT NULL,
    language VARCHAR(2) NOT NULL DEFAULT 'ES',
    issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pdf_url VARCHAR(500),
    status VARCHAR(20) NOT NULL DEFAULT 'Issued',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_invoice_total_positive CHECK (total >= 0),
    CONSTRAINT chk_invoice_language CHECK (language IN ('ES', 'EN')),
    CONSTRAINT chk_invoice_status CHECK (status IN ('Issued', 'Void')),
    CONSTRAINT chk_currency_length CHECK (LENGTH(currency) = 3)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_invoices_booking_id ON invoices(booking_id);
CREATE INDEX IF NOT EXISTS idx_invoices_user_id ON invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_invoices_issued_at ON invoices(issued_at);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(status);

-- Comentarios
COMMENT ON TABLE invoices IS 'Facturas generadas automáticamente al confirmar pagos';
COMMENT ON TABLE invoice_sequences IS 'Secuencias correlativas de facturas por año (F-YYYY-000000)';
COMMENT ON COLUMN invoices.invoice_number IS 'Número de factura en formato F-YYYY-000000';
COMMENT ON COLUMN invoices.language IS 'Idioma de la factura: ES (Español) o EN (Inglés)';
COMMENT ON COLUMN invoices.pdf_url IS 'URL del PDF generado (se llena cuando se genera el PDF)';
COMMENT ON COLUMN invoices.status IS 'Estado: Issued (Emitida) o Void (Anulada)';
