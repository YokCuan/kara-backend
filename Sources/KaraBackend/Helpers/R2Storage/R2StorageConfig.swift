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
