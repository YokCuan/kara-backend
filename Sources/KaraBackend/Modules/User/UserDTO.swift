import Vapor

struct APIResponseDTO<T: Content>: Content {
    let status: String
    let message: String
    let data: T?
}

struct CreateUserDTO: Content {
    let name: String
    let phone: String
    let password: String?
}

struct UserResponseDTO: Content {
    let id: UUID
    let name: String
    let phone: String
    let password: String?
    let phoneVerifiedAt: Date?
    let createdAt: Date?
    let updatedAt: Date?
    
    init(user: User) throws {
        guard let id = user.id else {
            throw Abort(.internalServerError, reason: "User ID is missing")
        }
        
        self.id = id
        self.name = user.name
        self.phone = user.phone
        self.password = user.password
        self.phoneVerifiedAt = user.phoneVerifiedAt
        self.createdAt = user.createdAt
        self.updatedAt = user.updatedAt
    }
}

struct FindByPhoneDTO: Content {
    let phone: String
}

struct UserRow: Decodable {
    let id: UUID
    let name: String
    let phone: String
    let password: String?
    let phoneVerifiedAt: Date?
    let createdAt: Date?
    let updatedAt: Date?
    
    var user: User {
        User(id: id, name: name, phone: phone, password: password, phoneVerifiedAt: phoneVerifiedAt, createdAt: createdAt, updatedAt: updatedAt)
    }
}
