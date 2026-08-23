import Fluent
import Vapor

extension Application {
    func addSeedMigrations() {
        self.migrations.add(SeedExpenseCategories())
    }
}
