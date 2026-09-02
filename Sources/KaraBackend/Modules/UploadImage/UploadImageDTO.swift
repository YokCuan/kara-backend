import Vapor

struct UploadRequest: Content {
    let file: File
}

struct UploadResponse: Content {
    let key: String
    let filename: String
    let contentType: String
    let size: Int
}
