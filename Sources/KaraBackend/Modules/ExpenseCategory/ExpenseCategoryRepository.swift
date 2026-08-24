import Fluent
import Vapor
import SQLKit

protocol ExpenseCategoryRepositoryProtocol: Sendable {
    func create(name: String, on db: any Database) async throws -> ExpenseCategory
    func findAll(on db: any Database) async throws -> [ExpenseCategory]
    func findByName(name: String, on db: any Database) async throws -> ExpenseCategory?
    func findByNameSlug(nameSlug: String, on db: any Database) async throws -> ExpenseCategory?
    func deleteById(_ id: UUID, on db: any Database) async throws
}

struct ExpenseCategoryRepository: ExpenseCategoryRepositoryProtocol, Sendable {
    func create(name: String, on db: any Database) async throws -> ExpenseCategory {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let id = UUID()
        let nameSlug = name.lowercased().replacingOccurrences(of: " ", with: "-")
        
        let newExpenseCategory = try await sql.raw("""
            INSERT INTO expense_categories
            (id, name, name_slug)
            VALUES (\(bind: id),\(bind: name),\(bind: nameSlug))
            RETURNING id, name, name_slug
        """).first(decoding: ExpenseCategory.self)
        
        guard let newExpenseCategory else {
            throw Abort(.internalServerError, reason: "Failed to create expense category")
        }
        
        return newExpenseCategory
    }
    
    func findAll(on db: any Database) async throws -> [ExpenseCategory] {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        return try await sql.raw("""
            SELECT 
                id, name, name_slug
            FROM expense_categories
            """).all(decoding: ExpenseCategory.self)
    }
    
    func findByName(name: String, on db: any Database) async throws -> ExpenseCategory? {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        return try await sql.raw("""
            SELECT id, name, name_slug
            FROM expense_categories
            WHERE name = \(bind: name)
        """).first(decoding: ExpenseCategory.self)
    }
    
    func findByNameSlug(nameSlug: String, on db: any Database) async throws -> ExpenseCategory? {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        return try await sql.raw("""
            SELECT id, name, name_slug
            FROM expense_categories
            WHERE name_slug = \(bind: nameSlug)
        """).first(decoding: ExpenseCategory.self)
    }
    
    func deleteById(_ id: UUID, on db: any Database) async throws {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        try await sql.raw("""
            DELETE FROM expense_categories
            WHERE id = \(bind: id)
            """).run()
    }
}
