import Fluent
import Vapor

protocol ExpenseServiceProtocol: Sendable {
    func create(_ dto: CreateExpenseDTO, on db: any Database) async throws -> ExpenseResponseDTO
    func findAllByShop(_ shopId: UUID, on db: any Database) async throws -> [ExpenseResponseDTO]
    func findAllByShopAndCategory(_ shopId: UUID, expenseCategoryId: UUID, on db: any Database) async throws -> [ExpenseResponseDTO]
    func findByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws -> ExpenseResponseDTO?
}

struct ExpenseService: ExpenseServiceProtocol, Sendable {
    let expenseRepository: any ExpenseRepositoryProtocol
    
    func create(_ data: CreateExpenseDTO, on db: any Database) async throws -> ExpenseResponseDTO {
        let expense = try await expenseRepository.create(
            shopId: data.shopId,
            expenseCategoryId: data.expenseCategoryId,
            supplierName: data.supplierName,
            supplierPhone: data.supplierPhone,
            paidAmount: data.paidAmount,
            purchasedAt: data.purchasedAt,
            createdBy: data.createdBy,
            updatedBy: data.updatedBy,
            on: db
        )
        
        return try ExpenseResponseDTO(expense: expense)
    }
    
    func findAllByShop(_ shopId: UUID, on db: any Database) async throws -> [ExpenseResponseDTO] {
        let expenses = try await expenseRepository.findAllByShop(shopId, on: db)
        return try expenses.map{expense in
            try ExpenseResponseDTO(expense: expense)
        }
    }
    
    func findAllByShopAndCategory(_ shopId: UUID, expenseCategoryId: UUID, on db: any Database) async throws -> [ExpenseResponseDTO] {
        let expenses = try await expenseRepository.findAllByShopAndCategory(shopId, expenseCategoryId: expenseCategoryId, on: db)
        
        return try expenses.map{expense in
            try ExpenseResponseDTO(expense: expense)
        }
    }
    
    func findByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws -> ExpenseResponseDTO? {
        guard let expense = try await expenseRepository.findByIdAndShop(id, shopId: shopId, on: db) else {
            return nil
        }
        return try ExpenseResponseDTO(expense: expense)
    }
}
