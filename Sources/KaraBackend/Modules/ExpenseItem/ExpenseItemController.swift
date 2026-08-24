import Vapor
import Fluent

struct ExpenseItemController: RouteCollection {
    let expenseItemService: any ExpenseItemServiceProtocol
    
    func boot(routes: RoutesBuilder) throws {
        let expenseItems = routes.grouped("expense_items")
        
        expenseItems.post(use: create)
        expenseItems.get(":expenseId", use: findAllByExpense)
        expenseItems.delete("by-expense", ":expenseId", use: deleteByExpense)
        expenseItems.delete("by-id", ":id", use: deleteById)
    }
    
    func create(req: Request) async throws -> ExpenseItemResponseDTO {
        let data = try req.content.decode(CreateExpenseItemDTO.self)
        return try await expenseItemService.create(data, on: req.db)
    }
    
    func findAllByExpense(req: Request) async throws -> [ExpenseItemResponseDTO] {
        guard let expenseId = req.parameters.get("expenseId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid expense ID")
        }
        return try await expenseItemService.findAllByExpense(
            expenseId,
            on: req.db
        )
    }
    
    func deleteByExpense(req: Request) async throws -> HTTPStatus {
        guard let expenseId = req.parameters.get("expenseId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid expense ID")
        }
        
        try await expenseItemService.deleteByExpense(expenseId, on: req.db)
        return .noContent
    }
    
    func deleteById(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid expense item ID")
        }
        
        try await expenseItemService.deleteById(id, on: req.db)
        return .noContent
    }
}
