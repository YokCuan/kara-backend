import Fluent

struct CreateExpenseCategory: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("expense_categories")
            .id()
            .field("name", .string, .required)
            .field("name_slug", .string, .required)
            .unique(on: "name_slug")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("expense_categories").delete()
    }
}
