import Fluent
import Vapor
import SQLKit

protocol ExpenseItemRepositoryProtocol: Sendable {
    func create(expenseId: UUID, name: String, on db: any Database) async throws -> ExpenseItem
    func findAllByExpense(_ expenseId: UUID, on db: any Database) async throws -> [ExpenseItem]
    func deleteByExpense(_ expenseId: UUID, on db: any Database) async throws
    func deleteById(_ id: UUID, on db: any Database) async throws
}

struct ExpenseItemRepository: ExpenseItemRepositoryProtocol, Sendable {
    func create(expenseId: UUID, name: String, on db: any Database) async throws -> ExpenseItem {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let id = UUID()
        
        let newExpenseItem = try await sql.raw("""
            INSERT INTO expense_items
            (id, expense_id, name)
            VALUES (\(bind: id),\(bind: expenseId),\(bind: name))
            RETURNING id, expense_id, name
        """).first(decoding: ExpenseItem.self)
        
        guard let newExpenseItem else {
            throw Abort(.internalServerError, reason: "Failed to create expense item")
        }
        
        return newExpenseItem
    }
    
    func findAllByExpense(_ expenseId: UUID, on db: any Database) async throws -> [ExpenseItem] {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let allExpenseItems = try await sql.raw("""
            SELECT 
                id, expense_id, name
            FROM expense_items
            """).all(decoding: ExpenseItem.self)
        
        return allExpenseItems
    }
    
    func deleteByExpense(_ expenseId: UUID,on db: any Database) async throws {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        try await sql.raw("""
                DELETE FROM expense_items
                WHERE expense_id = \(bind: expenseId)
            """).run()
    }
    
    func deleteById(_ id: UUID, on db: any Database) async throws {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        try await sql.raw("""
            DELETE FROM expense_items
            WHERE id = \(bind: id)
            """).run()
    }
}
