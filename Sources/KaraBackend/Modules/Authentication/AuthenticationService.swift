import Fluent
import Vapor

protocol AuthenticationServiceProtocol {
    func registerWithPassword(_ dto: RegisterWithPasswordDTO, on db: any Database) async throws -> AuthenticationResponseDTO
    func loginWithPassword(_ dto: LoginWithPasswordDTO, on db: any Database) async throws -> AuthenticationResponseDTO
    func logout(rawToken: String, on db: any Database) async throws
}

struct AuthenticationService: AuthenticationServiceProtocol {
    let userService: any UserServiceProtocol
    let shopService: any ShopServiceProtocol
    let authTokenService: any AuthTokenServiceProtocol
    
    func registerWithPassword(_ dto: RegisterWithPasswordDTO, on db: any Database) async throws -> AuthenticationResponseDTO {
        let userService = self.userService
        let shopService = self.shopService
        
        let phone = try indonesianPhoneFormatter(dto.phone)
        
        guard try await userService.findByPhone(phone, on: db) == nil else {
            throw Abort(.conflict, reason: "Phone number is already registered")
        }
        let passwordHash = try Bcrypt.hash(dto.password)
        
        return try await db.transaction { tx in
            let user = try await userService.create(
                CreateUserDTO(
                    name: dto.name,
                    phone: phone,
                    password: passwordHash
                ),
                on: tx
            )
            
            guard let userId = user.id else {
                throw Abort(.internalServerError, reason: "User ID is missing")
            }
            
            let shop = try await shopService.create(
                CreateShopDTO(
                    ownerId: userId,
                    name: dto.shopName,
                    description: dto.shopDescription,
                    address: dto.shopAddress,
                    phone: dto.shopPhone
                ),
                on: tx
            )
            
            let token = try await authTokenService.issue(
                userId: userId,
                deviceName: dto.deviceName,
                on: tx
            )
            
            return AuthenticationResponseDTO(
                accessToken: token.rawToken,
                expiresAt: token.expiresAt,
                user: try makeAuthUserResponse(user),
                shop: shop
            )
        }
    }
    
    func loginWithPassword(_ dto: LoginWithPasswordDTO, on db: any Database) async throws -> AuthenticationResponseDTO {
        let phone = try indonesianPhoneFormatter(dto.phone)
        
        guard let user = try await userService.findByPhone(phone, on: db),
              let passwordHash = user.password,
              try Bcrypt.verify(dto.password, created: passwordHash)
        else {
            throw Abort(.internalServerError, reason: "Invalid phone number or password")
        }
        
        guard let userId = user.id else {
            throw Abort(.notFound, reason: "User ID not found")
        }

        let token = try await authTokenService.issue(
            userId: userId,
            deviceName: dto.deviceName,
            on: db
        )

        let shop = try await shopService.findByOwner(
            userId,
            on: db
        )

        return AuthenticationResponseDTO(
            accessToken: token.rawToken,
            expiresAt: token.expiresAt,
            user: try makeAuthUserResponse(user),
            shop: shop
        )
    }
    
    func logout(rawToken: String, on db: any Database) async throws {
        try await authTokenService.revoke(
            rawToken: rawToken,
            on: db
        )
    }
}

private func makeAuthUserResponse(
    _ user: User
) throws -> AuthUserResponseDTO {
    guard let id = user.id else {
        throw Abort(
            .internalServerError,
            reason: "User ID is missing"
        )
    }

    return AuthUserResponseDTO(
        id: id,
        name: user.name,
        phone: user.phone,
        phoneVerifiedAt: user.phoneVerifiedAt,
        hasPassword: user.password != nil
    )
}
