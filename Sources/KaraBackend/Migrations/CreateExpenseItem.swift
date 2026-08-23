import Fluent

struct CreateExpenseItem: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("expense_items")
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("expense_items").delete()
    }
}
