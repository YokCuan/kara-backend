import Vapor

enum CashflowType: String, Content {
    case expense
    case salesNote = "sales_note"
}

struct CashflowResponseDTO: Content {
    let id: UUID
    let type: CashflowType
    let amount: Int
    let occurredAt: Date
    let title: String
    let description: String?
}
