import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }
    
    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
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
}
