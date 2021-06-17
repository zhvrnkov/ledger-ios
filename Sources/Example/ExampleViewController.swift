//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import Ledger
import Ion

final class ExampleViewController: UIViewController {

    private lazy var purchaseEventCollector: Collector<PurchaseInfo> = .init(source: Ledger.purchaseEventSource)
    private lazy var productInfoCollector: Collector<Product> = .init(source: Ledger.productInfoSource)

    private lazy var greetingLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private lazy var purchaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Purchase non-consumable", for: .normal)
        button.addTarget(self, action: #selector(purchaseButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var subscribeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Purchase subscription", for: .normal)
        button.addTarget(self, action: #selector(subscribeButtonPressed), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(greetingLabel)
        view.addSubview(purchaseButton)
        view.addSubview(subscribeButton)
        view.backgroundColor = .white
        checkSubscriptionStatus()

        productInfoCollector.subscribe { (product: Product) in
            print(product)
        }

        purchaseEventCollector.subscribe { (info: PurchaseInfo) in
            self.showAlert(withTitle: "Success", message: info.identifier)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        greetingLabel.sizeToFit()
        greetingLabel.center = view.center

        purchaseButton.sizeToFit()
        purchaseButton.center = .init(x: view.bounds.midX, y: 0.75 * view.bounds.height)

        subscribeButton.sizeToFit()
        subscribeButton.center = .init(x: view.bounds.midX, y: 0.25 * view.bounds.height)
    }

    @objc private func purchaseButtonPressed() {
        Ledger.purchaseProduct(withIdentifier: "com.filmm.filmm.pack.dream") { (error: Error?) in
            if let error = error {
                self.showAlert(withTitle: "Error", message: error.localizedDescription)
            }
        }
    }

    @objc private func subscribeButtonPressed() {
        Ledger.purchaseProduct(withIdentifier: "com.filmm.filmm.plus") { (error: Error?) in
            if let error = error {
                self.showAlert(withTitle: "Error", message: error.localizedDescription)
            }
        }
    }

    private func checkSubscriptionStatus() {
        greetingLabel.text = "isSubscribed: \(Ledger.isAnySubscriptionActive())"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.checkSubscriptionStatus()
        }
    }

    private func showAlert(withTitle title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: { _ in })
        controller.addAction(action)
        present(controller, animated: true, completion: nil)
    }
}
