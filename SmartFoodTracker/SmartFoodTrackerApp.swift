import SwiftUI
import UserNotifications

@main
struct SmartFoodTrackerApp: App {
    @StateObject private var store = Store()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onAppear {
                    UNUserNotificationCenter.current()
                        .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
                }
        }
    }
}

