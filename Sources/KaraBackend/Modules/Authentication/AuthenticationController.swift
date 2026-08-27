// Modules/Authentication/AuthController.swift
import Vapor
import Fluent

struct AuthenticationController: RouteCollection {
    let authenticationService: any AuthenticationServiceProtocol

    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("auth")

        auth.post("register", use: register)
        auth.post("login", use: login)
    }

    func register(req: Request) async throws -> RegisterResponseDTO {
        let dto = try req.content.decode(RegisterDTO.self)
        return try await authenticationService.register(dto, on: req.db)
    }

    func login(req: Request) async throws -> UserResponseDTO {
        let dto = try req.content.decode(LoginDTO.self)
        return try await authenticationService.login(dto, on: req.db)
    }
}
