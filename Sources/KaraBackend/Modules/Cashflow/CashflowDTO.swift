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
