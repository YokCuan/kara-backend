import Fluent
import Vapor
import SQLKit

protocol UserRepositoryProtocol: Sendable {
    func create(name: String, phone: String, password: String?, on db: any Database) async throws -> User
    func findAll(on db: any Database) async throws -> [User]
    func findById(_ id: UUID, on db: any Database) async throws -> User?
    func findByPhone(_ phone: String, on db: any Database) async throws -> User?
}

struct UserRepository: UserRepositoryProtocol, Sendable {
    func create(name: String, phone: String, password: String?, on db: any Database) async throws -> User {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let id = UUID()
        let now = Date()
        
        let newUser = try await sql.raw("""
            INSERT INTO users
            (id, name, phone, password, phone_verified_at, created_at, updated_at)
            VALUES (\(bind: id), \(bind: name), \(bind: phone), \(bind: password), NULL, \(bind: now), \(bind: now))
            RETURNING id, name, phone, password, phone_verified_at, created_at, updated_at
        """).first(decoding: UserRow.self)
        
        guard let newUser else {
            throw Abort(.internalServerError, reason: "Failed to create user")
        }
        
        return newUser.user
    }
    
    func findAll(on db: any Database) async throws -> [User] {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let allUsers = try await sql.raw("""
            SELECT
                id, name, phone, password, phone_verified_at, created_at, updated_at
            FROM users
            """).all(decoding: UserRow.self)
        
        return allUsers.map(\.user)
    }
    
    func findById(_ id: UUID, on db: any Database) async throws -> User? {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let user = try await sql.raw("""
            SELECT
                id, name, phone, password, phone_verified_at, created_at, updated_at
            FROM users
            WHERE id = \(bind: id)
            """).first(decoding: UserRow.self)
        
        return user?.user
    }
    
    func findByPhone(_ phone: String, on db: any Database) async throws -> User? {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let user = try await sql.raw("""
            SELECT
                id, name, phone, password, phone_verified_at, created_at, updated_at
            FROM users
            WHERE phone = \(bind: phone)
            """).first(decoding: UserRow.self)
        
        return user?.user
    }
}
