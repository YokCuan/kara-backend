import Fluent
import Vapor

final class ExpenseItem: Model, Content, @unchecked Sendable {
    static let schema = "expense_items"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "expense_id")
    var expense: Expense
    
    @Field(key: "name")
    var name: String
    
    init() {
        
    }
    
    init(id: UUID? = nil, expenseId: UUID, name: String){
        self.id = id
        self.$expense.id = expenseId
        self.name = name
    }
}
