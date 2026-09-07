import Vapor
import Fluent

extension User: Authenticatable {}

struct AuthTokenAuthenticator: AsyncBearerAuthenticator {
    let authTokenService: any AuthTokenServiceProtocol
    let userRepository: any UserRepositoryProtocol

    func authenticate(
        bearer: BearerAuthorization,
        for request: Request
    ) async throws {
        guard let token = try await authTokenService.findActive(
            rawToken: bearer.token,
            on: request.db
        ) else {
            return
        }

        guard let user = try await userRepository.findById(
            token.userId,
            on: request.db
        ) else {
            return
        }

        request.auth.login(user)
    }
}
