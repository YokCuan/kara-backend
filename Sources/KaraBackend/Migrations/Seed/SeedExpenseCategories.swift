import Fluent

struct SeedExpenseCategories: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let expenseCategories = [
            ExpenseCategory(name: "Bahan Baku", nameSlug: "bahan-baku"),
            ExpenseCategory(name: "Gaji Pekerja", nameSlug: "gaji-pekerja"),
            ExpenseCategory(name: "Kemasan", nameSlug: "kemasan"),
            ExpenseCategory(name: "Listrik, Gas, Air, Sewa", nameSlug: "listrik-gas-air-sewa"),
            ExpenseCategory(name: "Pengiriman", nameSlug: "pengiriman"),
            ExpenseCategory(name: "Diambil untuk Pribadi", nameSlug: "diambil-untuk-pribadi"),
            ExpenseCategory(name: "Lainnya", nameSlug: "lainnya")
        ]
    
        for expenseCategory in expenseCategories {
            try await expenseCategory.save(on: database)
        }
    }
    
    func revert(on database: any Database) async throws {
        try await ExpenseCategory.query(on: database).delete()
    }
}
