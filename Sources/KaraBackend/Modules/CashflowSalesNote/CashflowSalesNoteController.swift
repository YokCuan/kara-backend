import Vapor
import Fluent

struct CashflowSalesNoteController: RouteCollection {
    let cashflowSalesNoteService: any CashflowSalesNoteServiceProtocol
    
    func boot(routes: any RoutesBuilder) throws {
        let cashflowSalesNotes = routes.grouped("cashflow_sales_notes")
        
        cashflowSalesNotes.post(use: create)
        cashflowSalesNotes.delete(":shopId", ":id", use: softDelete)
    }
    
    func create(req: Request) async throws -> CashflowSalesNoteResponseDTO {
        let dto = try req.content.decode(CreateCashflowSalesNoteDTO.self)
        
        return try await cashflowSalesNoteService.create(
            dto,
            on: req.db
        )
    }
    
    func softDelete(req: Request) async throws -> HTTPStatus {
        guard let shopId = req.parameters.get("shopId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shop ID")
        }
        
        guard let salesNoteId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid sales note ID")
        }
        
        try await cashflowSalesNoteService.softDelete(
            salesNoteId,
            shopId: shopId,
            on: req.db
        )
        
        return .noContent
    }
}
