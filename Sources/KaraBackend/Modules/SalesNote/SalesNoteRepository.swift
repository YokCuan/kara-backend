import Fluent
import Vapor
import SQLKit

protocol SalesNoteRepositoryProtocol: Sendable {
    func create(shopId: UUID, customerName: String, customerPhone: String?, totalAmount: Int, paidAmount: Int, status: Status, noteFileLink: String?, dueAt: Date?, soldAt: Date, createdBy: String, updatedBy: String, on db: any Database) async throws -> SalesNote
    func findAllByShop(_ shopId: UUID, on db: any Database) async throws -> [SalesNote]
    func findByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws -> SalesNote?
    func findByShopAndIdentifier(_ shopId: UUID, identifier: String, on db: any Database) async throws -> SalesNote?
    func findAllCustomersByShop(_ shopId: UUID, on db: any Database) async throws -> [CustomerRow]
    func update(_ id: UUID, shopId: UUID, customerName: String?, customerPhone: String?, totalAmount: Int, paidAmount: Int, status: Status, noteFileLink: String?, dueAt: Date?, soldAt: Date, updatedBy: String, on db: any Database) async throws -> SalesNote
    func updatePaidAmount(_ id: UUID, shopId: UUID, paidAmount: Int, status: Status, updatedBy: String, on db: any Database) async throws -> SalesNote
    func softDeleteByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws
    func deleteById(_ id: UUID, on db: any Database) async throws
}

struct SalesNoteRepository: SalesNoteRepositoryProtocol, Sendable {
    func create(shopId: UUID, customerName: String, customerPhone: String?, totalAmount: Int, paidAmount: Int, status: Status, noteFileLink: String?, dueAt: Date?, soldAt: Date, createdBy: String, updatedBy: String, on db: any Database) async throws -> SalesNote {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let id = UUID()
        let now = Date()
        let identifier = try await nextIdentifier(for: shopId, on: sql)
        
        let newSalesNote = try await sql.raw("""
            INSERT INTO sales_notes
            (id, shop_id, identifier, customer_name, customer_phone, total_amount, paid_amount, status, note_file_link, due_at, sold_at, created_at, updated_at, created_by, updated_by, is_deleted)
            VALUES (\(bind: id), \(bind: shopId), \(bind: identifier), \(bind: customerName), \(bind: customerPhone), \(bind: totalAmount), \(bind: paidAmount), \(bind: status)::status, \(bind: noteFileLink), \(bind: dueAt), \(bind: soldAt), \(bind: now), \(bind: now), \(bind: createdBy), \(bind: updatedBy), false)
            RETURNING id, shop_id, identifier, customer_name, customer_phone, total_amount, paid_amount, status, note_file_link, due_at, sold_at, created_at, updated_at, created_by, updated_by, is_deleted
        """).first(decoding: SalesNoteRow.self)
        
        guard let newSalesNote else {
            throw Abort(.internalServerError, reason: "Failed to create sales note")
        }
        
        return newSalesNote.salesNote
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
            ORDER BY identifier ASC
            """).all(decoding: SalesNoteRow.self)
        
        return allSalesNotes.map(\.salesNote)
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
            """).first(decoding: SalesNoteRow.self)
        
