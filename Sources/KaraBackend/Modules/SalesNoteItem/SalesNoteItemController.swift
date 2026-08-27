import Vapor
import Fluent

struct SalesNoteItemController: RouteCollection {
    let salesNoteItemService: any SalesNoteItemServiceProtocol
    
    func boot(routes: any RoutesBuilder) throws {
        let salesNoteItems = routes.grouped("sales_note_items")
        
        salesNoteItems.post(use: create)
        salesNoteItems.get(":salesNoteId", use: findAllBySalesNote)
        salesNoteItems.delete("by-salesnote", ":salesNoteId", use: deleteBySalesNote)
        salesNoteItems.delete("by-id", ":id", use: deleteById)
    }
    
    func create(req: Request) async throws -> SalesNoteItemResponseDTO {
        let data = try req.content.decode(CreateSalesNoteItemDTO.self)
        return try await salesNoteItemService.create(data, on: req.db)
    }
    
    func findAllBySalesNote(req: Request) async throws -> [SalesNoteItemResponseDTO] {
        guard let salesNoteId = req.parameters.get("salesNoteId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid sales note ID")
        }
        return try await salesNoteItemService.findAllBySalesNote(
            salesNoteId,
            on: req.db
        )
    }
    
    func deleteBySalesNote(req: Request) async throws -> HTTPStatus {
        guard let salesNoteId = req.parameters.get("salesNoteId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid sales note ID")
        }
        
        try await salesNoteItemService.deleteBySalesNote(salesNoteId, on: req.db)
        return .noContent
    }
    
    func deleteById(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid sales note item ID")
        }
        
        try await salesNoteItemService.deleteById(id, on: req.db)
        return .noContent
    }
}
