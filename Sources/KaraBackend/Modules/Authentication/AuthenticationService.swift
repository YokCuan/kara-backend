import Fluent
import Vapor

protocol AuthenticationServiceProtocol {
    func register(_ dto: RegisterDTO, on db: any Database) async throws -> RegisterResponseDTO
    func login(_ dto: LoginDTO, on db: any Database) async throws -> UserResponseDTO
}

struct AuthenticationService: AuthenticationServiceProtocol {
    let userService: any UserServiceProtocol
    let shopService: any ShopServiceProtocol

    func register(_ dto: RegisterDTO, on db: any Database) async throws -> RegisterResponseDTO {
        let userService = self.userService
        let shopService = self.shopService

        return try await db.transaction { tx in
            let user = try await userService.create(
                CreateUserDTO(
                    name: dto.name,
                    phone: dto.phone,
                    password: dto.password
                ),
                on: tx
            )

            let shop = try await shopService.create(
                CreateShopDTO(
                    ownerId: user.id,
                    name: dto.shopName,
                    address: dto.shopAddress,
                    phone: dto.shopPhone
                ),
                on: tx
            )

            return RegisterResponseDTO(
                user: user,
                shop: shop
            )
        }
    }

    func login(_ dto: LoginDTO, on db: any Database) async throws -> UserResponseDTO {
        guard let user = try await userService.findByPhone(dto.phone, on: db) else {
            throw Abort(.unauthorized, reason: "Invalid phone number")
        }

        return user
    }
}
