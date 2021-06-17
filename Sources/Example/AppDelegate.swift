//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import Ledger

typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: LaunchOptions?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ExampleViewController()
        window?.makeKeyAndVisible()

        Ledger.start(sharedSecret: "1e06aba3f9ea494eadfe085966c96258")
        Ledger.debugModeReceipt = .init(purchases: [
            .init(identifier: "com.filmm.filmm.pack.dream", type: .nonConsumable)
        ])
        Ledger.fetchProducts(withIdentifiers: ["com.filmm.filmm.pack.dream", "com.filmm.filmm.plus"])

        return true
    }
}
