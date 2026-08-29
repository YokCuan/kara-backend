import Vapor
import Fluent

struct CreateSalesNoteDTO: Content {
    let shopId: UUID
    let customerName: String
    let customerPhone: String?
    let totalAmount: Int
    let paidAmount: Int
    let noteFileLink: String?
    let dueAt: Date?
    let soldAt: Date?
    let createdBy: String
    let updatedBy: String
}

struct AddSalesNotePaymentDTO: Content {
    let paidAmount: Int
    let updatedBy: String
}

struct SalesNoteResponseDTO: Content {
    let id: UUID
    let shopId: UUID
    let identifier: String
    let customerName: String
    let customerPhone: String?
    let totalAmount: Int
    let paidAmount: Int
    let status: Status
    let noteFileLink: String?
    let dueAt: Date?
    let soldAt: Date
    let createdAt: Date?
    let updatedAt: Date?
    let createdBy: String
    let updatedBy: String
    let isDeleted: Bool
    
    init(salesNote: SalesNote) throws {
        guard let id = salesNote.id else {
            throw Abort(.internalServerError, reason: "Sales Note ID is missing")
        }
        
        self.id = id
        self.shopId = salesNote.$shop.id
        self.identifier = salesNote.identifier
        self.customerName = salesNote.customerName
        self.customerPhone = salesNote.customerPhone
        self.totalAmount = salesNote.totalAmount
        self.paidAmount = salesNote.paidAmount
        self.status = salesNote.status
        self.noteFileLink = salesNote.noteFileLink
        self.dueAt = salesNote.dueAt
        self.soldAt = salesNote.soldAt
        self.createdAt = salesNote.createdAt
        self.updatedAt = salesNote.updatedAt
        self.createdBy = salesNote.createdBy
        self.updatedBy = salesNote.updatedBy
        self.isDeleted = salesNote.isDeleted
    }
}

struct SalesNoteByShopAndIdentifierDTO: Content {
    let shopId: UUID
    let identifier: String?
}

struct SalesNoteByIdAndShopDTO: Content {
    //    let id: UUID --- get from req.query instead
    let shopId: UUID
}

struct SalesNoteByShopAndCustomerNameDTO: Content {
    let shopId: UUID
    let customerName: String?
}
