import Fluent
import Vapor

protocol CashflowServiceProtocol: Sendable {
    func findAllByShop(_ shopId: UUID, on db: any Database) async throws -> [CashflowResponseDTO]
}

struct CashflowService: CashflowServiceProtocol, Sendable {
    let expenseRepository: any ExpenseRepositoryProtocol
    let salesNoteRepository: any SalesNoteRepositoryProtocol

    func findAllByShop(_ shopId: UUID,on db: any Database) async throws -> [CashflowResponseDTO] {
        async let expensesTask = expenseRepository.findAllByShop(
            shopId,
            on: db
        )

        async let salesNotesTask = salesNoteRepository.findAllByShop(
            shopId,
            on: db
        )

        let (expenses, salesNotes) = try await (
            expensesTask,
            salesNotesTask
        )

        let expenseEntries = try expenses.map { expense in
            guard let id = expense.id else {
                throw Abort(.internalServerError, reason: "Expense ID is missing")
            }

            return CashflowResponseDTO(
                id: id,
                type: .expense,
                amount: expense.paidAmount,
                occurredAt: expense.purchasedAt,
                title: expense.supplierName ?? "Expense",
                description: nil
            )
        }

        let salesNoteEntries = try salesNotes.map { salesNote in
            guard let id = salesNote.id else {
                throw Abort(.internalServerError, reason: "Sales note ID is missing")
            }

            return CashflowResponseDTO(
                id: id,
                type: .salesNote,
                amount: salesNote.paidAmount,
                occurredAt: salesNote.soldAt,
                title: salesNote.customerName,
                description: salesNote.identifier
            )
        }

        return (expenseEntries + salesNoteEntries)
            .sorted { $0.occurredAt > $1.occurredAt }
    }
}
