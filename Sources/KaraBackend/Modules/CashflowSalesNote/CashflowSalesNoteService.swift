import Fluent
import Vapor

protocol CashflowSalesNoteServiceProtocol: Sendable {
    func create(_ dto: CreateCashflowSalesNoteDTO, on db: any Database) async throws -> CashflowSalesNoteResponseDTO
    func updatePaidAmountAndStatus(_ id: UUID, shopId: UUID, dto: UpdateCashflowSalesNotePaidAmountAndStatusDTO, on db: any Database) async throws -> CashflowSalesNotePaymentsResponseDTO
    func findAllByShop(_ shopId: UUID, on db: any Database) async throws -> [CashflowSalesNoteResponseDTO]
    func findByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws -> CashflowSalesNoteResponseDTO
    func softDelete(_ salesNoteId: UUID, shopId: UUID, on db: any Database) async throws
}

struct CashflowSalesNoteService: CashflowSalesNoteServiceProtocol, Sendable {
    let salesNoteRepository: any SalesNoteRepositoryProtocol
    let salesNoteItemRepository: any SalesNoteItemRepositoryProtocol
    let salesNotePaymentRepository: any SalesNotePaymentRepositoryProtocol
    
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
            
            var salesNotePayments: [SalesNotePaymentResponseDTO] = []
            
            if dto.paidAmount > 0 {
                let payment = try await salesNotePaymentRepository.create(
                    salesNoteId: salesNoteId,
                    paymentAttempt: 1,
                    paidAmount: dto.paidAmount,
                    paidAt: dto.soldAt,
                    on: tx
                )
                
                salesNotePayments.append(
                    try SalesNotePaymentResponseDTO(salesNotePayment: payment)
                )
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
                salesNoteItems: salesNoteItems,
                salesNotePayments: salesNotePayments
            )
        }
    }
    
    func updatePaidAmountAndStatus(_ id: UUID, shopId: UUID, dto: UpdateCashflowSalesNotePaidAmountAndStatusDTO, on db: any Database) async throws -> CashflowSalesNotePaymentsResponseDTO {
        try await db.transaction { tx in
            guard let salesNote = try await salesNoteRepository.findByIdAndShop(
                id,
                shopId: shopId,
                on: tx
            ) else {
                throw Abort(.notFound, reason: "Sales Note ID not found")
            }
            
            guard dto.paidAmount > 0 else {
                throw Abort(.badRequest, reason: "Payment amount must be greater than zero")
            }
            
            let newPaidAmount = salesNote.paidAmount + dto.paidAmount
            
            guard newPaidAmount <= salesNote.totalAmount else {
                throw Abort(.badRequest, reason: "Payment exceeds the remaining balance")
            }
            
            let existingPayments = try await salesNotePaymentRepository.findAllBySalesNote(id, on: tx)
            
            let paymentAttempt = existingPayments.count + 1
            
            let payment = try await salesNotePaymentRepository.create(
                salesNoteId: id,
                paymentAttempt: paymentAttempt,
                paidAmount: dto.paidAmount,
                paidAt: dto.paidAt,
                on: tx
            )
            
            let newStatus = paymentStatus(totalAmount: salesNote.totalAmount,paidAmount: newPaidAmount)
            
            let updatedSalesNote = try await salesNoteRepository.updatePaidAmount(
                id,
                shopId: shopId,
                paidAmount: newPaidAmount,
                status: newStatus,
                updatedBy: salesNote.createdBy,
                on: tx
            )
            
            let allPayments = try await salesNotePaymentRepository.findAllBySalesNote(id, on: tx)
            
            let paymentDTOs = try allPayments.map {
                try SalesNotePaymentResponseDTO(salesNotePayment: $0)
            }
            
            return CashflowSalesNotePaymentsResponseDTO(
                salesNote: try SalesNoteResponseDTO(salesNote: updatedSalesNote),
                salesNotePayments: paymentDTOs
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
            
            let salesNotePayments = try await salesNotePaymentRepository.findAllBySalesNote(salesNoteId, on: db)
            
            let salesNotePaymentDTOs = try salesNotePayments.map {
                try SalesNotePaymentResponseDTO(salesNotePayment: $0)
            }
            
            results.append(
                CashflowSalesNoteResponseDTO(
                    salesNote: try SalesNoteResponseDTO(salesNote: salesNote),
                    salesNoteItems: salesNoteItemDTOs,
                    salesNotePayments: salesNotePaymentDTOs
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
        
        let salesNotePayments = try await salesNotePaymentRepository.findAllBySalesNote(salesNoteId, on: db)
        
        let salesNotePaymentDTOs = try salesNotePayments.map {
            try SalesNotePaymentResponseDTO(salesNotePayment: $0)
        }
        return CashflowSalesNoteResponseDTO(
            salesNote: try SalesNoteResponseDTO(salesNote: salesNote),
            salesNoteItems: salesNoteItemDTOs,
            salesNotePayments: salesNotePaymentDTOs
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
