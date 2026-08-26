import Fluent
import Foundation

final class Expense: Model, @unchecked Sendable {
    static let schema = "expenses"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "shop_id")
    var shop: Shop
    
    @Parent(key: "expense_category_id")
    var expenseCategory: ExpenseCategory
    
    @OptionalField(key: "supplier_name")
    var supplierName: String?
    
    @OptionalField(key: "supplier_phone")
    var supplierPhone: String?
    
    @Field(key: "paid_amount")
    var paidAmount: Int
    
    @Field(key: "purchased_at")
    var purchasedAt: Date
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Field(key: "created_by")
    var createdBy: String
    
    @Field(key: "updated_by")
    var updatedBy: String
    
    @Children(for: \.$expense)
    var expenseItem: [ExpenseItem]
    
    init() {
        
    }
    
    init(id: UUID? = nil, shopId: UUID, expenseCategoryId: UUID, supplierName: String?, supplierPhone: String?, paidAmount: Int, purchasedAt: Date, createdAt: Date?, updatedAt: Date?, createdBy: String, updatedBy: String) {
        self.id = id
        self.$shop.id = shopId
        self.$expenseCategory.id = expenseCategoryId
        self.supplierName = supplierName
        self.supplierPhone = supplierPhone
        self.paidAmount = paidAmount
        self.purchasedAt = purchasedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.createdBy = createdBy
        self.updatedBy = updatedBy
    }
}
