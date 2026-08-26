import Fluent
import Foundation

final class SalesNoteItem: Model, @unchecked Sendable {
    static let schema = "sales_note_items"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "sales_note_id")
    var salesNote: SalesNote
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "quantity")
    var quantity: Int
    
    @Field(key: "unit_price")
    var unitPrice: Int
    
    @Field(key: "subtotal")
    var subtotal: Int
    
    init() {
        
    }
    
    init(id: UUID? = nil, salesNoteId: UUID, name: String, quantity: Int, unitPrice: Int, subtotal: Int) {
        self.id = id
        self.$salesNote.id = salesNoteId
        self.name = name
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.subtotal = subtotal
    }
}
