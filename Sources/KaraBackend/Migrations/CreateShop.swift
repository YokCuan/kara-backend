import Fluent

struct CreateShop: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("shops")
            .id()
            .field("owner_id", .uuid, .required, .references("users", "id"))
            .field("name", .string, .required)
            .field("description", .string)
            .field("address", .string)
            .field("phone", .string)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("shops").delete()
    }
}
