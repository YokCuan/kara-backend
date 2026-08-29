import Fluent
import Vapor

protocol CashflowSalesNoteServiceProtocol: Sendable {
    func create(_ dto: CreateCashflowSalesNoteDTO, on db: any Database) async throws -> CashflowSalesNoteResponseDTO
    func findAllByShop(_ shopId: UUID, on db: any Database) async throws -> [CashflowSalesNoteResponseDTO]
    func findByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws -> CashflowSalesNoteResponseDTO
    func softDelete(_ salesNoteId: UUID, shopId: UUID, on db: any Database) async throws
}

struct CashflowSalesNoteService: CashflowSalesNoteServiceProtocol, Sendable {
    let salesNoteRepository: any SalesNoteRepositoryProtocol
    let salesNoteItemRepository: any SalesNoteItemRepositoryProtocol
    
    func create(_ dto: CreateCashflowSalesNoteDTO, on db: any Database) async throws -> CashflowSalesNoteResponseDTO {
        guard !dto.items.isEmpty else {
            throw Abort(.badRequest, reason: "Sales Note must contain at least one item")
        }
        guard dto.items.allSatisfy({ !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            throw Abort(.badRequest, reason: "Sales Note item name cannot be empty")
        }
        
        let totalAmount = dto.items.reduce(0) { total, item in
            total + (item.quantity * item.unitPrice)
        }
        
        let dueAt = dto.dueAt ?? nil
        
        return try await db.transaction { tx in
            let status = status(totalAmount: totalAmount, paidAmount: dto.paidAmount)
            
            let salesNote = try await salesNoteRepository.create(
                shopId: dto.shopId,
                customerName: dto.customerName,
                customerPhone: dto.customerPhone,
                totalAmount: totalAmount,
                paidAmount: dto.paidAmount,
                status: status,
                noteFileLink: dto.noteFileLink,
                dueAt: dueAt,
                soldAt: dto.soldAt,
                createdBy: dto.createdBy,
                updatedBy: dto.updatedBy,
                on: tx
            )
            
            guard let salesNoteId = salesNote.id else {
                throw Abort(.internalServerError, reason: "Failed to create sales note")
            }
            
            var salesNoteItems: [SalesNoteItemResponseDTO] = []
            
            for item in dto.items {
                let createdItem = try await salesNoteItemRepository.create(
                    salesNoteId: salesNoteId,
                    name: item.name,
                    quantity: item.quantity,
                    unitPrice: item.unitPrice,
                    on: tx
                )
                salesNoteItems.append(try SalesNoteItemResponseDTO(salesNoteItem: createdItem))
            }
            
            return CashflowSalesNoteResponseDTO(
                salesNote: try SalesNoteResponseDTO(salesNote: salesNote),
                salesNoteItems: salesNoteItems
            )
        }
    }
    
    func findAllByShop(_ shopId: UUID, on db: any Database) async throws -> [CashflowSalesNoteResponseDTO] {
        let salesNotes = try await salesNoteRepository.findAllByShop(shopId, on: db)
        
        var results: [CashflowSalesNoteResponseDTO] = []
        
        for salesNote in salesNotes {
            guard let salesNoteId = salesNote.id else {
                throw Abort(.internalServerError, reason: "Sales Note ID is missing")
            }
            
            let salesNoteItems = try await salesNoteItemRepository.findAllBySalesNote(salesNoteId, on: db)
            
            let salesNoteItemDTOs = try salesNoteItems.map {
                try SalesNoteItemResponseDTO(salesNoteItem: $0)
            }
            
            results.append(
                CashflowSalesNoteResponseDTO(
                    salesNote: try SalesNoteResponseDTO(salesNote: salesNote),
                    salesNoteItems: salesNoteItemDTOs
                )
            )
        }
        
        return results
    }
    
    func findByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws -> CashflowSalesNoteResponseDTO {
        guard let salesNote = try await salesNoteRepository.findByIdAndShop(id, shopId: shopId, on: db) else {
            throw Abort(.notFound, reason: "Sales Note not found")
        }
        
        guard let salesNoteId = salesNote.id else {
            throw Abort(.internalServerError, reason: "Sales Note ID is missing")
        }
        
        let salesNoteItems = try await salesNoteItemRepository.findAllBySalesNote(salesNoteId, on: db)
        
        let salesNoteItemDTOs = try salesNoteItems.map {
            try SalesNoteItemResponseDTO(salesNoteItem: $0)
        }
        
        return CashflowSalesNoteResponseDTO(
            salesNote: try SalesNoteResponseDTO(salesNote: salesNote),
            salesNoteItems: salesNoteItemDTOs
        )
    }
    
    func softDelete(_ salesNoteId: UUID, shopId: UUID, on db: any Database) async throws {
        guard let _ = try await salesNoteRepository.findByIdAndShop(
            salesNoteId,
            shopId: shopId,
            on: db
        ) else {
            throw Abort(.notFound, reason: "Sales Note not found")
        }
        
        try await salesNoteRepository.softDeleteByIdAndShop(salesNoteId, shopId: shopId, on: db)
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
