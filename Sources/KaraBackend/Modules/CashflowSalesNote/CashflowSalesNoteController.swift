import Vapor
import Fluent

struct CashflowSalesNoteController: RouteCollection {
    let cashflowSalesNoteService: any CashflowSalesNoteServiceProtocol
    
    func boot(routes: any RoutesBuilder) throws {
        let cashflowSalesNotes = routes.grouped("cashflow_sales_notes")
        
        cashflowSalesNotes.post(use: create)
        cashflowSalesNotes.get(":shopId", use: findAllByShop)
        cashflowSalesNotes.get(":shopId", ":id", use: findByIdAndShop)
        cashflowSalesNotes.delete(":shopId", ":id", use: softDelete)
    }
    
    func create(req: Request) async throws -> CashflowSalesNoteResponseDTO {
        let dto = try req.content.decode(CreateCashflowSalesNoteDTO.self)
        
        return try await cashflowSalesNoteService.create(
            dto,
            on: req.db
        )
    }
    
    func findAllByShop(req: Request) async throws -> [CashflowSalesNoteResponseDTO] {
        guard let shopId = req.parameters.get("shopId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shop ID")
        }
        
        return try await cashflowSalesNoteService.findAllByShop(
            shopId,
            on: req.db
        )
    }
    
    func findByIdAndShop(req: Request) async throws -> CashflowSalesNoteResponseDTO {
        guard let shopId = req.parameters.get("shopId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shop ID")
        }
        
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid ID")
        }
        
        return try await cashflowSalesNoteService.findByIdAndShop(
            id,
            shopId: shopId,
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
