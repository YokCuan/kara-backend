import Vapor
import Fluent

struct CreateExpenseDTO: Content {
    let shopId: UUID
    let expenseCategoryId: UUID
    let supplierName: String?
    let supplierPhone: String?
    let paidAmount: Int
    let purchasedAt: Date
    let createdBy: String
    let updatedBy: String
}

struct ExpenseResponseDTO: Content {
    let id: UUID
    let shopId: UUID
    let expenseCategoryId: UUID
    let supplierName: String?
    let supplierPhone: String?
    let paidAmount: Int
    let purchasedAt: Date
    let createdAt: Date?
    let updatedAt: Date?
    let createdBy: String
    let updatedBy: String
    
    init(expense: Expense) throws {
        guard let id = expense.id else {
            throw Abort(.internalServerError, reason: "Expense ID is missing")
        }
        
        self.id = id
        self.shopId = expense.$shop.id
        self.expenseCategoryId = expense.$expenseCategory.id
        self.supplierName = expense.supplierName
        self.supplierPhone = expense.supplierPhone
        self.paidAmount = expense.paidAmount
        self.purchasedAt = expense.purchasedAt
        self.createdAt = expense.createdAt
        self.updatedAt = expense.updatedAt
        self.createdBy = expense.createdBy
        self.updatedBy = expense.updatedBy
    }
}

struct ExpensesByShopAndCategoryDTO: Content {
    let shopId: UUID
    let expenseCategoryId: UUID?
}

struct ExpenseByIdAndShopDTO: Content {
//    let id: UUID --- get from req.query instead
    let shopId: UUID
}
