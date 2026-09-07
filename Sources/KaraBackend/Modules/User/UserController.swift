import Vapor
import Fluent

struct UserController: RouteCollection {
    let userService: any UserServiceProtocol
    
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        
        users.get(use: findAll)
        users.get(":id", use: findById)
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
}
