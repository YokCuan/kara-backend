import Fluent
import Vapor

protocol SalesNoteServiceProtocol: Sendable {
    func create(_ data: CreateSalesNoteDTO, on db: any Database) async throws -> SalesNoteResponseDTO
    func addSalesNotePaidAmount(_ id: UUID, shopId: UUID, data: AddSalesNotePaymentDTO, on db: any Database) async throws -> SalesNoteResponseDTO
    func findAllByShop(_ shopId: UUID, on db: any Database) async throws -> [SalesNoteResponseDTO]
    func findByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws -> SalesNoteResponseDTO?
    func findByShopAndIdentifier(_ shopId: UUID, identifier: String, on db: any Database) async throws -> SalesNoteResponseDTO?
    func findAllCustomersByShop(_ shopId: UUID, on db: any Database) async throws -> [CustomerResponseDTO]
    func softDeleteByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws
}

struct SalesNoteService: SalesNoteServiceProtocol, Sendable {
    let salesNoteRepository: any SalesNoteRepositoryProtocol
    
    func create(_ data: CreateSalesNoteDTO, on db: any Database) async throws -> SalesNoteResponseDTO {
        try await db.transaction { tx in
            let status = paymentStatus(totalAmount: data.totalAmount, paidAmount: data.paidAmount)
            let dueAt = data.dueAt ?? nil
            let salesNote = try await salesNoteRepository.create(
                shopId: data.shopId,
                customerName: data.customerName,
                customerPhone: data.customerPhone,
                totalAmount: data.totalAmount,
                paidAmount: data.paidAmount,
                status: status,
                noteFileLink: data.noteFileLink,
                dueAt: dueAt,
                soldAt: data.soldAt ?? Date(),
                createdBy: data.createdBy,
                updatedBy: data.updatedBy,
                on: tx
            )
            
            return try SalesNoteResponseDTO(salesNote: salesNote)
        }
    }
    
    func addSalesNotePaidAmount(_ id: UUID, shopId: UUID, data: AddSalesNotePaymentDTO, on db: any Database) async throws -> SalesNoteResponseDTO {
        try await db.transaction { tx in
            guard let existingSalesNote = try await salesNoteRepository.findByIdAndShop(id, shopId: shopId, on: tx) else {
                throw Abort(.notFound, reason: "Sales note not found")
            }
            guard data.paidAmount >= 0 else {
                throw Abort(.badRequest, reason: "Paid amount cannot be negative")
            }

            guard data.paidAmount <= existingSalesNote.totalAmount else {
                throw Abort(.badRequest, reason: "Paid amount cannot exceed total amount")
            }
            let newPaidAmount = existingSalesNote.paidAmount + data.paidAmount
            let status = paymentStatus(totalAmount: existingSalesNote.totalAmount, paidAmount: newPaidAmount)
            
            let salesNote = try await salesNoteRepository.updatePaidAmount(
                id,
                shopId: shopId,
                paidAmount: newPaidAmount,
                status: status,
                updatedBy: data.updatedBy,
                on: tx
            )
            
            return try SalesNoteResponseDTO(salesNote: salesNote)
        }
    }
    
    func findAllByShop(_ shopId: UUID, on db: any Database) async throws -> [SalesNoteResponseDTO] {
        let salesNotes = try await salesNoteRepository.findAllByShop(shopId, on: db)
        return try salesNotes.map { salesNote in
            try SalesNoteResponseDTO(salesNote: salesNote)
        }
    }
    
    func findByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws -> SalesNoteResponseDTO? {
        guard let salesNote = try await salesNoteRepository.findByIdAndShop(id, shopId: shopId, on: db) else {
            return nil
        }
        return try SalesNoteResponseDTO(salesNote: salesNote)
    }
    
    func findByShopAndIdentifier(_ shopId: UUID, identifier: String, on db: any Database) async throws -> SalesNoteResponseDTO? {
        guard let salesNote = try await salesNoteRepository.findByShopAndIdentifier(shopId, identifier: identifier, on: db) else {
            return nil
        }
        return try SalesNoteResponseDTO(salesNote: salesNote)
    }
    
    func findAllCustomersByShop(_ shopId: UUID, on db: any Database) async throws -> [CustomerResponseDTO] {
        let customers = try await salesNoteRepository.findAllCustomersByShop(
            shopId,
            on: db
        )

        return customers.map {
            CustomerResponseDTO(
                customerName: $0.customerName,
                customerPhone: $0.customerPhone,
                salesNoteCount: $0.salesNoteCount,
                lastSoldAt: $0.lastSoldAt
            )
        }
    }
    
    func softDeleteByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws {
        return try await salesNoteRepository.softDeleteByIdAndShop(id, shopId: shopId, on: db)
    }
    
    private func paymentStatus(totalAmount: Int, paidAmount: Int) -> Status {
        if paidAmount == totalAmount {
            return .paid
        } else if paidAmount == 0 {
            return .notPaid
        } else {
            return .dpPaid
        }
    }
}
