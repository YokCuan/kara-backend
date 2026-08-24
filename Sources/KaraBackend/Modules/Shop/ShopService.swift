import Fluent
import Vapor

protocol ShopServiceProtocol: Sendable {
    func create(_ dto: CreateShopDTO, on db: any Database) async throws -> ShopResponseDTO
    func findAll(on db: any Database) async throws -> [ShopResponseDTO]
    func findById(_ id: UUID, on db: any Database) async throws -> ShopResponseDTO?
    func findByOwner(_ ownerId: UUID, on db: any Database) async throws -> ShopResponseDTO?
    func findByName(_ name: String, on db: any Database) async throws -> ShopResponseDTO?
}

struct ShopService: ShopServiceProtocol, Sendable {
    let shopRepository: any ShopRepositoryProtocol
    
    func create(_ data: CreateShopDTO, on db: any Database) async throws -> ShopResponseDTO {
        guard !data.name.isEmpty else {
            throw Abort(.badRequest, reason: "Name cannot be empty")
        }
        
        let shop = try await shopRepository.create(
            ownerId: data.ownerId,
            name: data.name,
            address: data.address,
            phone: data.phone,
            on: db
        )
        
        return try ShopResponseDTO(shop: shop)
    }
    
    func findAll(on db: any Database) async throws -> [ShopResponseDTO] {
        let shops = try await shopRepository.findAll(on: db)
        return try shops.map(ShopResponseDTO.init(shop:))
    }
    
    func findById(_ id: UUID, on db: any Database) async throws -> ShopResponseDTO? {
        guard let shop = try await shopRepository.findById(id, on: db) else {
            return nil
        }
        return try ShopResponseDTO(shop: shop)
    }
    
    func findByOwner(_ ownerId: UUID, on db: any Database) async throws -> ShopResponseDTO? {
        guard let shop = try await shopRepository.findByOwner(ownerId, on: db) else {
            return nil
        }
        return try ShopResponseDTO(shop: shop)
    }
    
    func findByName(_ name: String, on db: any Database) async throws -> ShopResponseDTO? {
        guard let shop = try await shopRepository.findByName(name, on: db) else {
            return nil
        }
        return try ShopResponseDTO(shop: shop)
    }
}
