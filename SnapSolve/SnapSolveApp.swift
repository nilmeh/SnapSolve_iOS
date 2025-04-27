import SwiftUI
import SwiftData
import FirebaseCore

@main
struct SnapSolveApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate   // <-- Add this line

    @StateObject private var sessionManager = SessionManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if sessionManager.isLoggedIn {
                ContentView()
                    .environmentObject(sessionManager)
            } else {
                AuthView()
                    .environmentObject(sessionManager)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
