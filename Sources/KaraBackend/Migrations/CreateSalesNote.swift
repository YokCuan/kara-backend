import Fluent

struct CreateSalesNote: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let status = try await database.enum("status")
            .case("paid")
            .case("dp_paid")
            .case("not_paid")
            .create()
        
        try await database.schema("sales_notes")
            .id()
            .field("shop_id", .uuid, .required, .references("shops", "id"))
            .field("identifier", .string, .required)
            .field("customer_name", .string, .required)
            .field("customer_phone", .string)
            .field("total_amount", .int, .required)
            .field("paid_amount", .int, .required)
            .field("status", status, .required)
            .field("note_file_link", .string)
            .field("due_at", .datetime)
            .field("sold_at", .datetime, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .field("created_by", .string, .required)
            .field("updated_by", .string, .required)
            .field("is_deleted", .bool, .required)
            .unique(on: "shop_id", "identifier")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("sales_notes").delete()
        try await database.enum("status").delete()
    }
}
