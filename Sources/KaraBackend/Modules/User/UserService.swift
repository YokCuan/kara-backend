import Fluent
import Vapor

protocol UserServiceProtocol: Sendable {
    func create(_ dto: CreateUserDTO, on db: any Database) async throws -> User
    func findAll(on db: any Database) async throws -> [UserResponseDTO]
    func findById(_ id: UUID, on db: any Database) async throws -> UserResponseDTO?
    func findByPhone(_ phone: String, on db: any Database) async throws -> User?
}

struct UserService: UserServiceProtocol, Sendable {
    let userRepository: any UserRepositoryProtocol
    
    func create(_ data: CreateUserDTO, on db: any Database) async throws -> User {
        guard !data.name.isEmpty else {
            throw Abort(.badRequest, reason: "Name cannot be empty")
        }
        
        let user = try await userRepository.create(
            name: data.name,
            phone: data.phone,
            password: data.password,
            on: db
        )
        
        return user
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
    
    func findByPhone(_ phone: String, on db: any Database) async throws -> User? {
        return try await userRepository.findByPhone(phone, on: db) 
    }
}
