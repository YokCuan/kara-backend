import Fluent
import Vapor

extension Application {
    func addMigrations() {
        self.migrations.add(CreateUser())
        self.migrations.add(CreateShop())
        self.migrations.add(CreateExpenseCategory())
        self.migrations.add(CreateExpense())
        self.migrations.add(CreateExpenseItem())
        self.migrations.add(CreateSalesNote())
        self.migrations.add(CreateSalesNoteItem())
        self.migrations.add(CreateSalesNotePayment())
        addSeedMigrations()
    }
}
