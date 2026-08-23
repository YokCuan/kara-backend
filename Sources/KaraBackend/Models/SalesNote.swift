import Fluent
import Vapor

enum Status: String, Codable, CaseIterable {
    case paid
    case dp
    case notPaid
}

final class SalesNote: Model, Content, @unchecked Sendable {
    static let schema = "sales_notes"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "shop_id")
    var shop: Shop
    
    @Field(key: "identifier")
    var identifier: String
    
    @Field(key: "customer_name")
    var customerName: String
    
    @OptionalField(key: "customer_phone")
    var customerPhone: String?
    
    @Field(key: "total_amount")
    var totalAmount: Int
    
    @Field(key: "paid_amount")
    var paidAmount: Int
    
    @Enum(key: "status")
    var status: Status
    
    @OptionalField(key: "note_file_link")
    var noteFileLink: String?
    
    @Field(key: "due_at")
    var dueAt: Date?
    
    @Field(key: "sold_at")
    var soldAt: Date?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var deletedAt: Date?
    
    @Field(key: "created_by")
    var createdBy: String
    
    @Field(key: "updated_by")
    var updatedBy: String
    
    @Field(key: "is_deleted")
    var isDeleted: Bool
    
    @Children(for: \.$salesNote)
    var salesNoteItem: [SalesNoteItem]
    
    init() {
        
    }
    
    init(id: UUID? = nil, shopId: UUID, identifier: String, customerName: String, customerPhone: String?, totalAmount: Int, paidAmount: Int, status: Status, noteFileLink: String?, dueAt: Date?, soldAt: Date?, createdAt: Date?, updatedAt: Date?, createdBy: String, updatedBy: String, isDeleted: Bool = false){
        self.id = id
        self.$shop.id = shopId
        self.identifier = identifier
        self.customerName = customerName
        self.customerPhone = customerPhone
        self.totalAmount = totalAmount
        self.paidAmount = paidAmount
        self.status = status
        self.noteFileLink = noteFileLink
        self.dueAt = dueAt
        self.soldAt = soldAt
        self.createdAt = createdAt
        self.updatedBy = updatedBy
        self.createdBy = createdBy
        self.isDeleted = isDeleted
    }
}
