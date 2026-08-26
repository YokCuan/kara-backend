import Vapor

struct CreateCashflowExpenseItemDTO: Content {
    let name: String
}

struct CreateCashflowExpenseDTO: Content {
    let shopId: UUID
    let expenseCategoryId: UUID
    let supplierName: String?
    let supplierPhone: String?
    let paidAmount: Int
    let purchasedAt: Date
    let createdBy: String
    let updatedBy: String
    let items: [CreateCashflowExpenseItemDTO]
}

struct UpdateCashflowExpenseDTO: Content {
    let expenseCategoryId: UUID
    let supplierName: String?
    let supplierPhone: String?
    let paidAmount: Int
    let purchasedAt: Date
    let updatedBy: String
    let items: [CreateCashflowExpenseItemDTO]
}

struct CashflowExpenseResponseDTO: Content {
    let expense: ExpenseResponseDTO
    let expenseItems: [ExpenseItemResponseDTO]
}
