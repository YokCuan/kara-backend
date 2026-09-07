import Fluent
import Vapor

protocol CashflowServiceProtocol: Sendable {
    func findAllByShop(_ shopId: UUID, on db: any Database) async throws -> [CashflowResponseDTO]
}

struct CashflowService: CashflowServiceProtocol, Sendable {
    let expenseRepository: any ExpenseRepositoryProtocol
    let salesNotePaymentRepository: any SalesNotePaymentRepositoryProtocol

    func findAllByShop(_ shopId: UUID,on db: any Database) async throws -> [CashflowResponseDTO] {
        async let expensesTask = expenseRepository.findAllByShopWithCategory(
            shopId,
            on: db
        )
        async let salesNotePaymentsTask = salesNotePaymentRepository.findAllForCashflowByShop(shopId, on: db)
        
        let (expenses, salesNotePayments) = try await (
            expensesTask,
            salesNotePaymentsTask
        )

        let expenseEntries: [CashflowResponseDTO] = expenses.map { expense in
            return CashflowResponseDTO(
                id: expense.id,
                type: .expense,
                categoryType: expense.categoryName,
                amount: expense.paidAmount,
                occurredAt: expense.purchasedAt,
                title: expense.supplierName ?? "Expense",
                description: nil
            )
        }

        let salesNotePaymentEntries: [CashflowResponseDTO] = salesNotePayments.map { salesNotePayment in
            CashflowResponseDTO(
                id: salesNotePayment.salesNoteId,
                type: .salesNote,
                categoryType: "Penjualan",
                amount: salesNotePayment.amount,
                occurredAt: salesNotePayment.paidAt,
                title: salesNotePayment.customerName,
                description: makeSalesPaymentDescription(
                    identifier: salesNotePayment.identifier,
                    paymentAttempt: salesNotePayment.paymentAttempt,
                    paymentCount: salesNotePayment.paymentCount,
                    status: salesNotePayment.salesNoteStatus
                )
            )
        }

        return (expenseEntries + salesNotePaymentEntries)
            .sorted { $0.occurredAt > $1.occurredAt }
    }
}
