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
            VALUES (\(bind: id),\(bind: name),\(bind: phone),\(bind: password))
            RETURNING id, name, phone
        """).first(decoding: User.self)
        
        guard let newUser else {
            throw Abort(.internalServerError, reason: "Failed to create user")
        }
        
        return newUser
    }
    
    func findAll(on db: any Database) async throws -> [User] {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let allUsers = try await sql.raw("""
            SELECT 
                id, name, phone
            FROM users
            """).all(decoding: User.self)
        
        return allUsers
    }
    
    
    func findById(_ id: UUID, on db: any Database) async throws -> User? {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let user = try await sql.raw("""
            SELECT 
                id, name, phone
            FROM users
            WHERE id = \(bind: id)
            """).first(decoding: User.self)
        
        guard let user else {
            return nil
        }
        
        return user
    }
    
    func findByPhone(_ phone: String, on db: any Database) async throws -> User? {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let user = try await sql.raw("""
            SELECT 
                id, name, phone
            FROM users
            WHERE phone = \(bind: phone)
            """).first(decoding: User.self)
        
        guard let user else {
            return nil
        }
        
        return user
    }
}
