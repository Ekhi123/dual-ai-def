import SwiftUI
import SwiftData

@main
struct GeneratedApp: App {
    @State private var router = AppRouter()
    @State private var preferences = AppPreferences()
    private let modelContainer: ModelContainer = {
        do {
            return try AppPersistence.container(for: PlanItem.self)
        } catch {
            fatalError("Unable to create the planner data store: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(router)
                .environment(preferences)
                .tint(AppTheme.accent)
                .preferredColorScheme(preferences.appearance.colorScheme)
        }
        .modelContainer(modelContainer)
    }
}
