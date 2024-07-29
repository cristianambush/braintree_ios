import Foundation
import BraintreeCore

/// Options for the PayPal edit funding instrument flow
/// - Warning: This feature is currently in beta and may change or be removed in future releases.
public class BTPayPalVaultEditRequest {

    private let editPayPalVaultID: String
    public var merchantAccountID: String?
    public var hermesPath: String

    // MARK: - Static Properties

    static let callbackURLHostAndPath: String = "onetouch/v1/"

    //   TODO: specify endpoint for merchant to retrieve the token
    /// Initializes a PayPal Edit Request for the edit funding instrument flow
    /// - Parameters:
    ///   - editPayPalVaultID: Required: The `edit_paypal_vault_id` returned from the server side request
    /// - Warning: This feature is currently in beta and may change or be removed in future releases.
    public init(hermesPath: String, editPayPalVaultID: String, merchantAccountID: String? = nil) {
        self.hermesPath = hermesPath
        self.editPayPalVaultID = editPayPalVaultID
        self.merchantAccountID = merchantAccountID
    }

    public func parameters() -> [String: Any] {
        var parameters: [String: Any] = [:]

        if merchantAccountID != nil {
            parameters["merchant_account_id"] = merchantAccountID
        }

        parameters["return_url"] = BTCoreConstants.callbackURLScheme + "://\(BTPayPalRequest.callbackURLHostAndPath)success"
        parameters["cancel_url"] = BTCoreConstants.callbackURLScheme + "://\(BTPayPalRequest.callbackURLHostAndPath)cancel"
        parameters["edit_paypal_vault_id"] = editPayPalVaultID

        return parameters
    }
}
