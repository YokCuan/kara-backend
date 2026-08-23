import Fluent
import Vapor

final class ExpenseCategory: Model, Content, @unchecked Sendable {
    static let schema = "expense_categories"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "name_slug")
    var nameSlug: String
    
    @Children(for: \.$expenseCategory)
    var expenses: [Expense]
    
    init() {
        
    }
    
    init(id: UUID? = nil, name: String, nameSlug: String){
        self.id = id
        self.name = name
        self.nameSlug = nameSlug
    }
}
