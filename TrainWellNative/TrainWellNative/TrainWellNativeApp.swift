import SwiftUI
import UserNotifications

#if os(iOS) && !targetEnvironment(macCatalyst)
import UIKit

@main
final class TrainWellNativeApp: UIResponder, UIApplicationDelegate {
    private let store = TrainingStore()
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .systemBackground
        window.rootViewController = UIHostingController(
            rootView: ContentView()
                .environmentObject(store)
        )
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
#else
@main
struct TrainWellNativeApp: App {
    @StateObject private var store = TrainingStore()

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
            ContentView()
                .environmentObject(store)
            }
        }
    }
}
#endif
