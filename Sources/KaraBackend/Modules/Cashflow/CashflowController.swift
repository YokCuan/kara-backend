import Vapor
import Fluent

struct CashflowController: RouteCollection {
    let cashflowService: any CashflowServiceProtocol
    
    func boot(routes: any RoutesBuilder) throws {
        let cashflows = routes.grouped("cashflows")
        
        cashflows.get(":shopId", use: findAllByShop)
    }
    
    func findAllByShop(req: Request) async throws -> [CashflowResponseDTO] {
        guard let shopId = req.parameters.get("shopId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shop ID")
        }
        
        return try await cashflowService.findAllByShop(
            shopId,
            on: req.db
        )
    }
}
