import Fluent
import Vapor

protocol SalesNoteServiceProtocol: Sendable {
    func create(_ dto: CreateSalesNoteDTO, on db: any Database) async throws -> SalesNoteResponseDTO
    func findAllByShop(_ shopId: UUID, on db: any Database) async throws -> [SalesNoteResponseDTO]
    func findByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws -> SalesNoteResponseDTO?
    func findByShopAndIdentifier(_ shopId: UUID, identifier: String, on db: any Database) async throws -> SalesNoteResponseDTO?
    func softDeleteByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws
}

struct SalesNoteService: SalesNoteServiceProtocol, Sendable {
    let salesNoteRepository: any SalesNoteRepositoryProtocol
    
    func create(_ data: CreateSalesNoteDTO, on db: any Database) async throws -> SalesNoteResponseDTO {
        try await db.transaction { tx in
            let status = status(totalAmount: data.totalAmount, paidAmount: data.paidAmount)
            
            let salesNote = try await salesNoteRepository.create(
                shopId: data.shopId,
                customerName: data.customerName,
                customerPhone: data.customerPhone,
                totalAmount: data.totalAmount,
                paidAmount: data.paidAmount,
                status: status,
                noteFileLink: data.noteFileLink,
                dueAt: data.dueAt,
                soldAt: data.soldAt,
                createdBy: data.createdBy,
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
    
    func softDeleteByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws {
        return try await salesNoteRepository.softDeleteByIdAndShop(id, shopId: shopId, on: db)
    }
    
    private func status(totalAmount: Int, paidAmount: Int) -> Status {
        if paidAmount == totalAmount {
            return .paid
        } else if paidAmount == 0 {
            return .notPaid
        } else {
            return .dpPaid
        }
    }
}
