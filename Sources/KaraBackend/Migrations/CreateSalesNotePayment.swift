import Fluent

struct CreateSalesNotePayment: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("sales_note_payments")
            .id()
            .field("sales_note_id", .uuid, .required, .references("sales_notes", "id"))
            .field("sales_note_identifier", .string, .required)
            .field("payment_attempt", .int, .required)
            .field("paid_amount", .int, .required)
            .field("paid_at", .date, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("sales_note_payments").delete()
    }
}
