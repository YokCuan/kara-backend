import Vapor
import Fluent

struct ExpenseCategoryController: RouteCollection {
    let expenseCategoryService: any ExpenseCategoryServiceProtocol
    
    func boot(routes: RoutesBuilder) throws {
        let expenseCategories = routes.grouped("expense_categories")
        
        expenseCategories.post(use: create)
        expenseCategories.get(use: findAll)
        expenseCategories.get("by-name", use: findByName)
        expenseCategories.get("by-slug", use: findByNameSlug)
        expenseCategories.delete(":id", use: deleteById)
    }
    
    func create(req: Request) async throws -> ExpenseCategoryResponseDTO {
        let data = try req.content.decode(CreateExpenseCategoryDTO.self)
        return try await expenseCategoryService.create(data, on: req.db)
    }
    
    func findAll(req: Request) async throws -> [ExpenseCategoryResponseDTO] {
        return try await expenseCategoryService.findAll(
            on: req.db
        )
    }
    
    func findByName(req: Request) async throws -> ExpenseCategoryResponseDTO {
        guard let name = req.query[String.self, at: "name"] else {
            throw Abort(.badRequest, reason: "Missing 'name' query parameter")
        }
        
        return try await expenseCategoryService.findByName(name: name, on: req.db)
    }
    
    func findByNameSlug(req: Request) async throws -> ExpenseCategoryResponseDTO {
        guard let nameSlug = req.query[String.self, at: "nameSlug"] else {
            throw Abort(.badRequest, reason: "Missing 'name' query parameter")
        }
        
        return try await expenseCategoryService.findByNameSlug(nameSlug: nameSlug, on: req.db)
    }
    
    func deleteById(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid expense category ID")
        }
        
        try await expenseCategoryService.deleteById(id, on: req.db)
        return .noContent
    }
}
