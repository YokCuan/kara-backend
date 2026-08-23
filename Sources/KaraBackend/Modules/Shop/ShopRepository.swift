import Fluent
import Vapor
import SQLKit

protocol ShopRepositoryProtocol {
    func create(ownerId: UUID, name: String, address: String?, phone: String?, on db: any Database) async throws -> Shop
    func findAll(on db: any Database) async throws -> [Shop]
    func findById(_ id: UUID, on db: any Database) async throws -> Shop?
    func findByOwner(_ ownerId: UUID, on db: any Database) async throws -> Shop?
    func findByName(_ name: String, on db: any Database) async throws -> Shop?
}

struct ShopRepository: ShopRepositoryProtocol {
    func create(ownerId: UUID, name: String, address: String?, phone: String?, on db: any Database) async throws -> Shop {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let id = UUID()
        
        let newShop = try await sql.raw("""
            INSERT INTO shops
            (id, ownerId, name, address, phone)
            VALUES (\(bind: id),\(bind: ownerId),\(bind: name),\(bind: address),\(bind: phone))
            RETURNING id, ownerId, name, address, phone
        """).first(decoding: Shop.self)
        
        guard let newShop else {
            throw Abort(.internalServerError, reason: "Failed to create shop")
        }
        
        return newShop
    }
    
    func findAll(on db: any Database) async throws -> [Shop] {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let allShops = try await sql.raw("""
            SELECT 
                id, ownerId, name, address, phone
            FROM shops
            """).all(decoding: Shop.self)
        
        return allShops
    }
    
    
    func findById(_ id: UUID, on db: any Database) async throws -> Shop? {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let shop = try await sql.raw("""
            SELECT 
                id, ownerId, name, address, phone
            FROM shops
            WHERE id = \(bind: id)
            """).first(decoding: Shop.self)
        
        guard let shop else {
            return nil
        }
        
        return shop
    }
    
    func findByOwner(_ ownerId: UUID, on db: any Database) async throws -> Shop? {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let shop = try await sql.raw("""
            SELECT 
                id, ownerId, name, address, phone
            FROM shops
            WHERE ownerId = \(bind: ownerId)
            """).first(decoding: Shop.self)
        
        guard let shop else {
            return nil
        }
        
        return shop
    }
    
    func findByName(_ name: String, on db: any Database) async throws -> Shop? {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database connection error")
        }
        
        let shop = try await sql.raw("""
            SELECT 
                id, ownerId, name, address, phone
            FROM shops
            WHERE name = \(bind: name)
            """).first(decoding: Shop.self)
        
        guard let shop else {
            return nil
        }
        
        return shop
    }
}