        return salesNote?.salesNote
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
            """).first(decoding: SalesNoteRow.self)
        
        return salesNote?.salesNote
    }
    
    func findAllCustomersByShop(_ shopId: UUID, on db: any Database) async throws -> [CustomerRow] {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let allCustomers = try await sql.raw("""
            SELECT
                customer_name,
                customer_phone,
                COUNT(*) AS sales_note_count,
                MAX(sold_at) AS last_sold_at
            FROM sales_notes
            WHERE shop_id = \(bind: shopId)
              AND is_deleted = false
            GROUP BY
                customer_name,
                customer_phone
            ORDER BY
                sales_note_count DESC,
                last_sold_at DESC,
                customer_name ASC
            """).all(decoding: CustomerRow.self)
        
        return allCustomers
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
                status = \(bind: status)::status,
                note_file_link = \(bind: noteFileLink),
                due_at = \(bind: dueAt),
                sold_at = \(bind: soldAt),
                updated_at = \(bind: now),
                updated_by = \(bind: updatedBy)
            WHERE id = \(bind: id) AND shop_id = \(bind: shopId) AND is_deleted = false
            RETURNING id, shop_id, identifier, customer_name, customer_phone, total_amount, paid_amount, status, note_file_link, due_at, sold_at, created_at, updated_at, created_by, updated_by, is_deleted
        """).first(decoding: SalesNoteRow.self)
        
        guard let salesNote else {
            throw Abort(.internalServerError, reason: "Failed to update sales note")
        }
        
        return salesNote.salesNote
    }
    
    func updatePaidAmount(_ id: UUID, shopId: UUID, paidAmount: Int, status: Status, updatedBy: String, on db: any Database) async throws -> SalesNote {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let now = Date()
        
        let salesNote = try await sql.raw("""
            UPDATE sales_notes
            SET
                paid_amount = \(bind: paidAmount),
                status = \(bind: status)::status,
                updated_at = \(bind: now),
                updated_by = \(bind: updatedBy)
            WHERE id = \(bind: id) AND shop_id = \(bind: shopId) AND is_deleted = false
            RETURNING id, shop_id, identifier, customer_name, customer_phone, total_amount, paid_amount, status, note_file_link, due_at, sold_at, created_at, updated_at, created_by, updated_by, is_deleted
        """).first(decoding: SalesNoteRow.self)
        
        guard let salesNote else {
            throw Abort(.internalServerError, reason: "Failed to update sales note paid amount")
        }
        
        return salesNote.salesNote
    }
    
    func softDeleteByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        try await sql.raw("""
            UPDATE sales_notes
            SET is_deleted = true
            WHERE id = \(bind: id) AND shop_id = \(bind: shopId) AND is_deleted = false
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
    
    private func nextIdentifier(for shopId: UUID, on sql: any SQLDatabase) async throws -> String {
        let lockedShop = try await sql.raw("""
            SELECT id
            FROM shops
            WHERE id = \(bind: shopId)
            FOR UPDATE
            """).first(decoding: LockedShopRow.self)
        
        guard lockedShop != nil else {
            throw Abort(.notFound, reason: "Shop not found")
        }
        
        let counter = try await sql.raw("""
            SELECT MAX(CAST(identifier AS INTEGER)) AS max_identifier
            FROM sales_notes
            WHERE shop_id = \(bind: shopId)
            """).first(decoding: SalesNoteIdentifierCounterRow.self)
        
        let nextNumber = (counter?.maxIdentifier ?? 0) + 1
        return String(format: "%05d", nextNumber)
    }
}

private struct SalesNoteRow: Decodable {
    let id: UUID
    let shopId: UUID
    let identifier: String
    let customerName: String
    let customerPhone: String?
    let totalAmount: Int
    let paidAmount: Int
    let status: Status
    let noteFileLink: String?
    let dueAt: Date?
    let soldAt: Date
    let createdAt: Date?
    let updatedAt: Date?
    let createdBy: String
    let updatedBy: String
    let isDeleted: Bool
    
    var salesNote: SalesNote {
        SalesNote(
            id: id,
            shopId: shopId,
            identifier: identifier,
            customerName: customerName,
            customerPhone: customerPhone,
            totalAmount: totalAmount,
            paidAmount: paidAmount,
            status: status,
            noteFileLink: noteFileLink,
            dueAt: dueAt,
            soldAt: soldAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            isDeleted: isDeleted
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case shopId = "shop_id"
        case identifier
        case customerName = "customer_name"
        case customerPhone = "customer_phone"
        case totalAmount = "total_amount"
        case paidAmount = "paid_amount"
        case status
        case noteFileLink = "note_file_link"
        case dueAt = "due_at"
        case soldAt = "sold_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case createdBy = "created_by"
        case updatedBy = "updated_by"
        case isDeleted = "is_deleted"
    }
}

private struct LockedShopRow: Decodable {
    let id: UUID
}

private struct SalesNoteIdentifierCounterRow: Decodable {
    let maxIdentifier: Int?
    
    enum CodingKeys: String, CodingKey {
        case maxIdentifier = "max_identifier"
    }
}
