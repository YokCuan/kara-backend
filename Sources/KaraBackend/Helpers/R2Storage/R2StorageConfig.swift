import SotoS3
import Vapor

struct R2Storage {
    let client: S3
    let bucket: String
}

struct R2StorageKey: StorageKey {
    typealias Value = R2StorageService
}

extension Application {
    var r2Storage: R2StorageService? {
        get {
            storage[R2StorageKey.self]
        }
        set {
            storage[R2StorageKey.self] = newValue
        }
    }
}

extension Application {

    func configureR2() {
        guard
            let accountId = Environment.get("R2_ACCOUNT_ID"),
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

        self.r2Storage = R2StorageService(
            client: s3,
            bucket: bucket
        )

        self.lifecycle.use(
            R2ShutdownHandler(client: awsClient)
        )
    }
}

struct R2ShutdownHandler: LifecycleHandler {

    let client: AWSClient

    func shutdownAsync(_ app: Application) async throws {
        app.logger.info("🔥 R2ShutdownHandler: shutting down AWSClient")

        try await client.shutdown()

        app.logger.info("🔥 R2ShutdownHandler: AWSClient shut down")
    }
}
