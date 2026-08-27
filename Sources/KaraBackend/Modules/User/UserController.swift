import Vapor
import Fluent

struct UserController: RouteCollection {
    let userService: any UserServiceProtocol
    
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        
        users.post(use: create)
        users.get(use: findAll)
        users.get(":id", use: findById)
        users.post("find-by-phone", use: findByPhone)
    }
    
    func create(req: Request) async throws -> UserResponseDTO {
        let data = try req.content.decode(CreateUserDTO.self)
        return try await userService.create(data, on: req.db)
    }
    
    func findAll(req: Request) async throws -> [UserResponseDTO] {
        return try await userService.findAll(on: req.db)
    }
    
    func findById(req: Request) async throws -> UserResponseDTO {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }
        
        guard let user = try await userService.findById(id, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        return user
    }
    
    func findByPhone(req: Request) async throws -> UserResponseDTO {
        let body = try req.content.decode(FindByPhoneDTO.self)
        
        guard let user = try await userService.findByPhone(body.phone, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        return user
    }
}
