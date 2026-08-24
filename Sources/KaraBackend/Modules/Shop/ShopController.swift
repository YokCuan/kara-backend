import Vapor
import Fluent

struct ShopController: RouteCollection {
    let shopService: any ShopServiceProtocol
    func boot(routes: RoutesBuilder) throws {
        let shops = routes.grouped("shops")
        
        shops.post(use: create)
        shops.get(use: findAll)
        shops.get(":id", use: findById)
        shops.get(":ownerId", use: findByOwner)
        shops.post("find-by-name", use: findByName)
    }
    
    func create(req: Request) async throws -> ShopResponseDTO {
        let data = try req.content.decode(CreateShopDTO.self)
        return try await shopService.create(data, on: req.db)
    }
    
    func findAll(req: Request) async throws -> [ShopResponseDTO] {
        return try await shopService.findAll(on: req.db)
    }
    
    func findById(req: Request) async throws -> ShopResponseDTO {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shop ID")
        }
        
        guard let shop = try await shopService.findById(id, on: req.db) else {
            throw Abort(.notFound, reason: "Shop not found")
        }
        
        return shop
    }
    
    func findByOwner(req: Request) async throws -> ShopResponseDTO {
        guard let ownerId = req.parameters.get("ownerId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shop ID")
        }
        
        guard let shop = try await shopService.findByOwner(ownerId, on: req.db) else {
            throw Abort(.notFound, reason: "Shop not found")
        }
        
        return shop
    }
    
    func findByName(req: Request) async throws -> ShopResponseDTO {
        let body = try req.content.decode(FindByNameDTO.self)
        
        guard let shop = try await shopService.findByName(body.name, on: req.db) else {
            throw Abort(.notFound, reason: "Shop not found")
        }
        
        return shop
    }
}
