import Fluent
import Vapor
import SQLKit

protocol SalesNotePaymentRepositoryProtocol: Sendable {
    func create(salesNoteId: UUID, paymentAttempt: Int, paidAmount: Int, paidAt: Date, on db: any Database) async throws -> SalesNotePayment
    func findAllBySalesNote(_ salesNoteId: UUID, on db: any Database) async throws -> [SalesNotePayment]
    func findAllForCashflowByShop(_ shopId: UUID, on db: any Database) async throws -> [CashflowSalesPaymentRow]
    func deleteBySalesNote(_ salesNoteId: UUID, on db: any Database) async throws
    func deleteById(_ id: UUID, on db: any Database) async throws
}

struct SalesNotePaymentRepository: SalesNotePaymentRepositoryProtocol, Sendable {
    func create(salesNoteId: UUID, paymentAttempt: Int, paidAmount: Int, paidAt: Date, on db: any Database) async throws -> SalesNotePayment {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let id = UUID()
        
        let newSalesNotePayment = try await sql.raw("""
            INSERT INTO sales_note_payments
            (id, sales_note_id, payment_attempt, paid_amount, paid_at)
            VALUES (\(bind: id), \(bind: salesNoteId), \(bind: paymentAttempt), \(bind: paidAmount), \(bind: paidAt))
            RETURNING id, sales_note_id, payment_attempt, paid_amount, paid_at
        """).first(decoding: SalesNotePaymentRow.self)
        
        guard let newSalesNotePayment else {
            throw Abort(.internalServerError, reason: "Failed to create sales note payment")
        }
        
        return newSalesNotePayment.salesNotePayment
    }
    
    func findAllBySalesNote(_ salesNoteId: UUID, on db: any Database) async throws -> [SalesNotePayment] {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let allSalesNotePayments = try await sql.raw("""
            SELECT
                id, sales_note_id, payment_attempt, paid_amount, paid_at
            FROM sales_note_payments
            WHERE sales_note_id = \(bind: salesNoteId)
            """).all(decoding: SalesNotePaymentRow.self)
        
        return allSalesNotePayments.map(\.salesNotePayment)
    }
    
    func findAllForCashflowByShop(_ shopId: UUID, on db: any Database) async throws -> [CashflowSalesPaymentRow] {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }

        return try await sql.raw("""
            SELECT
                snp.sales_note_id,
                sn.identifier,
                sn.customer_name,
                snp.paid_amount AS amount,
                snp.paid_at,
                snp.payment_attempt,
                sn.status AS sales_note_status,
                COUNT(*) OVER (
                    PARTITION BY snp.sales_note_id
                ) AS payment_count
            FROM sales_note_payments AS snp
            INNER JOIN sales_notes AS sn
                ON sn.id = snp.sales_note_id
            WHERE sn.shop_id = \(bind: shopId)
              AND sn.is_deleted = false
            ORDER BY snp.paid_at DESC
        """).all(decoding: CashflowSalesPaymentRow.self)
    }
    
    func deleteBySalesNote(_ salesNoteId: UUID, on db: any Database) async throws {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        try await sql.raw("""
            DELETE FROM sales_note_payments
            WHERE sales_note_id = \(bind: salesNoteId)
            """).run()
    }
    
    func deleteById(_ id: UUID, on db: any Database) async throws {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        try await sql.raw("""
            DELETE FROM sales_note_payments
            WHERE id = \(bind: id)
            """).run()
    }
}
