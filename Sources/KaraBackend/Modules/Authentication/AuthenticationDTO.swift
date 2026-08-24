import Vapor

struct RegisterDTO: Content {
    let name: String
    let phone: String
    let password: String?
    let shopName: String
    let shopAddress: String?
    let shopPhone: String?
}

struct LoginDTO: Content {
    let phone: String
    let password: String?
}

struct RegisterResponseDTO: Content {
    let user: UserResponseDTO
    let shop: ShopResponseDTO
}
