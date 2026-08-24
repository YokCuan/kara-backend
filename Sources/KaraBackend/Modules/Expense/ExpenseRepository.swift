import Fluent
import Vapor
import SQLKit

protocol ExpenseRepositoryProtocol: Sendable {
    func create(shopId: UUID, expenseCategoryId: UUID, supplierName: String?, supplierPhone: String?, paidAmount: Int, purchasedAt: Date, createdBy: String, updatedBy: String, on db: any Database) async throws -> Expense
    func findAllByShop(_ shopId: UUID, on db: any Database) async throws -> [Expense]
    func findAllByShopAndCategory(_ shopId: UUID, expenseCategoryId: UUID, on db: any Database) async throws -> [Expense]
    func findByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws -> Expense?
}

struct ExpenseRepository: ExpenseRepositoryProtocol, Sendable {
    func create(shopId: UUID, expenseCategoryId: UUID, supplierName: String?, supplierPhone: String?, paidAmount: Int, purchasedAt: Date, createdBy: String, updatedBy: String, on db: any Database) async throws -> Expense {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let id = UUID()
        
        let newExpense = try await sql.raw("""
            INSERT INTO expenses
            (id, shop_id, expense_category_id, supplier_name, supplier_phone, paid_amount, purchased_at, created_by, updated_by)
            VALUES (\(bind: id),\(bind: shopId),\(bind: expenseCategoryId),\(bind: supplierName),\(bind: supplierPhone),\(bind: paidAmount),\(bind: purchasedAt),\(bind: createdBy),\(bind: updatedBy))
            RETURNING id, shop_id, expense_category_id, supplier_name, supplier_phone, paid_amount, purchased_at, created_at, updated_at, created_by, updated_by
        """).first(decoding: Expense.self)
        
        guard let newExpense else {
            throw Abort(.internalServerError, reason: "Failed to create expense")
        }
        
        return newExpense
    }
    
    func findAllByShop(_ shopId: UUID, on db: any Database) async throws -> [Expense] {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let allExpenses = try await sql.raw("""
            SELECT 
                id, shop_id, expense_category_id, supplier_name, supplier_phone, paid_amount, purchased_at, created_at, updated_at, created_by, updated_by
            FROM expenses
            WHERE shop_id = \(bind: shopId)
            """).all(decoding: Expense.self)
        
        return allExpenses
    }
    
    func findAllByShopAndCategory(_ shopId: UUID, expenseCategoryId: UUID, on db: any Database) async throws -> [Expense] {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let allExpenses = try await sql.raw("""
            SELECT 
                id, shop_id, expense_category_id, supplier_name, supplier_phone, paid_amount, purchased_at, created_at, updated_at, created_by, updated_by
            FROM expenses
            WHERE shop_id = \(bind: shopId) AND expense_category_id = \(bind: expenseCategoryId)
            """).all(decoding: Expense.self)
        
        return allExpenses
    }
    
    func findByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws -> Expense? {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let expense = try await sql.raw("""
            SELECT 
                id, shop_id, expense_category_id, supplier_name, supplier_phone, paid_amount, purchased_at, created_at, updated_at, created_by, updated_by
            FROM expenses
            WHERE id = \(bind: id) AND shop_id = \(bind: shopId)
            """).first(decoding: Expense.self)
        
        guard let expense else {
            return nil
        }
        
        return expense
    }
}
