import Vapor
import Fluent

struct ExpenseController: RouteCollection {
    let expenseService: any ExpenseServiceProtocol
    
    func boot(routes: any RoutesBuilder) throws {
        let expenses = routes.grouped("expenses")
        
        expenses.post(use: create)
        expenses.get(use: findAll)
        expenses.get(":shopId", ":id", use: findByIdAndShop)
    }
    
    func create(req: Request) async throws -> ExpenseResponseDTO {
        let data = try req.content.decode(CreateExpenseDTO.self)
        return try await expenseService.create(data, on: req.db)
    }
    
    func findAll(req: Request) async throws -> [ExpenseResponseDTO] {
        let query = try req.query.decode(ExpensesByShopAndCategoryDTO.self)
        
        if let expenseCategoryId = query.expenseCategoryId {
            return try await expenseService.findAllByShopAndCategory(
                query.shopId,
                expenseCategoryId: expenseCategoryId,
                on: req.db
            )
        }
        
        return try await expenseService.findAllByShop(
            query.shopId,
            on: req.db
        )
    }
    
    func findByIdAndShop(req: Request) async throws -> ExpenseResponseDTO {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid expense ID")
        }
        
        guard let shopId = req.parameters.get("shopId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shop ID")
        }
        
        guard let expense = try await expenseService.findByIdAndShop(
            id,
            shopId: shopId,
            on: req.db
        ) else {
            throw Abort(.notFound, reason: "Expense not found")
        }
        
        return expense
    }
}
