import Vapor
import Fluent

struct CreateExpenseItemDTO: Content {
    let expenseId: UUID
    let name: String
}

struct ExpenseItemResponseDTO: Content {
    let id: UUID
    let expenseId: UUID
    let name: String
    
    init(expenseItem: ExpenseItem) throws {
        guard let id = expenseItem.id else {
            throw Abort(.internalServerError, reason: "Expense Item ID is missing")
        }
        
        self.id = id
        self.expenseId = expenseItem.$expense.id
        self.name = expenseItem.name
    }
}
