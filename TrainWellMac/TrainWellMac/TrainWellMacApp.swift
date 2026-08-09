import SwiftUI
import UserNotifications

@main
struct TrainWellMacApp: App {
    @StateObject private var store = TrainingStore()

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color(nsColor: .windowBackgroundColor)
                    .ignoresSafeArea()
            ContentView()
                .environmentObject(store)
            }
        }
    }
}
