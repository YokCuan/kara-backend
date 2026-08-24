import Vapor
import Fluent

struct CreateExpenseCategoryDTO: Content {
    let name: String
    let nameSlug: String
}

struct ExpenseCategoryResponseDTO: Content {
    let id: UUID
    let name: String
    let nameSlug: String
    
    init(expenseCategory: ExpenseCategory) throws {
        guard let id = expenseCategory.id else {
            throw Abort(.internalServerError, reason: "Expense Category ID is missing")
        }
        
        self.id = id
        self.name = expenseCategory.name
        self.nameSlug = expenseCategory.nameSlug
    }
}

struct ExpenseCategoryByNameOrSlugDTO: Content {
    let name: String?
    let nameSlug: String?
}
