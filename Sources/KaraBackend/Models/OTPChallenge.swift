import Fluent
import Foundation

final class OTPChallenge: Model, @unchecked Sendable {
    static let schema = "otp_challenges"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "phone")
    var phone: String
    
    @Field(key: "code_hash")
    var codeHash: String
    
    @Field(key: "purpose")
    var purpose: String
    
    @Field(key: "expires_at")
    var expiresAt: Date?
    
    @Field(key: "attempt_count")
    var attemptCount: Int
    
    @OptionalField(key: "consumed_at")
    var consumedAt: Date?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Field(key: "last_sent_at")
    var lastSentAt: Date?
    
    init() {
        
    }
    
    init(id: UUID? = nil, phone: String, codeHash: String, purpose: String, expiresAt: Date, attemptCount: Int, consumedAt: Date?, createdAt: Date,  lastSentAt: Date) {
        self.id = id
        self.phone = phone
        self.codeHash = codeHash
        self.purpose = purpose
        self.expiresAt = expiresAt
        self.attemptCount = attemptCount
        self.consumedAt = consumedAt
        self.createdAt = createdAt
        self.lastSentAt = lastSentAt
    }
}
