-- Script para crear tabla de comentarios de blog
-- Fecha: 2026-01-06

-- Crear tabla blog_comments
CREATE TABLE IF NOT EXISTS blog_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blog_post_id UUID NOT NULL,
    user_id UUID,
    parent_comment_id UUID,
    author_name VARCHAR(200) NOT NULL,
    author_email VARCHAR(200) NOT NULL,
    author_website VARCHAR(500),
    content VARCHAR(5000) NOT NULL,
    status INTEGER NOT NULL DEFAULT 0, -- 0: Pending, 1: Approved, 2: Rejected, 3: Spam
    admin_notes VARCHAR(1000),
    user_ip VARCHAR(50),
    user_agent VARCHAR(500),
    likes INTEGER NOT NULL DEFAULT 0,
    dislikes INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Foreign keys
ALTER TABLE blog_comments
    ADD CONSTRAINT FK_BlogComment_BlogPost
    FOREIGN KEY (blog_post_id) REFERENCES pages(id) ON DELETE CASCADE;

ALTER TABLE blog_comments
    ADD CONSTRAINT FK_BlogComment_User
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE blog_comments
    ADD CONSTRAINT FK_BlogComment_ParentComment
    FOREIGN KEY (parent_comment_id) REFERENCES blog_comments(id) ON DELETE CASCADE;

-- Índices
CREATE INDEX IF NOT EXISTS IX_BlogComment_BlogPostId ON blog_comments(blog_post_id);
CREATE INDEX IF NOT EXISTS IX_BlogComment_UserId ON blog_comments(user_id);
CREATE INDEX IF NOT EXISTS IX_BlogComment_ParentCommentId ON blog_comments(parent_comment_id);
CREATE INDEX IF NOT EXISTS IX_BlogComment_Status ON blog_comments(status);
CREATE INDEX IF NOT EXISTS IX_BlogComment_CreatedAt ON blog_comments(created_at);

-- Índice compuesto para consultas comunes
CREATE INDEX IF NOT EXISTS IX_BlogComment_BlogPost_Status_CreatedAt 
    ON blog_comments(blog_post_id, status, created_at DESC);

-- Constraints
ALTER TABLE blog_comments
    ADD CONSTRAINT CK_BlogComment_Likes_NonNegative CHECK (likes >= 0);

ALTER TABLE blog_comments
    ADD CONSTRAINT CK_BlogComment_Dislikes_NonNegative CHECK (dislikes >= 0);

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION update_blog_comments_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_blog_comments_updated_at
    BEFORE UPDATE ON blog_comments
    FOR EACH ROW
    EXECUTE FUNCTION update_blog_comments_updated_at();

-- Comentarios en la tabla
COMMENT ON TABLE blog_comments IS 'Comentarios de posts de blog';
COMMENT ON COLUMN blog_comments.status IS '0: Pending, 1: Approved, 2: Rejected, 3: Spam';
COMMENT ON COLUMN blog_comments.parent_comment_id IS 'ID del comentario padre para comentarios anidados (respuestas)';
