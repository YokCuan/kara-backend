//
//  ExpenseCategoryController 2.swift
//  KaraBackend
//
//  Created by Sherin Olivia on 24/08/26.
//


import Vapor
import Fluent

struct ExpenseCategoryController: RouteCollection {
    let expenseCategoryService: any ExpenseCategoryServiceProtocol
    
    func boot(routes: RoutesBuilder) throws {
        let expenseCategories = routes.grouped("expense_categories")
        
        expenseCategories.post(use: create)
        expenseCategories.get(use: findAll)
        expenseCategories.delete(":id", use: deleteById)
    }
    
    func create(req: Request) async throws -> ExpenseCategoryResponseDTO {
        let data = try req.content.decode(CreateExpenseCategoryDTO.self)
        return try await expenseCategories.create(data, on: req.db)
    }
    
    func findAll(req: Request) async throws -> [ExpenseCategoryResponseDTO] {
        let query = try req.query.decode(ExpenseCategoryByNameOrSlugDTO.self)
        
        if let name = query.name {
            return try await expenseCategoryService.findByName(
                query.name,
                on: req.db
            )
        } else if let slug = query.nameSlug {
            return try await expenseCategoryService.findByNameSlug(
                query.nameSlug,
                on: req.db
            )
        }
        
        return try await expenseCategoryService.findAll(
            on: req.db
        )
    }
    
    func deleteById(req: Request) async throws {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid expense ID")
        }
        
        return nil
    }
}
