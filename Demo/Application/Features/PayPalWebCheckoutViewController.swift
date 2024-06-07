import Foundation
import UIKit
import BraintreePayPal
import BraintreeCore

class PayPalWebCheckoutViewController: PaymentButtonBaseViewController {

    let baTokenLabel = UILabel()

    lazy var payPalClient = BTPayPalClient(
        apiClient: apiClient,
        universalLink: URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!
    )
    
    lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Buyer email:"
        return label
    }()
    
    lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "placeholder@email.com"
        textField.backgroundColor = .systemBackground
        return textField
    }()
    
    lazy var payLaterToggleLabel: UILabel = {
        let label = UILabel()
        label.text = "Offer Pay Later"
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()
    
    let payLaterToggle = UISwitch()

    lazy var newPayPalCheckoutToggleLabel: UILabel = {
        let label = UILabel()
        label.text = "New PayPal Checkout Experience"
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()
    
    let newPayPalCheckoutToggle = UISwitch()

    override func createPaymentButton() -> UIView {
        let payPalAppSwitchButton = createButton(title: "PayPal App Switch", action: #selector(tappedPayPalAppSwitch))

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        baTokenLabel.isUserInteractionEnabled = true
        baTokenLabel.addGestureRecognizer(tapGesture)
        baTokenLabel.textColor = .systemPink

        let stackView = UIStackView(arrangedSubviews: [
            buttonsStackView(label: "PayPal App Switch Flow", views: [emailTextField, payPalAppSwitchButton]),
            baTokenLabel
        ])
        
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 25
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // MARK: - 1-Time Checkout Flows

    @objc func tappedPayPalCheckout(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Checkout using BTPayPalClient")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        let request = BTPayPalCheckoutRequest(amount: "5.00")
        request.userAuthenticationEmail = emailTextField.text
        
        let lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "5.00", name: "item one 1234567", kind: .debit)
        lineItem.upcCode = "123456789"
        lineItem.upcType = .UPC_A
        lineItem.imageURL = URL(string: "https://www.example.com/example.jpg")

        request.lineItems = [lineItem]        
        request.offerPayLater = payLaterToggle.isOn
        request.intent = newPayPalCheckoutToggle.isOn ? .sale : .authorize

        payPalClient.tokenize(request) { nonce, error in
            sender.isEnabled = true

            guard let nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }

            self.completionBlock(nonce)
        }
    }
    
    // MARK: - Vault Flows
    
    @objc func tappedPayPalVault(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Vault using BTPayPalClient")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        let request = BTPayPalVaultRequest()
        request.userAuthenticationEmail = emailTextField.text

        payPalClient.tokenize(request) { nonce, error in
            sender.isEnabled = true

            guard let nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }

            self.completionBlock(nonce)
        }
    }

    @objc func tappedPayPalAppSwitch(_ sender: UIButton) {
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false
        
        guard let userEmail = emailTextField.text, !userEmail.isEmpty else {
            self.progressBlock("Email cannot be nil for App Switch flow")
            sender.isEnabled = true
            return
        }

        let request = BTPayPalVaultRequest(
            userAuthenticationEmail: userEmail,
            enablePayPalAppSwitch: true
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedNotification),
            name: Notification.Name("BAToken"),
            object: nil
        )

        payPalClient.tokenize(request) { nonce, error in
            sender.isEnabled = true
            
            guard let nonce else {
                self.progressBlock(error?.localizedDescription)
                return

            }
            
            self.completionBlock(nonce)
        }
    }

    @objc func labelTapped(sender: UITapGestureRecognizer) {
        UIPasteboard.general.string = baTokenLabel.text
    }

    @objc func receivedNotification(_ notification: Notification) {
        guard let baToken = notification.object else {
            baTokenLabel.text = "No token returned"
            return
        }

        baTokenLabel.text = "\(baToken)"
    }

    // MARK: - Helpers
    
    private func buttonsStackView(label: String, views: [UIView]) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = label
        
        let buttonsStackView = UIStackView(arrangedSubviews: [titleLabel] + views)
        buttonsStackView.axis = .vertical
        buttonsStackView.distribution = .fillProportionally
        buttonsStackView.backgroundColor = .systemGray6
        buttonsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        buttonsStackView.isLayoutMarginsRelativeArrangement = true
        
        return buttonsStackView
    }
}
