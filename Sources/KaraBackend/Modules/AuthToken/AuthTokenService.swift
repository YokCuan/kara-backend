import Crypto
import Fluent
import Foundation
import Vapor

protocol AuthTokenServiceProtocol: Sendable {
    func issue(userId: UUID, deviceName: String?, on db: any Database) async throws -> IssuedAuthToken
    func findActive(rawToken: String, on db: any Database) async throws -> AuthToken?
    func revoke(rawToken: String, on db: any Database) async throws
}

struct IssuedAuthToken: Sendable {
    let rawToken: String
    let expiresAt: Date
}

struct AuthTokenService: AuthTokenServiceProtocol, Sendable {
    let authTokenRepository: any AuthTokenRepositoryProtocol
    
    private let tokenLifetime: TimeInterval = 60 * 60 * 24 * 30
    
    func issue(userId: UUID, deviceName: String? = nil, on db: any Database) async throws -> IssuedAuthToken {
        let rawToken = try AuthTokenGenerator.generate()
        let tokenHash = AuthTokenGenerator.hash(rawToken)
        
        let now = Date()
        let expiresAt = now.addingTimeInterval(tokenLifetime)
        
        try await authTokenRepository.create(
            userId,
            tokenHash: tokenHash,
            expiresAt: expiresAt,
            deviceName: deviceName,
            on: db
        )
        
        return IssuedAuthToken(
            rawToken: rawToken,
            expiresAt: expiresAt
        )
    }
    
    func findActive(rawToken: String,  on db: any Database) async throws -> AuthToken? {
        try await authTokenRepository.findActiveByHash(AuthTokenGenerator.hash(rawToken), on: db)
    }
    
    func revoke(rawToken: String, on db: any Database) async throws {
        try await authTokenRepository.revokeByHash(AuthTokenGenerator.hash(rawToken), revokedAt: Date(), on: db)
    }
    
    
}
