import Fluent
import Vapor


protocol CashflowExpenseServiceProtocol: Sendable {
    func create(_ dto: CreateCashflowExpenseDTO, on db: any Database) async throws -> CashflowExpenseResponseDTO
    func findAllByShop(_ shopId: UUID, on db: any Database) async throws -> [CashflowExpenseResponseDTO]
    func findByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws -> CashflowExpenseResponseDTO
    func update(_ expenseId: UUID, shopId: UUID, dto: UpdateCashflowExpenseDTO, on db: any Database) async throws -> CashflowExpenseResponseDTO
    func delete(_ expenseId: UUID, shopId: UUID, on db: any Database ) async throws
}

struct CashflowExpenseService: CashflowExpenseServiceProtocol, Sendable {
    let expenseRepository: any ExpenseRepositoryProtocol
    let expenseItemRepository: any ExpenseItemRepositoryProtocol
    
    func create(_ dto: CreateCashflowExpenseDTO, on db: any Database) async throws -> CashflowExpenseResponseDTO {
        guard !dto.items.isEmpty else {
            throw Abort(.badRequest, reason: "Expense must contain at least one item")
        }
        guard dto.items.allSatisfy({ !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            throw Abort(.badRequest, reason: "Expense item name cannot be empty")
        }
        
        return try await db.transaction { tx in
            let purchasedAt = dto.purchasedAt ?? Date()
            let expense = try await expenseRepository.create(
                shopId: dto.shopId,
                expenseCategoryId: dto.expenseCategoryId,
                supplierName: dto.supplierName,
                supplierPhone: dto.supplierPhone,
                paidAmount: dto.paidAmount,
                purchasedAt: purchasedAt,
                createdBy: dto.createdBy,
                updatedBy: dto.updatedBy,
                on: tx
            )
            
            guard let expenseId = expense.id else {
                throw Abort(.internalServerError, reason: "Failed to create expense")
            }
            
            var expenseItems: [ExpenseItemResponseDTO] = []
            
            for item in dto.items {
                let createdItem = try await expenseItemRepository.create(
                    expenseId: expenseId,
                    name: item.name,
                    on: tx
                )
                expenseItems.append(try ExpenseItemResponseDTO(expenseItem: createdItem))
            }
            
            return CashflowExpenseResponseDTO(
                expense: try ExpenseResponseDTO(expense: expense),
                expenseItems: expenseItems
            )
        }
    }
    
    func findAllByShop(_ shopId: UUID, on db: any Database) async throws -> [CashflowExpenseResponseDTO] {
        let expenses = try await expenseRepository.findAllByShop(shopId, on: db)
        
        var results: [CashflowExpenseResponseDTO] = []
        
        for expense in expenses {
            guard let expenseId = expense.id else {
                throw Abort(.internalServerError, reason: "Expense ID is missing")
            }
            
            let expenseItems = try await expenseItemRepository.findAllByExpense(expenseId, on: db)
            
            let expenseItemDTOs = try expenseItems.map {
                try ExpenseItemResponseDTO(expenseItem: $0)
            }
            
            results.append(
                CashflowExpenseResponseDTO(
                    expense: try ExpenseResponseDTO(expense: expense),
                    expenseItems: expenseItemDTOs
                )
            )
        }
        
        return results
    }
    
    func findByIdAndShop(_ id: UUID, shopId: UUID, on db: any Database) async throws -> CashflowExpenseResponseDTO {
        guard let expense = try await expenseRepository.findByIdAndShop(id, shopId: shopId, on: db) else {
            throw Abort(.notFound, reason: "Expense not found")
        }
        
        guard let expenseId = expense.id else {
            throw Abort(.internalServerError, reason: "Expense ID is missing")
        }
        
        let expenseItems = try await expenseItemRepository.findAllByExpense(expenseId, on: db)
        
        let expenseItemDTOs = try expenseItems.map {
            try ExpenseItemResponseDTO(expenseItem: $0)
        }
        
        return CashflowExpenseResponseDTO(
            expense: try ExpenseResponseDTO(expense: expense),
            expenseItems: expenseItemDTOs
        )
    }
    
    func update(_ expenseId: UUID, shopId: UUID, dto: UpdateCashflowExpenseDTO, on db: any Database) async throws -> CashflowExpenseResponseDTO {
        try await db.transaction { transaction in
            guard let _ = try await expenseRepository.findByIdAndShop(
                expenseId,
                shopId: shopId,
                on: transaction
            ) else {
                throw Abort(.notFound, reason: "Expense not found")
            }
            
            let updatedExpense = try await expenseRepository.update(
                expenseId,
                shopId: shopId,
                expenseCategoryId: dto.expenseCategoryId,
                supplierName: dto.supplierName,
                supplierPhone: dto.supplierPhone,
                paidAmount: dto.paidAmount,
                purchasedAt: dto.purchasedAt,
                updatedBy: dto.updatedBy,
                on: transaction
            )
            
            try await expenseItemRepository.deleteByExpense(
                expenseId,
                on: transaction
            )
            
            var newItems: [ExpenseItem] = []
            
            for item in dto.items {
                let newItem = try await expenseItemRepository.create(
                    expenseId: expenseId,
                    name: item.name,
                    on: transaction
                )
                newItems.append(newItem)
            }
            
            return CashflowExpenseResponseDTO(
                expense: try ExpenseResponseDTO(expense: updatedExpense),
                expenseItems: try newItems.map {
                    try ExpenseItemResponseDTO(expenseItem: $0)
                }
            )
        }
    }
    
    func delete(_ expenseId: UUID, shopId: UUID, on db: any Database) async throws {
        try await db.transaction { transaction in
            guard let _ = try await expenseRepository.findByIdAndShop(
                expenseId,
                shopId: shopId,
                on: transaction
            ) else {
                throw Abort(.notFound, reason: "Expense not found")
            }
            
            try await expenseItemRepository.deleteByExpense(
                expenseId,
                on: transaction
            )
            
            try await expenseRepository.deleteById(
                expenseId,
                on: transaction
            )
        }
    }
}
