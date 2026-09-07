import Fluent
import Foundation

final class User: Model, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "phone")
    var phone: String
    
    @OptionalField(key: "password")
    var password: String?
    
    @OptionalField(key: "phone_verified_at")
    var phoneVerifiedAt: Date?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Children(for: \.$owner)
    var shops: [Shop]
    
    @Children(for: \.$user)
    var authTokens: [AuthToken]
    
    init() {
        
    }
    
    init(id: UUID? = nil, name: String, phone: String, password: String?, phoneVerifiedAt: Date?, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.name = name
        self.phone = phone
        self.password = password
        self.phoneVerifiedAt = phoneVerifiedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
