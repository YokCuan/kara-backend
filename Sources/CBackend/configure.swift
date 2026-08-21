import Vapor
import Fluent
import FluentPostgresDriver
import NIOSSL
import Queues
import QueuesFluentDriver

/// configures your application
func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // register routes
    try routes(app)
}
