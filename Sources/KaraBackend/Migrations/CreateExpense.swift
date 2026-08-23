import Fluent

struct CreateExpense: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("expenses")
            .id()
            .field("shop_id", .uuid, .required, .references("shops", "id"))
            .field("expense_category_id", .uuid, .required, .references("expense_categories", "id"))
            .field("supplier_name", .string)
            .field("supplier_phone", .string)
            .field("paid_amount", .int, .required)
            .field("purchased_at", .datetime, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .field("created_by", .string, .required)
            .field("updated_by", .string, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("expenses").delete()
    }
}
