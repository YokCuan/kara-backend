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
        
        let newUser = try await sql.raw("""
            INSERT INTO users
            (id, name, phone, password)
            VALUES (\(bind: id), \(bind: name), \(bind: phone), \(bind: password))
            RETURNING id, name, phone, password
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
                id, name, phone, password
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
                id, name, phone, password
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
                id, name, phone, password
            FROM users
            WHERE phone = \(bind: phone)
            """).first(decoding: UserRow.self)
        
        return user?.user
    }
}

private struct UserRow: Decodable {
    let id: UUID
    let name: String
    let phone: String
    let password: String?
    
    var user: User {
        User(id: id, name: name, phone: phone, password: password)
    }
}
