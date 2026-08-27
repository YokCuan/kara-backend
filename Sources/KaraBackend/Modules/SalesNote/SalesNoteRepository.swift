import Fluent
import Vapor
import SQLKit

protocol SalesNoteRepositoryProtocol: Sendable {
    func create(shopId: UUID, identifier: String, customerName: String?, customerPhone: String?, totalAmount: Int, paidAmount: Int, status: Status, noteFileLink: String?, dueAt: Date?, soldAt: Date, createdBy: String, updatedBy: String, on db: any Database) async throws -> SalesNote
    func findAllByShop(_ shopId: UUID, on db: any Database) async throws -> [SalesNote]
    func findByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws -> SalesNote?
    func findByShopAndIdentifier(_ shopId: UUID, identifier: String, on db: any Database) async throws -> SalesNote?
    func update(_ id: UUID, shopId: UUID, customerName: String?, customerPhone: String?, totalAmount: Int, paidAmount: Int, status: Status, noteFileLink: String?, dueAt: Date?, soldAt: Date, updatedBy: String, on db: any Database) async throws -> SalesNote
    func softDeleteByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws
    func deleteById(_ id: UUID, on db: any Database) async throws
}

struct SalesNoteRepository: SalesNoteRepositoryProtocol, Sendable {
    func create(shopId: UUID, identifier: String, customerName: String?, customerPhone: String?, totalAmount: Int, paidAmount: Int, status: Status, noteFileLink: String?, dueAt: Date?, soldAt: Date, createdBy: String, updatedBy: String, on db: any Database) async throws -> SalesNote {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let id = UUID()
        let now = Date()
        
        let newSalesNote = try await sql.raw("""
            INSERT INTO sales_notes
            (id, shop_id, identifier, customer_name, customer_phone, total_amount, paid_amount, status, note_file_link, due_at, sold_at, created_at, updated_at, created_by, updated_by)
            VALUES (\(bind: id), \(bind: shopId), \(bind: identifier), \(bind: customerName), \(bind: customerPhone), \(bind: totalAmount),  \(bind: paidAmount), \(bind: status), \(bind: dueAt), \(bind: soldAt), \(bind: now), \(bind: now), \(bind: createdBy), \(bind: updatedBy))
            RETURNING id, shop_id, identifier, customer_name, customer_phone, total_amount, paid_amount, status, note_file_link, due_at, sold_at, created_at, updated_at, created_by, updated_by, is_deleted
        """).first(decoding: SalesNote.self)
        
        guard let newSalesNote else {
            throw Abort(.internalServerError, reason: "Failed to create sales note")
        }
        
        return newSalesNote
    }
    
    func findAllByShop(_ shopId: UUID, on db: any Database) async throws -> [SalesNote] {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let allSalesNotes = try await sql.raw("""
            SELECT
                id, shop_id, identifier, customer_name, customer_phone, total_amount, paid_amount, status, note_file_link, due_at, sold_at, created_at, updated_at, created_by, updated_by, is_deleted
            FROM sales_notes
            WHERE shop_id = \(bind: shopId) AND is_deleted = false
            """).all(decoding: SalesNote.self)
        
        return allSalesNotes
    }
    
    func findByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws -> SalesNote? {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let salesNote = try await sql.raw("""
            SELECT
                id, shop_id, identifier, customer_name, customer_phone, total_amount, paid_amount, status, note_file_link, due_at, sold_at, created_at, updated_at, created_by, updated_by, is_deleted
            FROM sales_notes
            WHERE id = \(bind: id) AND shop_id = \(bind: shopId) AND is_deleted = false
            """).first(decoding: SalesNote.self)
        
        return salesNote
    }
    
    func findByShopAndIdentifier(_ shopId: UUID, identifier: String, on db: any Database) async throws -> SalesNote? {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let salesNote = try await sql.raw("""
            SELECT
                id, shop_id, identifier, customer_name, customer_phone, total_amount, paid_amount, status, note_file_link, due_at, sold_at, created_at, updated_at, created_by, updated_by, is_deleted
            FROM sales_notes
            WHERE shop_id = \(bind: shopId) AND identifier = \(bind: identifier) AND is_deleted = false
            """).first(decoding: SalesNote.self)
        
        return salesNote
    }
    
    func update(_ id: UUID, shopId: UUID, customerName: String?, customerPhone: String?, totalAmount: Int, paidAmount: Int, status: Status, noteFileLink: String?, dueAt: Date?, soldAt: Date, updatedBy: String, on db: any Database) async throws -> SalesNote {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let now = Date()
        
        let salesNote = try await sql.raw("""
            UPDATE sales_notes
            SET
                customer_name = \(bind: customerName),
                customer_phone = \(bind: customerPhone),
                total_amount = \(bind: totalAmount),
                paid_amount = \(bind: paidAmount),
                status = \(bind: status),
                note_file_link = \(bind: noteFileLink),
                due_at = \(bind: dueAt),
                sold_at = \(bind: soldAt),
                updated_at = \(bind: now),
                updated_by = \(bind: updatedBy)
            WHERE id = \(bind: id) AND shop_id = \(bind: shopId)
            RETURNING id, shop_id, identifier, customer_name, customer_phone, total_amount, paid_amount, status, note_file_link, due_at, sold_at, created_at, updated_at, created_by, updated_by, is_deleted
        """).first(decoding: SalesNote.self)
        
        guard let salesNote else {
            throw Abort(.internalServerError, reason: "Failed to update sales note")
        }
        
        return salesNote
    }
    
    func softDeleteByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        try await sql.raw("""
            UPDATE sales_notes
            SET
                is_deleted = NOT is_deleted
            WHERE id = \(bind: id) AND shop_id = \(bind: shopId)
            """).run()
    }
    
    func deleteById(_ id: UUID, on db: any Database) async throws {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        try await sql.raw("""
            DELETE FROM sales_notes
            WHERE id = \(bind: id)
            """).run()
    }
}
