import Vapor
import Fluent

struct SalesNotePaymentController: RouteCollection {
    let salesNotePaymentService: any SalesNotePaymentServiceProtocol
    
    func boot(routes: any RoutesBuilder) throws {
        let salesNotePayments = routes.grouped("sales_note_payments")
        
        salesNotePayments.post(use: create)
        salesNotePayments.get(":salesNoteId", use: findAllBySalesNote)
        salesNotePayments.delete("by-salesnote", ":salesNoteId", use: deleteBySalesNote)
        salesNotePayments.delete("by-id", ":id", use: deleteById)
    }
    
    func create(req: Request) async throws -> SalesNotePaymentResponseDTO {
        let data = try req.content.decode(CreateSalesNotePaymentDTO.self)
        return try await salesNotePaymentService.create(data, on: req.db)
    }
    
    func findAllBySalesNote(req: Request) async throws -> [SalesNotePaymentResponseDTO] {
        guard let salesNoteId = req.parameters.get("salesNoteId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid sales note ID")
        }
        return try await salesNotePaymentService.findAllBySalesNote(
            salesNoteId,
            on: req.db
        )
    }
    
    func deleteBySalesNote(req: Request) async throws -> HTTPStatus {
        guard let salesNoteId = req.parameters.get("salesNoteId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid sales note ID")
        }
        
        try await salesNotePaymentService.deleteBySalesNote(salesNoteId, on: req.db)
        return .noContent
    }
    
    func deleteById(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid sales note item ID")
        }
        
        try await salesNotePaymentService.deleteById(id, on: req.db)
        return .noContent
    }
}
