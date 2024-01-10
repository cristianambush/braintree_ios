import Foundation
import PassKit

/// The POST body for `v2/payments/find-eligible-methods`
struct BTEligiblePaymentsRequest: Encodable {
    
    private let customer: Customer
    private let purchaseUnits: [PurchaseUnit]
    private let preferences = Preferences()
    
    struct Customer: Encodable {
        let countryCode: String = "US"
        let email: String?
        let phone: Phone?
        
        enum CodingKeys: String, CodingKey {
            case countryCode = "country_code"
            case email = "email"
            case phone = "phone"
        }
    }

    struct PurchaseUnit: Encodable {
        let payee: Payee
        let amount = Amount()
        
        struct Amount: Encodable {
            let currencyCode = "USD"
            
            enum CodingKeys: String, CodingKey {
                case currencyCode = "currency_code"
            }
        }

        struct Payee: Encodable {
            let merchantID: String
            
            enum CodingKeys: String, CodingKey {
                case merchantID = "merchant_id"
            }
        }
    }
    
    struct Preferences: Encodable {
        let includeAccountDetails = true
        let includeVaultTokens = true
        let paymentSourceConstraint = PaymentSourceConstraint()
        
        enum CodingKeys: String, CodingKey {
            case includeAccountDetails = "include_account_details"
            case includeVaultTokens = "include_vault_tokens"
            case paymentSourceConstraint = "payment_source_constraint"
        }
        
        struct PaymentSourceConstraint: Encodable {
            let constraintType = "INCLUDE"
            let paymentSources = ["PAYPAL", "VENMO"]
            
            enum CodingKeys: String, CodingKey {
                case constraintType = "constraint_type"
                case paymentSources = "payment_sources"
            }
        }
    }
    
    init(email: String?, phone: Phone?, merchantID: String) {
        self.customer = Customer(email: email, phone: phone)
        self.purchaseUnits = [PurchaseUnit(payee: PurchaseUnit.Payee(merchantID: merchantID))]
    }
}
