import Fluent

struct CreateSalesNoteItem: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("sales_note_items")
            .id()
            .field("sales_note_id", .uuid, .required, .references("sales_notes", "id"))
            .field("name", .string, .required)
            .field("quantity", .int, .required)
            .field("unit_price", .int, .required)
            .field("subtotal", .int, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("sales_note_items").delete()
    }
}
