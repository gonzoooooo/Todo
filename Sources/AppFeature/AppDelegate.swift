import Foundation
import NotificationClient
import UIKit

public final class AppDelegate: UIResponder, UIApplicationDelegate {
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        Task {
            if await NotificationClient.shared.requestAuthorization() {
                print("granted")
            }
        }

        return true
    }
}
