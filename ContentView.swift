import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: PlannerTab = .dashboard
    @State private var didSeed = false

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            TabView(selection: $selectedTab) {
                TodayDashboardScreen()
                    .tabItem { Label("Dashboard", systemImage: "house.fill") }
                    .tag(PlannerTab.dashboard)

                WeekScheduleScreen()
                    .tabItem { Label("Calendar", systemImage: "calendar") }
                    .tag(PlannerTab.calendar)

                PlannerScreen()
                    .tabItem { Label("AI Planner", systemImage: "sparkles") }
                    .tag(PlannerTab.aiPlanner)

                ProfileScreen()
                    .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                    .tag(PlannerTab.profile)
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            .navigationDestination(for: AppRoute.self) { route in
                routeDestination(for: route)
            }
        }
        .task {
            guard !didSeed else { return }
            PlannerSeed.insertIfNeeded(in: modelContext)
            didSeed = true
        }
    }

    @ViewBuilder
    private func routeDestination(for route: AppRoute) -> some View {
        switch route {
        case let .screen(identifier):
            if identifier == "settings" {
                PlannerSettingsScreen()
            } else if identifier == "sharing" {
                PlannerSharingScreen()
            } else if identifier == "smart-plan" {
                SmartPlanScreen()
            } else if identifier == "weekly-review" {
                WeeklyReviewScreen()
            } else if identifier.hasPrefix("item-"),
                      let id = UUID(uuidString: String(identifier.dropFirst("item-".count))) {
                PlanItemDestination(id: id)
            } else {
                AppErrorState(message: "This planner page is unavailable.")
            }
        }
    }
}

private enum PlannerTab: Hashable {
    case dashboard
    case calendar
    case aiPlanner
    case profile
}
