import Fluent
import Foundation

final class AuthToken: Model, @unchecked Sendable {
    static let schema = "auth_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    
    var userId: UUID {
        self.$user.id
    }
    
    @Field(key: "token_hash")
    var tokenHash: String
    
    @Field(key: "expires_at")
    var expiresAt: Date?
    
    @Timestamp(key: "created_at", on: .update)
    var createdAt: Date?
    
    @Field(key: "revoked_at")
    var revokedAt: Date?
    
    @OptionalField(key: "device_name")
    var deviceName: String?
    
    init() {
        
    }
    
    init(id: UUID? = nil, userId: UUID, tokenHash: String, expiresAt: Date?, createdAt: Date, revokedAt: Date, deviceName: String?) {
        self.id = id
        self.$user.id = userId
        self.tokenHash = tokenHash
        self.expiresAt = expiresAt
        self.createdAt = createdAt
        self.revokedAt = revokedAt
        self.deviceName = deviceName
    }
}
