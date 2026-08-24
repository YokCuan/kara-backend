import Vapor
import Fluent

struct CreateShopDTO: Content {
    let ownerId: UUID
    let name: String
    let address: String?
    let phone: String?
}

struct ShopResponseDTO: Content {
    let id: UUID
    let ownerId: UUID
    let name: String
    let address: String?
    let phone: String?
    
    init(shop: Shop) throws {
        guard let id = shop.id else {
            throw Abort(.internalServerError, reason: "Shop ID is missing")
        }
        
        self.id = id
        self.ownerId = shop.$owner.id
        self.name = shop.name
        self.address = shop.address
        self.phone = shop.phone
    }
}

struct FindByNameDTO: Content {
    let name: String
}
