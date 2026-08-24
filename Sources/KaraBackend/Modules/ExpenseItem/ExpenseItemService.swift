import Fluent
import Vapor

protocol ExpenseItemServiceProtocol: Sendable {
    func create(_ dto: CreateExpenseItemDTO, on db: any Database) async throws -> ExpenseItemResponseDTO
    func findAllByExpense(_ expenseId: UUID, on db: any Database) async throws -> [ExpenseItemResponseDTO]
    func deleteByExpense(_ expenseId: UUID, on db: any Database) async throws
    func deleteById(_ id: UUID, on db: any Database) async throws
}

struct ExpenseItemService: ExpenseItemServiceProtocol, Sendable {
    let expenseItemRepository: any ExpenseItemRepositoryProtocol
    
    func create(_ data: CreateExpenseItemDTO, on db: any Database) async throws -> ExpenseItemResponseDTO {
        let expenseItem = try await expenseItemRepository.create(
            expenseId: data.expenseId,
            name: data.name,
            on: db
        )
        
        return try ExpenseItemResponseDTO(expenseItem: expenseItem)
    }
    
    func findAllByExpense(_ expenseId: UUID, on db: any Database) async throws -> [ExpenseItemResponseDTO] {
        let expenseItems = try await expenseItemRepository.findAllByExpense(expenseId, on: db)
        return try expenseItems.map{expenseItem in
            try ExpenseItemResponseDTO(expenseItem: expenseItem)
        }
    }
    
    func deleteByExpense(_ expenseId: UUID, on db: any Database) async throws {
        try await expenseItemRepository.deleteByExpense(expenseId, on: db)
    }
    
    func deleteById(_ id: UUID, on db: any Database) async throws {
        try await expenseItemRepository.deleteById(id, on: db)
    }
}
