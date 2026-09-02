import Foundation
import SotoCore
import SotoS3
import Vapor

struct R2StorageService: Sendable {
    let client: S3
    let bucket: String

    func upload(
        file: File,
        key: String,
        logger: Logger
    ) async throws {
        let input = S3.PutObjectRequest(
            body: AWSHTTPBody(buffer: file.data),
            bucket: bucket,
            contentType: file.contentType?.description,
            key: key
        )

        _ = try await client.putObject(input, logger: logger)
    }
}
