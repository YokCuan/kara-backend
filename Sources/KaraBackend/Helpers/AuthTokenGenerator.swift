import Crypto
import Foundation
import Vapor

enum AuthTokenGenerator {
    static func generate() throws -> String {
        let bytes = [UInt8].random(count: 32)

        return Data(bytes)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    static func hash(_ rawToken: String) -> String {
        let digest = SHA256.hash(
            data: Data(rawToken.utf8)
        )

        return digest.map {
            String(format: "%02x", $0)
        }.joined()
    }
}
