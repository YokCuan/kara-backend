import Fluent
import Vapor

protocol SalesNoteItemServiceProtocol: Sendable {
    func create(_ dto: CreateSalesNoteItemDTO, on db: any Database) async throws -> SalesNoteItemResponseDTO
    func findAllBySalesNote(_ salesNoteId: UUID, on db: any Database) async throws -> [SalesNoteItemResponseDTO]
    func deleteBySalesNote(_ salesNoteId: UUID, on db: any Database) async throws
    func deleteById(_ id: UUID, on db: any Database) async throws
}

struct SalesNoteItemService: SalesNoteItemServiceProtocol, Sendable {
    let salesNoteItemRepository: any SalesNoteItemRepositoryProtocol
    
    func create(_ data: CreateSalesNoteItemDTO, on db: any Database) async throws -> SalesNoteItemResponseDTO {
        let salesNoteItem = try await salesNoteItemRepository.create(
            salesNoteId: data.salesNoteId,
            name: data.name,
            quantity: data.quantity,
            unitPrice: data.unitPrice,
            on: db
        )
        
        return try SalesNoteItemResponseDTO(salesNoteItem: salesNoteItem)
    }
    
    func findAllBySalesNote(_ salesNoteId: UUID, on db: any Database) async throws -> [SalesNoteItemResponseDTO] {
        let salesNoteItems = try await salesNoteItemRepository.findAllBySalesNote(salesNoteId, on: db)
        return try salesNoteItems.map{salesNoteItem in
            try SalesNoteItemResponseDTO(salesNoteItem: salesNoteItem)
        }
    }
    
    func deleteBySalesNote(_ salesNoteId: UUID, on db: any Database) async throws {
        try await salesNoteItemRepository.deleteBySalesNote(salesNoteId, on: db)
    }
    
    func deleteById(_ id: UUID, on db: any Database) async throws {
        try await salesNoteItemRepository.deleteById(id, on: db)
    }
}
