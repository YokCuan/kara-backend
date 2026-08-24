import Fluent
import Vapor

protocol ExpenseCategoryServiceProtocol: Sendable {
    func create(_ dto: CreateExpenseCategoryDTO, on db: any Database) async throws -> ExpenseCategoryResponseDTO
    func findAll(on db: any Database) async throws -> [ExpenseCategoryResponseDTO]
    func findByName(name: String, on db: any Database) async throws -> ExpenseCategoryResponseDTO
    func findByNameSlug(nameSlug: String, on db: any Database) async throws -> ExpenseCategoryResponseDTO
    func deleteById(_ id: UUID, on db: any Database) async throws
}

struct ExpenseCategoryService: ExpenseCategoryServiceProtocol, Sendable {
    let expenseCategoryRepository: any ExpenseCategoryRepositoryProtocol
    
    func create(_ data: CreateExpenseCategoryDTO, on db: any Database) async throws -> ExpenseCategoryResponseDTO {
        let expenseCategory = try await expenseCategoryRepository.create(
            name: data.name,
            on: db
        )
        
        return try ExpenseCategoryResponseDTO(expenseCategory: expenseCategory)
    }
    
    func findAll(on db: any Database) async throws -> [ExpenseCategoryResponseDTO] {
        let expenseCategories = try await expenseCategoryRepository.findAll(on: db)
        return try expenseCategories.map{expenseCategory in
            try ExpenseCategoryResponseDTO(expenseCategory: expenseCategory)
        }
    }
    
    func findByName(name: String, on db: any Database) async throws -> ExpenseCategoryResponseDTO {
        guard let expenseCategory = try await expenseCategoryRepository.findByName(name: name, on: db) else {
            throw Abort(.notFound, reason: "Category not found")
        }
        return try ExpenseCategoryResponseDTO(expenseCategory: expenseCategory)
    }
    
    func findByNameSlug(nameSlug: String, on db: any Database) async throws -> ExpenseCategoryResponseDTO {
        guard let expenseCategory = try await expenseCategoryRepository.findByNameSlug(nameSlug: nameSlug, on: db) else {
            throw Abort(.notFound, reason: "Category not found")
        }
        return try ExpenseCategoryResponseDTO(expenseCategory: expenseCategory)
    }
    
    func deleteById(_ id: UUID, on db: any Database) async throws {
        try await expenseCategoryRepository.deleteById(id, on: db)
    }    
}
