using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PanamaTravelHub.Infrastructure.Migrations;

/// <summary>
/// Permite el tipo EmailVerification (5) en email_notifications.
/// El constraint chk_email_type puede haber sido creado por script SQL con solo (1,2,3,4).
/// </summary>
public class AllowEmailVerificationTypeInEmailNotifications : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(@"
            ALTER TABLE email_notifications DROP CONSTRAINT IF EXISTS chk_email_type;
            ALTER TABLE email_notifications ADD CONSTRAINT chk_email_type CHECK (type IN (1, 2, 3, 4, 5));
        ");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(@"
            ALTER TABLE email_notifications DROP CONSTRAINT IF EXISTS chk_email_type;
            ALTER TABLE email_notifications ADD CONSTRAINT chk_email_type CHECK (type IN (1, 2, 3, 4));
        ");
    }
}
