import Fluent
import Vapor
import SQLKit

protocol AuthTokenRepositoryProtocol: Sendable {
    func create(_ userId: UUID, tokenHash: String, expiresAt: Date, deviceName: String?, on db: any Database) async throws
    func findActiveByHash(_ tokenHash: String, on db: any Database) async throws -> AuthToken?
    func revokeByHash(_ tokenHash: String, revokedAt: Date, on db: any Database) async throws
}


struct AuthTokenRepository: AuthTokenRepositoryProtocol, Sendable {
    func create(_ userId: UUID, tokenHash: String, expiresAt: Date, deviceName: String?, on db: any Database) async throws {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let id = UUID()
        let now = Date()
        
        try await sql.raw("""
            INSERT INTO auth_tokens 
                (id, user_id, token_hash, expires_at, created_at, revoked_at, device_name)
            VALUES 
                (\(bind: id), \(bind: userId), \(bind: tokenHash), \(bind: expiresAt), \(bind: now), NULL, \(bind: deviceName))
        """).run()
        
        
    }
    
    func findActiveByHash(_ tokenHash: String, on db: any Database) async throws -> AuthToken? {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let row = try await sql.raw("""
            SELECT
                id, user_id, token_hash, expires_at, created_at, revoked_at, device_name
            FROM auth_tokens
            WHERE token_hash = \(bind: tokenHash) AND revoked_at IS NULL AND expires_at > NOW()
            LIMIT 1
        """).first(decoding: AuthTokenRow.self)
        
        return row?.authToken
    }
    
    func revokeByHash(_ tokenHash: String, revokedAt: Date, on db: any Database) async throws {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        try await sql.raw("""
            UPDATE auth_tokens
            SET revoked_at = \(bind: revokedAt)
            WHERE token_hash = \(bind: tokenHash) AND revoked_at IS NULL
        """).run()
    }
}
