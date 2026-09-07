import Vapor

enum CashflowType: String, Content {
    case expense
    case salesNote = "sales_note"
    
}

struct CashflowResponseDTO: Content {
    let id: UUID
    let type: CashflowType
    let categoryType: String
    let amount: Int
    let occurredAt: Date
    let title: String
    let description: String?
}

struct CashflowExpenseRow: Decodable {
    let id: UUID
    let paidAmount: Int
    let purchasedAt: Date
    let supplierName: String?
    let categoryName: String

    enum CodingKeys: String, CodingKey {
        case id
        case paidAmount = "paid_amount"
        case purchasedAt = "purchased_at"
        case supplierName = "supplier_name"
        case categoryName = "category_name"
    }
}

struct CashflowSalesPaymentRow: Decodable {
    let salesNoteId: UUID
    let identifier: String
    let customerName: String
    let amount: Int
    let paidAt: Date
    let paymentAttempt: Int
    let paymentCount: Int
    let salesNoteStatus: Status

    enum CodingKeys: String, CodingKey {
        case salesNoteId = "sales_note_id"
        case identifier
        case customerName = "customer_name"
        case amount
        case paidAt = "paid_at"
        case paymentAttempt = "payment_attempt"
        case paymentCount = "payment_count"
        case salesNoteStatus = "sales_note_status"
    }
}
