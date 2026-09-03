func paymentStatus(totalAmount: Int, paidAmount: Int) -> Status {
    if paidAmount == totalAmount {
        return .paid
    } else if paidAmount == 0 {
        return .notPaid
    } else {
        return .dpPaid
    }
}
