import Fluent
import Vapor

protocol UserServiceProtocol {
    func create(_ dto: CreateUserDTO, on db: any Database) async throws -> UserResponseDTO
    func findAll(on db: any Database) async throws -> [UserResponseDTO]
    func findById(_ id: UUID, on db: any Database) async throws -> UserResponseDTO?
    func findByPhone(_ phone: String, on db: any Database) async throws -> UserResponseDTO?
}

struct UserService: UserServiceProtocol {
    let userRepository: any UserRepositoryProtocol
    
    func create(_ data: CreateUserDTO, on db: any Database) async throws -> UserResponseDTO {
        guard !data.name.isEmpty else {
            throw Abort(.badRequest, reason: "Name cannot be empty")
        }
        
        let user = try await userRepository.create(
            name: data.name,
            phone: data.phone,
            password: data.password,
            on: db
        )
        
        return try UserResponseDTO(user: user)
    }
    
    func findAll(on db: any Database) async throws -> [UserResponseDTO] {
        let users = try await userRepository.findAll(on: db)
        return try users.map(UserResponseDTO.init(user:))
    }
    
    func findById(_ id: UUID, on db: any Database) async throws -> UserResponseDTO? {
        guard let user = try await userRepository.findById(id, on: db) else {
            return nil
        }
        return try UserResponseDTO(user: user)
    }
    
    func findByPhone(_ phone: String, on db: any Database) async throws -> UserResponseDTO? {
        guard let user = try await userRepository.findByPhone(phone, on: db) else {
            return nil
        }
        return try UserResponseDTO(user: user)
    }
}
