import Vapor
import Fluent
import FluentPostgresDriver
import NIOSSL
import Queues
import QueuesFluentDriver
import SotoCore
import SotoS3

// configures your application
func configure(_ app: Application) async throws {
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    guard
        let host = Environment.get("DATABASE_HOST"),
        let database = Environment.get("DATABASE_NAME"),
        let username = Environment.get("DATABASE_USERNAME"),
        let password = Environment.get("DATABASE_PASSWORD"),
        let portString = Environment.get("DATABASE_PORT"),
        let port = Int(portString)
    else {
        fatalError("Missing or invalid database environment variables")
    }
    
    let tlsConfiguration = TLSConfiguration.makeClientConfiguration()
    let sslContext = try NIOSSLContext(configuration: tlsConfiguration)
    
    let postgresConfiguration = SQLPostgresConfiguration(
        hostname: host,
        port: port,
        username: username,
        password: password,
        database: database,
        tls: .require(sslContext)
    )
    
    app.databases.use(.postgres(configuration: postgresConfiguration), as: .psql)
    
    app.addMigrations()
    app.migrations.add(JobMetadataMigrate())
    app.queues.use(.fluent())
    
    if !app.environment.arguments.contains("migrate") {
        app.configureR2()
    }
    
    try routes(app)
}
