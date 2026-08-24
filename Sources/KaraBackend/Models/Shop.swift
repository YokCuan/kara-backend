import Fluent
import Vapor

final class Shop: Model, Content, @unchecked Sendable {
    static let schema = "shops"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "owner_id")
    var owner: User
    
    @Field(key: "name")
    var name: String
    
    @OptionalField(key: "description")
    var description: String?
    
    @OptionalField(key: "address")
    var address: String?
    
    @OptionalField(key: "phone")
    var phone: String?
    
    @Children(for: \.$shop)
    var salesNotes: [SalesNote]
    
    @Children(for: \.$shop)
    var expenses: [Expense]
    
    init() {
        
    }
    
    init(id: UUID? = nil, ownerId: UUID, name: String, description: String?, address: String?, phone: String?){
        self.id = id
        self.$owner.id = ownerId
        self.name = name
        self.description = description
        self.address = address
        self.phone = phone
    }
}
