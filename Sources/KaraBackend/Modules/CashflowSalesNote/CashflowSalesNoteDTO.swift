import Vapor

struct CreateCashflowSalesNoteItemDTO: Content {
    let name: String
    let quantity: Int
    let unitPrice: Int
}

struct CreateCashflowSalesNoteDTO: Content {
    let shopId: UUID
    let customerName: String
    let customerPhone: String?
    let paidAmount: Int
    let noteFileLink: String?
    let dueAt: Date?
    let soldAt: Date
    let createdBy: String
    let updatedBy: String
    let items: [CreateCashflowSalesNoteItemDTO]
}

struct UpdateCashflowSalesNotePaidAmountAndStatusDTO: Content {
    let paidAmount: Int
    let paidAt: Date
}

struct CashflowSalesNoteResponseDTO: Content {
    let salesNote: SalesNoteResponseDTO
    let salesNoteItems: [SalesNoteItemResponseDTO]
    let salesNotePayments: [SalesNotePaymentResponseDTO]
}

struct CashflowSalesNotePaymentsResponseDTO: Content {
    let salesNote: SalesNoteResponseDTO
    let salesNotePayments: [SalesNotePaymentResponseDTO]
}
