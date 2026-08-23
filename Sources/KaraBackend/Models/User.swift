import Fluent
import Vapor

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "phone")
    var phone: String
    
    @Field(key: "password")
    var password: String
    
    @Children(for: \.$owner)
    var shops: [Shop]

//    @Children(for: \.$user)
//    var userDailyQuests: [UserDailyQuest]
    
    init() {
        
    }
    
    init(id: UUID? = nil, name: String, phone: String, password: String){
        self.id = id
        self.name = name
        self.phone = phone
        self.password = password
    }
}
