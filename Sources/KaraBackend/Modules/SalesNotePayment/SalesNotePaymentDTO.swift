import Vapor
import Fluent

struct CreateSalesNotePaymentDTO: Content {
    let salesNoteId: UUID
    let paidAmount: Int
    let paidAt: Date
}

struct SalesNotePaymentResponseDTO: Content {
    let id: UUID
    let salesNoteId: UUID
    let paymentAttempt: Int
    let paidAmount: Int
    let paidAt: Date
    
    init(salesNotePayment: SalesNotePayment) throws {
        guard let id = salesNotePayment.id else {
            throw Abort(.internalServerError, reason: "Sales Note Payment ID is missing")
        }
        
        self.id = id
        self.salesNoteId = salesNotePayment.$salesNote.id
        self.paymentAttempt = salesNotePayment.paymentAttempt
        self.paidAmount = salesNotePayment.paidAmount
        self.paidAt = salesNotePayment.paidAt
    }
}

struct SalesNotePaymentRow: Decodable {
    let id: UUID
    let salesNoteId: UUID
    let paymentAttempt: Int
    let paidAmount: Int
    let paidAt: Date
    
    var salesNotePayment: SalesNotePayment {
        SalesNotePayment(
            id: id,
            salesNoteId: salesNoteId,
            paymentAttempt: paymentAttempt,
            paidAmount: paidAmount,
            paidAt: paidAt
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case salesNoteId = "sales_note_id"
        case paymentAttempt = "payment_attempt"
        case paidAmount = "paid_amount"
        case paidAt = "paid_at"
    }
}
