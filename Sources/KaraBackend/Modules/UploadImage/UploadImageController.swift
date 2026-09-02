import Vapor

struct UploadImageController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
            routes.on(
                .POST,
                "uploads",
                body: .collect(maxSize: "12mb"),
                use: uploadImage
            )
        }

    private func uploadImage(
        req: Request
    ) async throws -> UploadResponse {
        req.logger.info(
            "Upload Content-Type: \(req.headers.contentType?.description ?? "missing")"
        )
        let payload = try req.content.decode(UploadRequest.self)

        let file = payload.file
        req.logger.info(
            "Upload received: filename=\(file.filename), contentType=\(file.contentType?.description ?? "none"), size=\(file.data.readableBytes)"
        )

        guard file.data.readableBytes <= 10 * 1024 * 1024 else {
            throw Abort(
                .payloadTooLarge,
                reason: "File must be smaller than 10 MB"
            )
        }

        guard let contentType = file.contentType,
              [
                HTTPMediaType.jpeg,
                HTTPMediaType.png,
                HTTPMediaType.pdf
              ].contains(contentType)
        else {
            throw Abort(
                .unsupportedMediaType,
                reason: "Only JPEG, PNG, and PDF files are supported"
            )
        }

        guard let storage = req.application.r2Storage else {
            throw Abort(
                .internalServerError,
                reason: "R2 storage is not configured"
            )
        }

        let fileExtension = file.filename
            .split(separator: ".")
            .last
            .map(String.init) ?? "bin"

        let key = "sales-notes/\(UUID().uuidString).\(fileExtension)"

        try await storage.upload(
            file: file,
            key: key,
            logger: req.logger
        )

        return UploadResponse(
            key: key,
            filename: file.filename,
            contentType: contentType.description,
            size: file.data.readableBytes
        )
    }
}
