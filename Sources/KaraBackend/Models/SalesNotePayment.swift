import Fluent
import Foundation

final class SalesNotePayment: Model, @unchecked Sendable {
    static let schema = "sales_note_payments"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "sales_note_id")
    var salesNote: SalesNote
    
    @Field(key: "sales_note_identifier")
    var salesNoteIdentifier: String
    
    @Field(key: "payment_attempt")
    var paymentAttempt: Int
    
    @Field(key: "paid_amount")
    var paidAmount: Int
    
    @Field(key: "paid_at")
    var paidAt: Date
    
    init() {
        
    }
    
    init(id: UUID? = nil, salesNoteId: UUID, salesNoteIdentifier: String, paymentAttempt: Int, paidAmount: Int, paidAt: Date) {
        self.id = id
        self.$salesNote.id = salesNoteId
        self.salesNoteIdentifier = salesNoteIdentifier
        self.paymentAttempt = paymentAttempt
        self.paidAmount = paidAmount
        self.paidAt = paidAt
    }
}
