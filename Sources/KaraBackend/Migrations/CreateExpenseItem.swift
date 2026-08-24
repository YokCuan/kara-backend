import Fluent

struct CreateExpenseItem: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("expense_items")
            .id()
            .field("expense_id", .uuid, .required, .references("expenses", "id",onDelete: .cascade))
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("expense_items").delete()
    }
}
