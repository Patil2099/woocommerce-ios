import Hardware

public extension PaymentIntent {
    /// Maps a PaymentIntent into an struct that contains only the data we need to
    /// render a receipt.
    /// - Returns: an optional struct containing all the data that needs to go into a receipt
    func receiptParameters() -> CardPresentReceiptParameters? {
        guard let paymentMethod = self.charges.first?.paymentMethod,
              case .presentCard(details: let cardDetails) = paymentMethod else {
            return nil
        }

        return CardPresentReceiptParameters(amount: amount,
                                            currency: currency,
                                            date: created,
                                            storeName: metadata?[CardPresentReceiptParameters.MetadataKeys.store] as? String,
                                            cardDetails: cardDetails)
    }
}
