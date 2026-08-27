import Fluent
import Vapor
import SQLKit

protocol SalesNoteItemRepositoryProtocol: Sendable {
    func create(salesNoteId: UUID, name: String, quantity: Int, unitPrice: Int, on db: any Database) async throws -> SalesNoteItem
    func findAllBySalesNote(_ salesNoteId: UUID, on db: any Database) async throws -> [SalesNoteItem]
    func deleteBySalesNote(_ salesNoteId: UUID, on db: any Database) async throws
    func deleteById(_ id: UUID, on db: any Database) async throws
}

struct SalesNoteItemRepository: SalesNoteItemRepositoryProtocol, Sendable {
    func create(salesNoteId: UUID, name: String, quantity: Int, unitPrice: Int, on db: any Database) async throws -> SalesNoteItem {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let id = UUID()
        let subtotal = quantity * unitPrice
        
        let newSalesNoteItem = try await sql.raw("""
            INSERT INTO sales_note_items
            (id, sales_note_id, name, quantity, unit_price, subtotal)
            VALUES (\(bind: id), \(bind: salesNoteId), \(bind: name), \(bind: quantity), \(bind: unitPrice), \(bind: subtotal))
            RETURNING id, sales_note_id, name, quantity, unit_price, subtotal
        """).first(decoding: SalesNoteItem.self)
        
        guard let newSalesNoteItem else {
            throw Abort(.internalServerError, reason: "Failed to create expense item")
        }
        
        return newSalesNoteItem
    }
    
    func findAllBySalesNote(_ salesNoteId: UUID, on db: any Database) async throws -> [SalesNoteItem] {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let allSalesNoteItems = try await sql.raw("""
            SELECT
                id, sales_note_id, name, quantity, unit_price, subtotal
            FROM sales_note_items
            WHERE sales_note_id = \(bind: salesNoteId)
            """).all(decoding: SalesNoteItem.self)
        
        return allSalesNoteItems
    }
    
    func deleteBySalesNote(_ salesNoteId: UUID, on db: any Database) async throws {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        try await sql.raw("""
            DELETE FROM sales_note_items
            WHERE sales_note_id = \(bind: salesNoteId)
            """).run()
    }
    
    func deleteById(_ id: UUID, on db: any Database) async throws {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        try await sql.raw("""
            DELETE FROM sales_note_items
            WHERE id = \(bind: id)
            """).run()
    }
}
