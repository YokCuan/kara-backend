import Fluent
import Vapor
import SQLKit

protocol ShopRepositoryProtocol: Sendable {
    func create(ownerId: UUID, name: String, description: String?, address: String?, phone: String?, on db: any Database) async throws -> Shop
    func findAll(on db: any Database) async throws -> [Shop]
    func findById(_ id: UUID, on db: any Database) async throws -> Shop?
    func findByOwner(_ ownerId: UUID, on db: any Database) async throws -> Shop?
    func findByName(_ name: String, on db: any Database) async throws -> Shop?
}

struct ShopRepository: ShopRepositoryProtocol, Sendable {
    func create(ownerId: UUID, name: String, description: String?, address: String?, phone: String?, on db: any Database) async throws -> Shop {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let id = UUID()
        
        let newShop = try await sql.raw("""
            INSERT INTO shops
            (id, owner_id, name, description, address, phone)
            VALUES (\(bind: id), \(bind: ownerId), \(bind: name), \(bind: description), \(bind: address), \(bind: phone))
            RETURNING id, owner_id, name, description, address, phone
        """).first(decoding: ShopRow.self)
        
        guard let newShop else {
            throw Abort(.internalServerError, reason: "Failed to create shop")
        }
        
        return newShop.shop
    }
    
    func findAll(on db: any Database) async throws -> [Shop] {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let allShops = try await sql.raw("""
            SELECT
                id, owner_id, name, description, address, phone
            FROM shops
            """).all(decoding: ShopRow.self)
        
        return allShops.map(\.shop)
    }
    
    func findById(_ id: UUID, on db: any Database) async throws -> Shop? {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let shop = try await sql.raw("""
            SELECT
                id, owner_id, name, description, address, phone
            FROM shops
            WHERE id = \(bind: id)
            """).first(decoding: ShopRow.self)
        
        return shop?.shop
    }
    
    func findByOwner(_ ownerId: UUID, on db: any Database) async throws -> Shop? {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let shop = try await sql.raw("""
            SELECT
                id, owner_id, name, description, address, phone
            FROM shops
            WHERE owner_id = \(bind: ownerId)
            """).first(decoding: ShopRow.self)
        
        return shop?.shop
    }
    
    func findByName(_ name: String, on db: any Database) async throws -> Shop? {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let shop = try await sql.raw("""
            SELECT
                id, owner_id, name, description, address, phone
            FROM shops
            WHERE name = \(bind: name)
            """).first(decoding: ShopRow.self)
        
        return shop?.shop
    }
}

private struct ShopRow: Decodable {
    let id: UUID
    let ownerId: UUID
    let name: String
    let description: String?
    let address: String?
    let phone: String?
    
    var shop: Shop {
        Shop(
            id: id,
            ownerId: ownerId,
            name: name,
            description: description,
            address: address,
            phone: phone
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case ownerId = "owner_id"
        case name
        case description
        case address
        case phone
    }
}
