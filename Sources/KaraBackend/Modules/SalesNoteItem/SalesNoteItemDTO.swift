import Vapor
import Fluent

struct CreateSalesNoteItemDTO: Content {
    let salesNoteId: UUID
    let name: String
    let quantity: Int
    let unitPrice: Int
}

struct SalesNoteItemResponseDTO: Content {
    let id: UUID
    let salesNoteId: UUID
    let name: String
    let quantity: Int
    let unitPrice: Int
    let subtotal: Int
    
    init(salesNoteItem: SalesNoteItem) throws {
        guard let id = salesNoteItem.id else {
            throw Abort(.internalServerError, reason: "Sales Note Item ID is missing")
        }
        
        self.id = id
        self.salesNoteId = salesNoteItem.$salesNote.id
        self.name = salesNoteItem.name
        self.quantity = salesNoteItem.quantity
        self.unitPrice = salesNoteItem.unitPrice
        self.subtotal = salesNoteItem.subtotal
    }
}
