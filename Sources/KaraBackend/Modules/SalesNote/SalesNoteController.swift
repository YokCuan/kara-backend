import Vapor
import Fluent

struct SalesNoteController: RouteCollection {
    let salesNoteService: any SalesNoteServiceProtocol
    
    func boot(routes: any RoutesBuilder) throws {
        let salesNotes = routes.grouped("sales_notes")
        
        salesNotes.post(use: create)
        salesNotes.get(":shopId", use: findAllByShop)
        salesNotes.get("customers", ":shopId", use: findAllCustomersByShop)
        salesNotes.get(":shopId", ":id", use: findByIdAndShop)
        salesNotes.get(":shopId", "identifier", ":identifier", use: findByShopAndIdentifier)
        salesNotes.patch("paid-amount", ":shopId", ":id", use: updateSalesNotePaidAmount)
        salesNotes.delete(":shopId", ":id", use: softDeleteByIdAndShop)
    }
    
    func create(req: Request) async throws -> SalesNoteResponseDTO {
        let data = try req.content.decode(CreateSalesNoteDTO.self)
        
        return try await salesNoteService.create(
            data,
            on: req.db
        )
    }
    
    func updateSalesNotePaidAmount(req: Request) async throws -> SalesNoteResponseDTO {
        guard let shopId = req.parameters.get("shopId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shop ID")
        }
        
        guard let salesNoteId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid sales note ID")
        }
        
        let data = try req.content.decode(AddSalesNotePaymentDTO.self)
        
        return try await salesNoteService.addSalesNotePaidAmount(
            salesNoteId,
            shopId: shopId,
            data: data,
            on: req.db
        )
    }
    
    func findAllByShop(req: Request) async throws -> [SalesNoteResponseDTO] {
        guard let shopId = req.parameters.get("shopId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shop ID")
        }
        
        return try await salesNoteService.findAllByShop(
            shopId,
            on: req.db
        )
    }
    
    func findByIdAndShop(req: Request) async throws -> SalesNoteResponseDTO {
        guard let shopId = req.parameters.get("shopId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shop ID")
        }
        
        guard let salesNoteId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid sales note ID")
        }
        
        guard let salesNote = try await salesNoteService.findByIdAndShop(
            salesNoteId,
            shopId: shopId,
            on: req.db
        ) else {
            throw Abort(.notFound, reason: "Sales note not found")
        }
        
        return salesNote
    }
    
    func findByShopAndIdentifier(req: Request) async throws -> SalesNoteResponseDTO {
        guard let shopId = req.parameters.get("shopId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shop ID")
        }
        
        guard let identifier = req.parameters.get("identifier") else {
            throw Abort(.badRequest, reason: "Missing sales note identifier")
        }
        
        guard let salesNote = try await salesNoteService.findByShopAndIdentifier(
            shopId,
            identifier: identifier,
            on: req.db
        ) else {
            throw Abort(.notFound, reason: "Sales note not found")
        }
        
        return salesNote
    }
    
    func findAllCustomersByShop(req: Request) async throws -> [CustomerResponseDTO] {
        guard let shopId = req.parameters.get("shopId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shop ID")
        }
        
        return try await salesNoteService.findAllCustomersByShop(
            shopId,
            on: req.db
        )
    }
    
    func softDeleteByIdAndShop(req: Request) async throws -> HTTPStatus {
        guard let shopId = req.parameters.get("shopId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shop ID")
        }
        
        guard let salesNoteId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid sales note ID")
        }
        
        try await salesNoteService.softDeleteByIdAndShop(
            salesNoteId,
            shopId: shopId,
            on: req.db
        )
        
        return .noContent
    }
}
