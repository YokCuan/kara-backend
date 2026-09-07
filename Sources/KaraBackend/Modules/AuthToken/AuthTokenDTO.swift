import Vapor
import Fluent

struct CreateAuthTokenDTO: Content {
    let userId: UUID
    let tokenHash: String
    let expiresAt: Date?
    let createdAt: Date?
    let revokedAt: Date?
    let deviceName: String?
}

struct AuthTokenResponseDTO: Content {
    let id: UUID
    let userId: UUID
    let tokenHash: String
    let expiresAt: Date?
    let createdAt: Date?
    let revokedAt: Date?
    let deviceName: String?
    
    init(authToken: AuthToken) throws {
        guard let id = authToken.id else {
            throw Abort(.internalServerError, reason: "Auth Token ID is missing")
        }
        
        self.id = id
        self.userId = authToken.$user.id
        self.tokenHash = authToken.tokenHash
        self.expiresAt = authToken.expiresAt
        self.createdAt = authToken.createdAt
        self.revokedAt = authToken.revokedAt
        self.deviceName = authToken.deviceName
    }
}

struct AuthTokenRow: Decodable {
    let id: UUID
    let userId: UUID
    let tokenHash: String
    let expiresAt: Date
    let createdAt: Date
    let revokedAt: Date
    let deviceName: String
    
    var authToken: AuthToken {
        AuthToken(id: id, userId: userId, tokenHash: tokenHash, expiresAt: expiresAt, createdAt: createdAt, revokedAt: revokedAt, deviceName: deviceName)
    }
}
