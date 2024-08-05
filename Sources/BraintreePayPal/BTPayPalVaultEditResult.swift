import Foundation
import BraintreeCore

/// A result of the Edit FI flow used to display a customers updated payment details in your UI
/// - Warning: This feature is currently in beta and may change or be removed in future releases.
public class BTPayPalVaultEditResult {
    public let payerID: String? = nil
    public let email: String? = nil
    public let firstName: String? = nil
    public let lastName: String? = nil
    public let phone: String? = nil
    public let shippingAddress: BTPostalAddress? = nil
    public let fundingSourceDescription: String? = nil
    // are we geting clientMetadataID for now?
    // Where are we getting this value?
    // should be non-optional per req
    public let clientMetadataID: String? = nil
}
