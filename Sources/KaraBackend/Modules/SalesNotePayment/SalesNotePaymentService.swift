import Fluent
import Vapor

protocol SalesNotePaymentServiceProtocol: Sendable {
    func create(_ dto: CreateSalesNotePaymentDTO, on db: any Database) async throws -> SalesNotePaymentResponseDTO
    func findAllBySalesNote(_ salesNoteId: UUID, on db: any Database) async throws -> [SalesNotePaymentResponseDTO]
    func deleteBySalesNote(_ salesNoteId: UUID, on db: any Database) async throws
    func deleteById(_ id: UUID, on db: any Database) async throws
}

struct SalesNotePaymentService: SalesNotePaymentServiceProtocol, Sendable {
    let salesNotePaymentRepository: any SalesNotePaymentRepositoryProtocol
    
    func create(_ data: CreateSalesNotePaymentDTO, on db: any Database) async throws -> SalesNotePaymentResponseDTO {
        guard data.paidAmount > 0 else {
            throw Abort(.badRequest, reason: "Payment amount must be greater than zero")
        }
        
        let salesNotePayments = try await salesNotePaymentRepository.findAllBySalesNote(data.salesNoteId, on: db)
        let paymentAttempt = salesNotePayments.count + 1
        let salesNotePayment = try await salesNotePaymentRepository.create(
            salesNoteId: data.salesNoteId,
            paymentAttempt: paymentAttempt,
            paidAmount: data.paidAmount,
            paidAt: data.paidAt,
            on: db
        )
        
        return try SalesNotePaymentResponseDTO(salesNotePayment: salesNotePayment)
    }
    
    func findAllBySalesNote(_ salesNoteId: UUID, on db: any Database) async throws -> [SalesNotePaymentResponseDTO] {
        let salesNotePayments = try await salesNotePaymentRepository.findAllBySalesNote(salesNoteId, on: db)
        return try salesNotePayments.map{salesNotePayment in
            try SalesNotePaymentResponseDTO(salesNotePayment: salesNotePayment)
        }
    }
    
    func deleteBySalesNote(_ salesNoteId: UUID, on db: any Database) async throws {
        try await salesNotePaymentRepository.deleteBySalesNote(salesNoteId, on: db)
    }
    
    func deleteById(_ id: UUID, on db: any Database) async throws {
        try await salesNotePaymentRepository.deleteById(id, on: db)
    }
}
