// Modules/Authentication/AuthController.swift
import Vapor
import Fluent

struct AuthenticationController: RouteCollection {
    let authenticationService: any AuthenticationServiceProtocol

    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("auth")

        auth.post("register", use: registerWithPassword)
        auth.post("login", use: loginWithPassword)
    }

    func registerWithPassword(req: Request) async throws -> AuthenticationResponseDTO {
        let dto = try req.content.decode(RegisterWithPasswordDTO.self)
        return try await authenticationService.registerWithPassword(dto, on: req.db)
    }

    func loginWithPassword(req: Request) async throws -> AuthenticationResponseDTO {
        let dto = try req.content.decode(LoginWithPasswordDTO.self)
        return try await authenticationService.loginWithPassword(dto, on: req.db)
    }
}
