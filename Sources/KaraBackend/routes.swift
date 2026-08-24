import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }
    
    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    let userController = UserController(
        userService: UserService(userRepository: UserRepository())
    )
    try app.register(collection: userController)
    
    let shopController = ShopController(
        shopService: ShopService(shopRepository: ShopRepository())
    )
    try app.register(collection: shopController)
}
