import Vapor

struct RegisterWithPasswordDTO: Content {
    let name: String
    let phone: String
    let password: String
    let deviceName: String?
    let shopName: String
    let shopDescription: String?
    let shopAddress: String?
    let shopPhone: String?
}

struct LoginWithPasswordDTO: Content {
    let phone: String
    let password: String
    let deviceName: String?
}

struct AuthenticationResponseDTO: Content {
    let accessToken: String
    let expiresAt: Date
    let user: AuthUserResponseDTO
    let shop: ShopResponseDTO?
}

struct AuthUserResponseDTO: Content {
    let id: UUID
    let name: String
    let phone: String
    let phoneVerifiedAt: Date?
    let hasPassword: Bool
}
