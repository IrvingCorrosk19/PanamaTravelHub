using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace PanamaTravelHub.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddInvoicesBlogCommentsAnalytics : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "countries",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    code = table.Column<string>(type: "character varying(2)", maxLength: 2, nullable: false),
                    name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    display_order = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_countries", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "DataProtectionKeys",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    FriendlyName = table.Column<string>(type: "text", nullable: true),
                    Xml = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DataProtectionKeys", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "home_page_content",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    hero_title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    hero_subtitle = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    hero_search_placeholder = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    hero_search_button = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    hero_image_url = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    tours_section_title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    tours_section_subtitle = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: false),
                    loading_tours_text = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    error_loading_tours_text = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: false),
                    no_tours_found_text = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    footer_brand_text = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    footer_description = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    footer_copyright = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    nav_brand_text = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    nav_tours_link = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    nav_bookings_link = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    nav_login_link = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    nav_logout_button = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    page_title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    meta_description = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    logo_url = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    favicon_url = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    logo_url_social = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_home_page_content", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "invoice_sequences",
                columns: table => new
                {
                    year = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    current_value = table.Column<int>(type: "integer", nullable: false, defaultValue: 0)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_invoice_sequences", x => x.year);
                });

            migrationBuilder.CreateTable(
                name: "roles",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    name = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    description = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_roles", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "tour_categories",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    slug = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    description = table.Column<string>(type: "text", nullable: true),
                    display_order = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tour_categories", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "tour_tags",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    name = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    slug = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tour_tags", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "tours",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    description = table.Column<string>(type: "text", nullable: false),
                    itinerary = table.Column<string>(type: "text", nullable: true),
                    includes = table.Column<string>(type: "text", nullable: true),
                    price = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    max_capacity = table.Column<int>(type: "integer", nullable: false),
                    duration_hours = table.Column<int>(type: "integer", nullable: false),
                    location = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    tour_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    available_spots = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    hero_title = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    hero_subtitle = table.Column<string>(type: "text", nullable: true),
                    hero_cta_text = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true, defaultValue: "Ver fechas disponibles"),
                    social_proof_text = table.Column<string>(type: "text", nullable: true),
                    has_certified_guide = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    has_flexible_cancellation = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    available_languages = table.Column<string>(type: "text", nullable: true),
                    highlights_duration = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    highlights_group_type = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    highlights_physical_level = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    highlights_meeting_point = table.Column<string>(type: "text", nullable: true),
                    story_content = table.Column<string>(type: "text", nullable: true),
                    includes_list = table.Column<string>(type: "text", nullable: true),
                    excludes_list = table.Column<string>(type: "text", nullable: true),
                    map_coordinates = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    map_reference_text = table.Column<string>(type: "text", nullable: true),
                    final_cta_text = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true, defaultValue: "¿Listo para vivir esta experiencia?"),
                    final_cta_button_text = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true, defaultValue: "Ver fechas disponibles"),
                    block_order = table.Column<string>(type: "text", nullable: true),
                    block_enabled = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tours", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "users",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    email = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    password_hash = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    first_name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    last_name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    phone = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    failed_login_attempts = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    locked_until = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    last_login_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    email_verified = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    email_verified_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    email_verification_token = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_users", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "coupons",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    code = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    description = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    discount_type = table.Column<int>(type: "integer", nullable: false),
                    discount_value = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    minimum_purchase_amount = table.Column<decimal>(type: "numeric(18,2)", nullable: true),
                    maximum_discount_amount = table.Column<decimal>(type: "numeric(18,2)", nullable: true),
                    valid_from = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    valid_until = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    max_uses = table.Column<int>(type: "integer", nullable: true),
                    max_uses_per_user = table.Column<int>(type: "integer", nullable: true),
                    current_uses = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    is_first_time_only = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    applicable_tour_id = table.Column<Guid>(type: "uuid", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_coupons", x => x.id);
                    table.CheckConstraint("chk_current_uses_non_negative", "current_uses >= 0");
                    table.CheckConstraint("chk_discount_value_positive", "discount_value > 0");
                    table.CheckConstraint("chk_max_uses_per_user_positive", "max_uses_per_user IS NULL OR max_uses_per_user > 0");
                    table.CheckConstraint("chk_max_uses_positive", "max_uses IS NULL OR max_uses > 0");
                    table.CheckConstraint("chk_percentage_range", "discount_type != 1 OR (discount_value >= 0 AND discount_value <= 100)");
                    table.ForeignKey(
                        name: "FK_coupons_tours_applicable_tour_id",
                        column: x => x.applicable_tour_id,
                        principalTable: "tours",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "tour_category_assignments",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    tour_id = table.Column<Guid>(type: "uuid", nullable: false),
                    category_id = table.Column<Guid>(type: "uuid", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tour_category_assignments", x => x.id);
                    table.ForeignKey(
                        name: "FK_tour_category_assignments_tour_categories_category_id",
                        column: x => x.category_id,
                        principalTable: "tour_categories",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_tour_category_assignments_tours_tour_id",
                        column: x => x.tour_id,
                        principalTable: "tours",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "tour_dates",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    tour_id = table.Column<Guid>(type: "uuid", nullable: false),
                    tour_date_time = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    available_spots = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tour_dates", x => x.id);
                    table.ForeignKey(
                        name: "FK_tour_dates_tours_tour_id",
                        column: x => x.tour_id,
                        principalTable: "tours",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "tour_images",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    tour_id = table.Column<Guid>(type: "uuid", nullable: false),
                    image_url = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    alt_text = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    display_order = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    is_primary = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tour_images", x => x.id);
                    table.ForeignKey(
                        name: "FK_tour_images_tours_tour_id",
                        column: x => x.tour_id,
                        principalTable: "tours",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "tour_tag_assignments",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    tour_id = table.Column<Guid>(type: "uuid", nullable: false),
                    tag_id = table.Column<Guid>(type: "uuid", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tour_tag_assignments", x => x.id);
                    table.ForeignKey(
                        name: "FK_tour_tag_assignments_tour_tags_tag_id",
                        column: x => x.tag_id,
                        principalTable: "tour_tags",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_tour_tag_assignments_tours_tour_id",
                        column: x => x.tour_id,
                        principalTable: "tours",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "analytics_events",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    @event = table.Column<string>(name: "event", type: "character varying(100)", maxLength: 100, nullable: false),
                    entity_type = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    entity_id = table.Column<Guid>(type: "uuid", nullable: true),
                    session_id = table.Column<Guid>(type: "uuid", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: true),
                    metadata = table.Column<string>(type: "jsonb", nullable: true),
                    device = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    user_agent = table.Column<string>(type: "text", nullable: true),
                    referrer = table.Column<string>(type: "text", nullable: true),
                    country = table.Column<string>(type: "character varying(2)", maxLength: 2, nullable: true),
                    city = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_analytics_events", x => x.id);
                    table.ForeignKey(
                        name: "FK_analytics_events_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "audit_logs",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    user_id = table.Column<Guid>(type: "uuid", nullable: true),
                    entity_type = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    entity_id = table.Column<Guid>(type: "uuid", nullable: false),
                    action = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    before_state = table.Column<string>(type: "jsonb", nullable: true),
                    after_state = table.Column<string>(type: "jsonb", nullable: true),
                    ip_address = table.Column<string>(type: "character varying(45)", maxLength: 45, nullable: true),
                    user_agent = table.Column<string>(type: "text", nullable: true),
                    correlation_id = table.Column<Guid>(type: "uuid", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_audit_logs", x => x.id);
                    table.ForeignKey(
                        name: "FK_audit_logs_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "login_history",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    ip_address = table.Column<string>(type: "character varying(45)", maxLength: 45, nullable: false),
                    user_agent = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    is_successful = table.Column<bool>(type: "boolean", nullable: false),
                    failure_reason = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    location = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    UserId1 = table.Column<Guid>(type: "uuid", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_login_history", x => x.id);
                    table.ForeignKey(
                        name: "FK_login_history_users_UserId1",
                        column: x => x.UserId1,
                        principalTable: "users",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "FK_login_history_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "media_files",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    file_name = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    file_path = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    file_url = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    mime_type = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    file_size = table.Column<long>(type: "bigint", nullable: false),
                    alt_text = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    description = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    category = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    is_image = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    width = table.Column<int>(type: "integer", nullable: true),
                    height = table.Column<int>(type: "integer", nullable: true),
                    uploaded_by = table.Column<Guid>(type: "uuid", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_media_files", x => x.id);
                    table.ForeignKey(
                        name: "FK_media_files_users_uploaded_by",
                        column: x => x.uploaded_by,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "pages",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    slug = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    content = table.Column<string>(type: "text", nullable: false),
                    excerpt = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    meta_title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    meta_description = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    meta_keywords = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    is_published = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    published_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    template = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    display_order = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    created_by = table.Column<Guid>(type: "uuid", nullable: true),
                    updated_by = table.Column<Guid>(type: "uuid", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_pages", x => x.id);
                    table.ForeignKey(
                        name: "FK_pages_users_created_by",
                        column: x => x.created_by,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_pages_users_updated_by",
                        column: x => x.updated_by,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "password_reset_tokens",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    token = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    expires_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    is_used = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    used_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    ip_address = table.Column<string>(type: "character varying(45)", maxLength: 45, nullable: true),
                    user_agent = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    UserId1 = table.Column<Guid>(type: "uuid", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_password_reset_tokens", x => x.id);
                    table.ForeignKey(
                        name: "FK_password_reset_tokens_users_UserId1",
                        column: x => x.UserId1,
                        principalTable: "users",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "FK_password_reset_tokens_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "refresh_tokens",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    token = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    expires_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    is_revoked = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    revoked_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    replaced_by_token = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    ip_address = table.Column<string>(type: "character varying(45)", maxLength: 45, nullable: true),
                    user_agent = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_refresh_tokens", x => x.id);
                    table.ForeignKey(
                        name: "FK_refresh_tokens_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "user_favorites",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    tour_id = table.Column<Guid>(type: "uuid", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_user_favorites", x => x.id);
                    table.ForeignKey(
                        name: "FK_user_favorites_tours_tour_id",
                        column: x => x.tour_id,
                        principalTable: "tours",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_user_favorites_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "user_roles",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    role_id = table.Column<Guid>(type: "uuid", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_user_roles", x => x.id);
                    table.ForeignKey(
                        name: "FK_user_roles_roles_role_id",
                        column: x => x.role_id,
                        principalTable: "roles",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_user_roles_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "user_two_factor",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    secret_key = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    is_enabled = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    backup_codes = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    phone_number = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    is_sms_enabled = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    enabled_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    last_used_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    UserId1 = table.Column<Guid>(type: "uuid", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_user_two_factor", x => x.id);
                    table.ForeignKey(
                        name: "FK_user_two_factor_users_UserId1",
                        column: x => x.UserId1,
                        principalTable: "users",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "FK_user_two_factor_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "bookings",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    tour_id = table.Column<Guid>(type: "uuid", nullable: false),
                    tour_date_id = table.Column<Guid>(type: "uuid", nullable: true),
                    status = table.Column<int>(type: "integer", nullable: false, defaultValue: 1),
                    number_of_participants = table.Column<int>(type: "integer", nullable: false),
                    total_amount = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    expires_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    notes = table.Column<string>(type: "text", nullable: true),
                    country_id = table.Column<Guid>(type: "uuid", nullable: true),
                    allow_partial_payments = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    payment_plan_type = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_bookings", x => x.id);
                    table.ForeignKey(
                        name: "FK_bookings_countries_country_id",
                        column: x => x.country_id,
                        principalTable: "countries",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_bookings_tour_dates_tour_date_id",
                        column: x => x.tour_date_id,
                        principalTable: "tour_dates",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_bookings_tours_tour_id",
                        column: x => x.tour_id,
                        principalTable: "tours",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_bookings_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "waitlist",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    tour_id = table.Column<Guid>(type: "uuid", nullable: false),
                    tour_date_id = table.Column<Guid>(type: "uuid", nullable: true),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    number_of_participants = table.Column<int>(type: "integer", nullable: false),
                    is_notified = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    notified_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    priority = table.Column<int>(type: "integer", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_waitlist", x => x.id);
                    table.CheckConstraint("chk_participants_positive", "number_of_participants > 0");
                    table.CheckConstraint("chk_priority_positive", "priority >= 0");
                    table.ForeignKey(
                        name: "FK_waitlist_tour_dates_tour_date_id",
                        column: x => x.tour_date_id,
                        principalTable: "tour_dates",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_waitlist_tours_tour_id",
                        column: x => x.tour_id,
                        principalTable: "tours",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_waitlist_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "blog_comments",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    BlogPostId = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: true),
                    ParentCommentId = table.Column<Guid>(type: "uuid", nullable: true),
                    AuthorName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    AuthorEmail = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    AuthorWebsite = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    Content = table.Column<string>(type: "character varying(5000)", maxLength: 5000, nullable: false),
                    Status = table.Column<int>(type: "integer", nullable: false),
                    AdminNotes = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    UserIp = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    UserAgent = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    Likes = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    Dislikes = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_blog_comments", x => x.Id);
                    table.CheckConstraint("CK_BlogComment_Dislikes_NonNegative", "dislikes >= 0");
                    table.CheckConstraint("CK_BlogComment_Likes_NonNegative", "likes >= 0");
                    table.ForeignKey(
                        name: "FK_blog_comments_blog_comments_ParentCommentId",
                        column: x => x.ParentCommentId,
                        principalTable: "blog_comments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_blog_comments_pages_BlogPostId",
                        column: x => x.BlogPostId,
                        principalTable: "pages",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_blog_comments_users_UserId",
                        column: x => x.UserId,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "booking_participants",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    booking_id = table.Column<Guid>(type: "uuid", nullable: false),
                    first_name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    last_name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    email = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    phone = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    date_of_birth = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    special_requirements = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_booking_participants", x => x.id);
                    table.ForeignKey(
                        name: "FK_booking_participants_bookings_booking_id",
                        column: x => x.booking_id,
                        principalTable: "bookings",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "coupon_usages",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    coupon_id = table.Column<Guid>(type: "uuid", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    booking_id = table.Column<Guid>(type: "uuid", nullable: false),
                    discount_amount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    original_amount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    final_amount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_coupon_usages", x => x.id);
                    table.ForeignKey(
                        name: "FK_coupon_usages_bookings_booking_id",
                        column: x => x.booking_id,
                        principalTable: "bookings",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_coupon_usages_coupons_coupon_id",
                        column: x => x.coupon_id,
                        principalTable: "coupons",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_coupon_usages_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "email_notifications",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    user_id = table.Column<Guid>(type: "uuid", nullable: true),
                    booking_id = table.Column<Guid>(type: "uuid", nullable: true),
                    type = table.Column<int>(type: "integer", nullable: false),
                    status = table.Column<int>(type: "integer", nullable: false, defaultValue: 1),
                    to_email = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    subject = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    body = table.Column<string>(type: "text", nullable: false),
                    sent_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    retry_count = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    error_message = table.Column<string>(type: "text", nullable: true),
                    scheduled_for = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_email_notifications", x => x.id);
                    table.ForeignKey(
                        name: "FK_email_notifications_bookings_booking_id",
                        column: x => x.booking_id,
                        principalTable: "bookings",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "FK_email_notifications_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id");
                });

            migrationBuilder.CreateTable(
                name: "invoices",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    invoice_number = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    booking_id = table.Column<Guid>(type: "uuid", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    currency = table.Column<string>(type: "character varying(3)", maxLength: 3, nullable: false, defaultValue: "USD"),
                    subtotal = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    discount = table.Column<decimal>(type: "numeric(10,2)", nullable: false, defaultValue: 0m),
                    taxes = table.Column<decimal>(type: "numeric(10,2)", nullable: false, defaultValue: 0m),
                    total = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    language = table.Column<string>(type: "character varying(2)", maxLength: 2, nullable: false, defaultValue: "ES"),
                    issued_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    pdf_url = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false, defaultValue: "Issued"),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_invoices", x => x.id);
                    table.CheckConstraint("chk_invoice_language", "language IN ('ES', 'EN')");
                    table.CheckConstraint("chk_invoice_status", "status IN ('Issued', 'Void')");
                    table.CheckConstraint("chk_invoice_total_positive", "total >= 0");
                    table.ForeignKey(
                        name: "FK_invoices_bookings_booking_id",
                        column: x => x.booking_id,
                        principalTable: "bookings",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_invoices_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "payments",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    booking_id = table.Column<Guid>(type: "uuid", nullable: false),
                    provider = table.Column<int>(type: "integer", nullable: false),
                    status = table.Column<int>(type: "integer", nullable: false, defaultValue: 1),
                    amount = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    provider_transaction_id = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    provider_payment_intent_id = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    currency = table.Column<string>(type: "character varying(3)", maxLength: 3, nullable: false, defaultValue: "USD"),
                    authorized_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    captured_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    refunded_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    failure_reason = table.Column<string>(type: "text", nullable: true),
                    metadata = table.Column<string>(type: "jsonb", nullable: true),
                    is_partial = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    installment_number = table.Column<int>(type: "integer", nullable: true),
                    total_installments = table.Column<int>(type: "integer", nullable: true),
                    parent_payment_id = table.Column<Guid>(type: "uuid", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_payments", x => x.id);
                    table.ForeignKey(
                        name: "FK_payments_bookings_booking_id",
                        column: x => x.booking_id,
                        principalTable: "bookings",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_payments_payments_parent_payment_id",
                        column: x => x.parent_payment_id,
                        principalTable: "payments",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "sms_notifications",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    user_id = table.Column<Guid>(type: "uuid", nullable: true),
                    booking_id = table.Column<Guid>(type: "uuid", nullable: true),
                    type = table.Column<int>(type: "integer", nullable: false),
                    status = table.Column<int>(type: "integer", nullable: false, defaultValue: 1),
                    to_phone_number = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    message = table.Column<string>(type: "character varying(1600)", maxLength: 1600, nullable: false),
                    sent_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    retry_count = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    error_message = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    scheduled_for = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    provider_message_id = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    provider_response = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sms_notifications", x => x.id);
                    table.ForeignKey(
                        name: "FK_sms_notifications_bookings_booking_id",
                        column: x => x.booking_id,
                        principalTable: "bookings",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_sms_notifications_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "tour_reviews",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    tour_id = table.Column<Guid>(type: "uuid", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    booking_id = table.Column<Guid>(type: "uuid", nullable: true),
                    rating = table.Column<int>(type: "integer", nullable: false),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    comment = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    is_approved = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    is_verified = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    TourId1 = table.Column<Guid>(type: "uuid", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tour_reviews", x => x.id);
                    table.CheckConstraint("chk_rating_range", "rating >= 1 AND rating <= 5");
                    table.ForeignKey(
                        name: "FK_tour_reviews_bookings_booking_id",
                        column: x => x.booking_id,
                        principalTable: "bookings",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_tour_reviews_tours_TourId1",
                        column: x => x.TourId1,
                        principalTable: "tours",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "FK_tour_reviews_tours_tour_id",
                        column: x => x.tour_id,
                        principalTable: "tours",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_tour_reviews_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_analytics_events_created_at",
                table: "analytics_events",
                column: "created_at");

            migrationBuilder.CreateIndex(
                name: "IX_analytics_events_entity_type_entity_id",
                table: "analytics_events",
                columns: new[] { "entity_type", "entity_id" });

            migrationBuilder.CreateIndex(
                name: "IX_analytics_events_event",
                table: "analytics_events",
                column: "event");

            migrationBuilder.CreateIndex(
                name: "IX_analytics_events_session_id",
                table: "analytics_events",
                column: "session_id");

            migrationBuilder.CreateIndex(
                name: "IX_analytics_events_user_id",
                table: "analytics_events",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "idx_audit_logs_action",
                table: "audit_logs",
                column: "action");

            migrationBuilder.CreateIndex(
                name: "idx_audit_logs_correlation_id",
                table: "audit_logs",
                column: "correlation_id");

            migrationBuilder.CreateIndex(
                name: "idx_audit_logs_created_at",
                table: "audit_logs",
                column: "created_at");

            migrationBuilder.CreateIndex(
                name: "idx_audit_logs_entity_type_id",
                table: "audit_logs",
                columns: new[] { "entity_type", "entity_id" });

            migrationBuilder.CreateIndex(
                name: "IX_audit_logs_user_id",
                table: "audit_logs",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_blog_comments_BlogPostId",
                table: "blog_comments",
                column: "BlogPostId");

            migrationBuilder.CreateIndex(
                name: "IX_blog_comments_BlogPostId_Status_CreatedAt",
                table: "blog_comments",
                columns: new[] { "BlogPostId", "Status", "CreatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_blog_comments_CreatedAt",
                table: "blog_comments",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_blog_comments_ParentCommentId",
                table: "blog_comments",
                column: "ParentCommentId");

            migrationBuilder.CreateIndex(
                name: "IX_blog_comments_Status",
                table: "blog_comments",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_blog_comments_UserId",
                table: "blog_comments",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "idx_booking_participants_booking_id",
                table: "booking_participants",
                column: "booking_id");

            migrationBuilder.CreateIndex(
                name: "idx_bookings_country_id",
                table: "bookings",
                column: "country_id");

            migrationBuilder.CreateIndex(
                name: "idx_bookings_created_at",
                table: "bookings",
                column: "created_at");

            migrationBuilder.CreateIndex(
                name: "idx_bookings_status",
                table: "bookings",
                column: "status");

            migrationBuilder.CreateIndex(
                name: "idx_bookings_tour_id",
                table: "bookings",
                column: "tour_id");

            migrationBuilder.CreateIndex(
                name: "idx_bookings_user_id",
                table: "bookings",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "idx_bookings_user_status",
                table: "bookings",
                columns: new[] { "user_id", "status" });

            migrationBuilder.CreateIndex(
                name: "IX_bookings_tour_date_id",
                table: "bookings",
                column: "tour_date_id");

            migrationBuilder.CreateIndex(
                name: "idx_countries_active_order",
                table: "countries",
                columns: new[] { "is_active", "display_order" });

            migrationBuilder.CreateIndex(
                name: "idx_countries_code",
                table: "countries",
                column: "code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_coupon_usages_booking_id",
                table: "coupon_usages",
                column: "booking_id");

            migrationBuilder.CreateIndex(
                name: "IX_coupon_usages_coupon_id",
                table: "coupon_usages",
                column: "coupon_id");

            migrationBuilder.CreateIndex(
                name: "IX_coupon_usages_coupon_id_user_id",
                table: "coupon_usages",
                columns: new[] { "coupon_id", "user_id" });

            migrationBuilder.CreateIndex(
                name: "IX_coupon_usages_user_id",
                table: "coupon_usages",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_coupons_applicable_tour_id",
                table: "coupons",
                column: "applicable_tour_id");

            migrationBuilder.CreateIndex(
                name: "IX_coupons_code",
                table: "coupons",
                column: "code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_coupons_is_active",
                table: "coupons",
                column: "is_active");

            migrationBuilder.CreateIndex(
                name: "IX_coupons_valid_from",
                table: "coupons",
                column: "valid_from");

            migrationBuilder.CreateIndex(
                name: "IX_coupons_valid_until",
                table: "coupons",
                column: "valid_until");

            migrationBuilder.CreateIndex(
                name: "idx_email_notifications_scheduled_for",
                table: "email_notifications",
                column: "scheduled_for");

            migrationBuilder.CreateIndex(
                name: "idx_email_notifications_status",
                table: "email_notifications",
                column: "status");

            migrationBuilder.CreateIndex(
                name: "idx_email_notifications_type",
                table: "email_notifications",
                column: "type");

            migrationBuilder.CreateIndex(
                name: "IX_email_notifications_booking_id",
                table: "email_notifications",
                column: "booking_id");

            migrationBuilder.CreateIndex(
                name: "IX_email_notifications_user_id",
                table: "email_notifications",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_invoices_booking_id",
                table: "invoices",
                column: "booking_id");

            migrationBuilder.CreateIndex(
                name: "IX_invoices_invoice_number",
                table: "invoices",
                column: "invoice_number",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_invoices_issued_at",
                table: "invoices",
                column: "issued_at");

            migrationBuilder.CreateIndex(
                name: "IX_invoices_user_id",
                table: "invoices",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_login_history_created_at",
                table: "login_history",
                column: "created_at");

            migrationBuilder.CreateIndex(
                name: "IX_login_history_ip_address",
                table: "login_history",
                column: "ip_address");

            migrationBuilder.CreateIndex(
                name: "IX_login_history_is_successful",
                table: "login_history",
                column: "is_successful");

            migrationBuilder.CreateIndex(
                name: "IX_login_history_user_id",
                table: "login_history",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_login_history_user_id_created_at",
                table: "login_history",
                columns: new[] { "user_id", "created_at" });

            migrationBuilder.CreateIndex(
                name: "IX_login_history_UserId1",
                table: "login_history",
                column: "UserId1");

            migrationBuilder.CreateIndex(
                name: "idx_media_files_category",
                table: "media_files",
                column: "category");

            migrationBuilder.CreateIndex(
                name: "idx_media_files_created_at",
                table: "media_files",
                column: "created_at");

            migrationBuilder.CreateIndex(
                name: "idx_media_files_is_image",
                table: "media_files",
                column: "is_image");

            migrationBuilder.CreateIndex(
                name: "idx_media_files_uploaded_by",
                table: "media_files",
                column: "uploaded_by");

            migrationBuilder.CreateIndex(
                name: "idx_pages_created_at",
                table: "pages",
                column: "created_at");

            migrationBuilder.CreateIndex(
                name: "idx_pages_is_published",
                table: "pages",
                column: "is_published");

            migrationBuilder.CreateIndex(
                name: "idx_pages_published_order",
                table: "pages",
                columns: new[] { "is_published", "display_order" });

            migrationBuilder.CreateIndex(
                name: "idx_pages_slug_unique",
                table: "pages",
                column: "slug",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_pages_created_by",
                table: "pages",
                column: "created_by");

            migrationBuilder.CreateIndex(
                name: "IX_pages_updated_by",
                table: "pages",
                column: "updated_by");

            migrationBuilder.CreateIndex(
                name: "idx_password_reset_tokens_token",
                table: "password_reset_tokens",
                column: "token",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "idx_password_reset_tokens_user_id",
                table: "password_reset_tokens",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "idx_password_reset_tokens_valid",
                table: "password_reset_tokens",
                columns: new[] { "token", "is_used", "expires_at" });

            migrationBuilder.CreateIndex(
                name: "IX_password_reset_tokens_UserId1",
                table: "password_reset_tokens",
                column: "UserId1");

            migrationBuilder.CreateIndex(
                name: "idx_payments_booking_id",
                table: "payments",
                column: "booking_id");

            migrationBuilder.CreateIndex(
                name: "idx_payments_created_at",
                table: "payments",
                column: "created_at");

            migrationBuilder.CreateIndex(
                name: "idx_payments_provider",
                table: "payments",
                column: "provider");

            migrationBuilder.CreateIndex(
                name: "idx_payments_provider_transaction_id",
                table: "payments",
                column: "provider_transaction_id");

            migrationBuilder.CreateIndex(
                name: "idx_payments_status",
                table: "payments",
                column: "status");

            migrationBuilder.CreateIndex(
                name: "IX_payments_parent_payment_id",
                table: "payments",
                column: "parent_payment_id");

            migrationBuilder.CreateIndex(
                name: "idx_refresh_tokens_token",
                table: "refresh_tokens",
                column: "token",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "idx_refresh_tokens_user_active",
                table: "refresh_tokens",
                columns: new[] { "user_id", "is_revoked", "expires_at" });

            migrationBuilder.CreateIndex(
                name: "idx_refresh_tokens_user_id",
                table: "refresh_tokens",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "idx_roles_name",
                table: "roles",
                column: "name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "idx_sms_notifications_booking_id",
                table: "sms_notifications",
                column: "booking_id");

            migrationBuilder.CreateIndex(
                name: "idx_sms_notifications_provider_id",
                table: "sms_notifications",
                column: "provider_message_id");

            migrationBuilder.CreateIndex(
                name: "idx_sms_notifications_status",
                table: "sms_notifications",
                column: "status");

            migrationBuilder.CreateIndex(
                name: "idx_sms_notifications_status_scheduled",
                table: "sms_notifications",
                columns: new[] { "status", "scheduled_for" });

            migrationBuilder.CreateIndex(
                name: "idx_sms_notifications_user_id",
                table: "sms_notifications",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "idx_tour_categories_active",
                table: "tour_categories",
                column: "is_active");

            migrationBuilder.CreateIndex(
                name: "idx_tour_categories_slug",
                table: "tour_categories",
                column: "slug",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "idx_tour_category_assignments_category",
                table: "tour_category_assignments",
                column: "category_id");

            migrationBuilder.CreateIndex(
                name: "idx_tour_category_assignments_tour",
                table: "tour_category_assignments",
                column: "tour_id");

            migrationBuilder.CreateIndex(
                name: "uq_tour_category",
                table: "tour_category_assignments",
                columns: new[] { "tour_id", "category_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "idx_tour_dates_tour_date_time",
                table: "tour_dates",
                column: "tour_date_time");

            migrationBuilder.CreateIndex(
                name: "idx_tour_dates_tour_id",
                table: "tour_dates",
                column: "tour_id");

            migrationBuilder.CreateIndex(
                name: "idx_tour_images_display_order",
                table: "tour_images",
                columns: new[] { "tour_id", "display_order" });

            migrationBuilder.CreateIndex(
                name: "idx_tour_images_tour_id",
                table: "tour_images",
                column: "tour_id");

            migrationBuilder.CreateIndex(
                name: "IX_tour_reviews_booking_id",
                table: "tour_reviews",
                column: "booking_id");

            migrationBuilder.CreateIndex(
                name: "IX_tour_reviews_is_approved",
                table: "tour_reviews",
                column: "is_approved");

            migrationBuilder.CreateIndex(
                name: "IX_tour_reviews_rating",
                table: "tour_reviews",
                column: "rating");

            migrationBuilder.CreateIndex(
                name: "IX_tour_reviews_tour_id",
                table: "tour_reviews",
                column: "tour_id");

            migrationBuilder.CreateIndex(
                name: "IX_tour_reviews_tour_id_user_id",
                table: "tour_reviews",
                columns: new[] { "tour_id", "user_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_tour_reviews_TourId1",
                table: "tour_reviews",
                column: "TourId1");

            migrationBuilder.CreateIndex(
                name: "IX_tour_reviews_user_id",
                table: "tour_reviews",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "idx_tour_tag_assignments_tag",
                table: "tour_tag_assignments",
                column: "tag_id");

            migrationBuilder.CreateIndex(
                name: "idx_tour_tag_assignments_tour",
                table: "tour_tag_assignments",
                column: "tour_id");

            migrationBuilder.CreateIndex(
                name: "uq_tour_tag",
                table: "tour_tag_assignments",
                columns: new[] { "tour_id", "tag_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "idx_tour_tags_slug",
                table: "tour_tags",
                column: "slug",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "idx_tours_is_active",
                table: "tours",
                column: "is_active");

            migrationBuilder.CreateIndex(
                name: "idx_tours_name",
                table: "tours",
                column: "name");

            migrationBuilder.CreateIndex(
                name: "IX_user_favorites_tour_id",
                table: "user_favorites",
                column: "tour_id");

            migrationBuilder.CreateIndex(
                name: "IX_user_favorites_user_id_tour_id",
                table: "user_favorites",
                columns: new[] { "user_id", "tour_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "idx_user_roles_role_id",
                table: "user_roles",
                column: "role_id");

            migrationBuilder.CreateIndex(
                name: "idx_user_roles_user_id",
                table: "user_roles",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "uq_user_role",
                table: "user_roles",
                columns: new[] { "user_id", "role_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_user_two_factor_is_enabled",
                table: "user_two_factor",
                column: "is_enabled");

            migrationBuilder.CreateIndex(
                name: "IX_user_two_factor_user_id",
                table: "user_two_factor",
                column: "user_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_user_two_factor_UserId1",
                table: "user_two_factor",
                column: "UserId1",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "idx_users_email",
                table: "users",
                column: "email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "idx_users_is_active",
                table: "users",
                column: "is_active");

            migrationBuilder.CreateIndex(
                name: "IX_waitlist_is_active",
                table: "waitlist",
                column: "is_active");

            migrationBuilder.CreateIndex(
                name: "IX_waitlist_is_notified",
                table: "waitlist",
                column: "is_notified");

            migrationBuilder.CreateIndex(
                name: "IX_waitlist_tour_date_id",
                table: "waitlist",
                column: "tour_date_id");

            migrationBuilder.CreateIndex(
                name: "IX_waitlist_tour_id",
                table: "waitlist",
                column: "tour_id");

            migrationBuilder.CreateIndex(
                name: "IX_waitlist_tour_id_tour_date_id_is_active_priority",
                table: "waitlist",
                columns: new[] { "tour_id", "tour_date_id", "is_active", "priority" });

            migrationBuilder.CreateIndex(
                name: "IX_waitlist_user_id",
                table: "waitlist",
                column: "user_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "analytics_events");

            migrationBuilder.DropTable(
                name: "audit_logs");

            migrationBuilder.DropTable(
                name: "blog_comments");

            migrationBuilder.DropTable(
                name: "booking_participants");

            migrationBuilder.DropTable(
                name: "coupon_usages");

            migrationBuilder.DropTable(
                name: "DataProtectionKeys");

            migrationBuilder.DropTable(
                name: "email_notifications");

            migrationBuilder.DropTable(
                name: "home_page_content");

            migrationBuilder.DropTable(
                name: "invoice_sequences");

            migrationBuilder.DropTable(
                name: "invoices");

            migrationBuilder.DropTable(
                name: "login_history");

            migrationBuilder.DropTable(
                name: "media_files");

            migrationBuilder.DropTable(
                name: "password_reset_tokens");

            migrationBuilder.DropTable(
                name: "payments");

            migrationBuilder.DropTable(
                name: "refresh_tokens");

            migrationBuilder.DropTable(
                name: "sms_notifications");

            migrationBuilder.DropTable(
                name: "tour_category_assignments");

            migrationBuilder.DropTable(
                name: "tour_images");

            migrationBuilder.DropTable(
                name: "tour_reviews");

            migrationBuilder.DropTable(
                name: "tour_tag_assignments");

            migrationBuilder.DropTable(
                name: "user_favorites");

            migrationBuilder.DropTable(
                name: "user_roles");

            migrationBuilder.DropTable(
                name: "user_two_factor");

            migrationBuilder.DropTable(
                name: "waitlist");

            migrationBuilder.DropTable(
                name: "pages");

            migrationBuilder.DropTable(
                name: "coupons");

            migrationBuilder.DropTable(
                name: "tour_categories");

            migrationBuilder.DropTable(
                name: "bookings");

            migrationBuilder.DropTable(
                name: "tour_tags");

            migrationBuilder.DropTable(
                name: "roles");

            migrationBuilder.DropTable(
                name: "countries");

            migrationBuilder.DropTable(
                name: "tour_dates");

            migrationBuilder.DropTable(
                name: "users");

            migrationBuilder.DropTable(
                name: "tours");
        }
    }
}
