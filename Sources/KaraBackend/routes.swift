import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }
    
    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    //    MARK: - User & Shop Related
    let userRepository = UserRepository()
    let shopRepository = ShopRepository()
    
    let userService = UserService(userRepository: userRepository)
    let shopService = ShopService(shopRepository: shopRepository)
    let authenticationService = AuthenticationService(userService: userService, shopService: shopService)
    
    let userController = UserController(userService: userService)
    try app.register(collection: userController)
    
    let shopController = ShopController(shopService: shopService)
    try app.register(collection: shopController)
    
    let authenticationController = AuthenticationController(authenticationService: authenticationService)
    try app.register(collection: authenticationController)
    
    //    MARK: - Expenses Related
    let expenseCategoryRepository = ExpenseCategoryRepository()
    let expenseRepository = ExpenseRepository()
    let expenseItemRepository = ExpenseItemRepository()
    
    let expenseCategoryService = ExpenseCategoryService(expenseCategoryRepository: expenseCategoryRepository)
    let expenseService = ExpenseService(expenseRepository: expenseRepository)
    let expenseItemService = ExpenseItemService(expenseItemRepository: expenseItemRepository)
    let cashflowExpenseService = CashflowExpenseService(expenseRepository: expenseRepository, expenseItemRepository: expenseItemRepository)
    
    let expenseCategoryController = ExpenseCategoryController(expenseCategoryService: expenseCategoryService)
    try app.register(collection: expenseCategoryController)
    
    let expenseController = ExpenseController(expenseService: expenseService)
    try app.register(collection: expenseController)
    
    let expenseItemController = ExpenseItemController(expenseItemService: expenseItemService)
    try app.register(collection: expenseItemController)
    
    let cashflowExpenseController = CashflowExpenseController(cashflowExpenseService: cashflowExpenseService)
    try app.register(collection: cashflowExpenseController)
    
    //    MARK: - Sales Notes Related
    let salesNoteRepository = SalesNoteRepository()
    let salesNoteItemRepository = SalesNoteItemRepository()
    
    let salesNoteService = SalesNoteService(salesNoteRepository: salesNoteRepository)
    let salesNoteItemService = SalesNoteItemService(salesNoteItemRepository: salesNoteItemRepository)
    let cashflowSalesNoteService = CashflowSalesNoteService(salesNoteRepository: salesNoteRepository, salesNoteItemRepository: salesNoteItemRepository)
    
    let salesNoteController = SalesNoteController(salesNoteService: salesNoteService)
    try app.register(collection: salesNoteController)
    
    let salesNoteItemController = SalesNoteItemController(salesNoteItemService: salesNoteItemService)
    try app.register(collection: salesNoteItemController)
    
    let cashflowSalesNoteController = CashflowSalesNoteController(cashflowSalesNoteService: cashflowSalesNoteService)
    try app.register(collection: cashflowSalesNoteController)
    
    //    MARK: - Cashflow
    let cashflowService = CashflowService(expenseRepository: expenseRepository, salesNoteRepository: salesNoteRepository)
    
    let cashflowController = CashflowController(cashflowService: cashflowService)
    try app.register(collection: cashflowController)
    
    //    MARK: - Upload Image
    try app.register(collection: UploadImageController())
}
