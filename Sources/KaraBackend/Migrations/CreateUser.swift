import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("phone", .string)
            .field("password", .string)
            .field("phone_verified_at", .datetime)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "phone")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("users").delete()
    }
}
