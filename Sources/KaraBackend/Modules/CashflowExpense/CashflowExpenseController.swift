import Vapor
import Fluent

struct CashflowExpenseController: RouteCollection {
    let cashflowExpenseService: any CashflowExpenseServiceProtocol
    
    func boot(routes: RoutesBuilder) throws {
        let cashflowExpenses = routes.grouped("cashflow_expenses")
        
        cashflowExpenses.post(use: create)
        cashflowExpenses.patch(":shopId", ":id", use: update)
        cashflowExpenses.delete(":shopId", ":id", use: delete)
    }
    
    func create(req: Request) async throws -> CashflowExpenseResponseDTO {
        guard let shopId = req.parameters.get("shopId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shop ID")
        }
        
        let dto = try req.content.decode(CreateCashflowExpenseDTO.self)
        
        let correctedDTO = CreateCashflowExpenseDTO(
            shopId: shopId,
            expenseCategoryId: dto.expenseCategoryId,
            supplierName: dto.supplierName,
            supplierPhone: dto.supplierPhone,
            paidAmount: dto.paidAmount,
            purchasedAt: dto.purchasedAt,
            createdBy: dto.createdBy,
            updatedBy: dto.updatedBy,
            items: dto.items
        )
        
        return try await cashflowExpenseService.create(
            correctedDTO,
            on: req.db
        )
    }
    
    func update(req: Request) async throws -> CashflowExpenseResponseDTO {
        guard let shopId = req.parameters.get("shopId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shop ID")
        }
        
        guard let expenseId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid expense ID")
        }
        
        let dto = try req.content.decode(UpdateCashflowExpenseDTO.self)
        
        return try await cashflowExpenseService.update(
            expenseId,
            shopId: shopId,
            dto: dto,
            on: req.db
        )
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let shopId = req.parameters.get("shopId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shop ID")
        }
        
        guard let expenseId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid expense ID")
        }
        
        try await cashflowExpenseService.delete(
            expenseId,
            shopId: shopId,
            on: req.db
        )
        
        return .noContent
    }
}
