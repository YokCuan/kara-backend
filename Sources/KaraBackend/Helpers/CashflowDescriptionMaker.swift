func makeSalesPaymentDescription(
    identifier: String,
    paymentAttempt: Int,
    paymentCount: Int,
    status: Status
) -> String {
    guard paymentCount > 1 || status != .paid else {
        return identifier
    }
    
    return "\(identifier) - Pembayaran ke \(paymentAttempt)"
}
