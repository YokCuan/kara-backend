import Vapor

func indonesianPhoneFormatter(_ input: String) throws -> String {
    let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)

    let digits = trimmed.filter(\.isNumber)

    let normalized: String

    if digits.hasPrefix("0") {
        normalized = "+62" + digits.dropFirst()
    } else if digits.hasPrefix("62") {
        normalized = "+" + digits
    } else if trimmed.hasPrefix("+62") {
        normalized = "+" + digits
    } else {
        throw Abort(
            .badRequest,
            reason: "Use a valid Indonesian phone number"
        )
    }

    guard normalized.count >= 10, normalized.count <= 16 else {
        throw Abort(
            .badRequest,
            reason: "Use a valid Indonesian phone number"
        )
    }

    return normalized
}
