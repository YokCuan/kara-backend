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
        """).first(decoding: SalesNoteItemRow.self)
        
        guard let newSalesNoteItem else {
            throw Abort(.internalServerError, reason: "Failed to create sales note item")
        }
        
        return newSalesNoteItem.salesNoteItem
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
            """).all(decoding: SalesNoteItemRow.self)
        
        return allSalesNoteItems.map(\.salesNoteItem)
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

private struct SalesNoteItemRow: Decodable {
    let id: UUID
    let salesNoteId: UUID
    let name: String
    let quantity: Int
    let unitPrice: Int
    let subtotal: Int
    
    var salesNoteItem: SalesNoteItem {
        SalesNoteItem(
            id: id,
            salesNoteId: salesNoteId,
            name: name,
            quantity: quantity,
            unitPrice: unitPrice,
            subtotal: subtotal
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case salesNoteId = "sales_note_id"
        case name
        case quantity
        case unitPrice = "unit_price"
        case subtotal
    }
}
