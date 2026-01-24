using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PanamaTravelHub.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddEmailSettingsTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "email_settings",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    smtp_host = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    smtp_port = table.Column<int>(type: "integer", nullable: false),
                    smtp_username = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    smtp_password = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    from_address = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    from_name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    enable_ssl = table.Column<bool>(type: "boolean", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_email_settings", x => x.id);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "email_settings");
        }
    }
}
