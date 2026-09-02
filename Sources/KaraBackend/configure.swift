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
    try await app.autoMigrate()
    
    guard let accountId = Environment.get("R2_ACCOUNT_ID"),
          let accessKey = Environment.get("R2_ACCESS_KEY_ID"),
          let secretKey = Environment.get("R2_SECRET_ACCESS_KEY"),
          let bucket = Environment.get("R2_BUCKET")
    else {
        fatalError("Missing R2 environment variables")
    }
    
    let endpoint = "https://\(accountId).r2.cloudflarestorage.com"
    
    let awsClient = AWSClient(
        credentialProvider: .static(
            accessKeyId: accessKey,
            secretAccessKey: secretKey
        )
    )
    
    let s3 = S3(
        client: awsClient,
        endpoint: endpoint
    )
    
    app.storage[ R2StorageKey.self ] = R2StorageService(
        client: s3,
        bucket: bucket
    )
    
    app.lifecycle.use(R2ShutdownHandler(client: awsClient))
    
    try routes(app)
}

struct R2ShutdownHandler: LifecycleHandler {
    let client: AWSClient

    func shutdownAsync(_ application: Application) async throws {
        try await client.shutdown()
    }
}
