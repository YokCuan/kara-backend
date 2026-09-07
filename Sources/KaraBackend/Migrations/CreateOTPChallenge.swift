import Fluent
import Vapor
import SQLKit

struct CreateOTPChallenges: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("otp_challenges")
            .id()
            .field("phone", .string, .required)
            .field("code_hash", .string, .required)
            .field("purpose", .string, .required)
            .field("expires_at", .datetime, .required)
            .field("attempt_count", .int, .required)
            .field("consumed_at", .datetime)
            .field("created_at", .datetime, .required)
            .field("last_sent_at", .datetime, .required)
            .create()

        guard let sql = database as? any SQLDatabase else {
            throw Abort(
                .internalServerError,
                reason: "Database does not support SQL index creation"
            )
        }

        try await sql.raw("""
            CREATE INDEX otp_challenges_phone_purpose_expires_index
            ON otp_challenges (phone, purpose, expires_at);
        """).run()
    }

    func revert(on database: any Database) async throws {
        guard let sql = database as? any SQLDatabase else {
            throw Abort(
                .internalServerError,
                reason: "Database does not support SQL index deletion"
            )
        }

        try await sql.raw("""
            DROP INDEX IF EXISTS otp_challenges_phone_purpose_expires_index;
        """).run()

        try await database.schema("otp_challenges").delete()
    }
}
