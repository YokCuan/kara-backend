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

struct UserResponseDTO: Content {
    let id: UUID
    let name: String
    let phone: String

    init(user: User) throws {
        guard let id = user.id else {
            throw Abort(.internalServerError, reason: "User ID is missing")
        }

        self.id = id
        self.name = user.name
        self.phone = user.phone
    }
}

struct FindByPhoneDTO: Content {
    let phone: String
}
