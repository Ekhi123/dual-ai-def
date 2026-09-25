import SwiftUI

struct PlannerSettingsScreen: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        AppSettingsScreen {
            Section("Notifications") {
                AppValueRow(label: "Plan item reminders", value: "Set per item", systemImage: "bell.badge")
                AppSystemSettingsLink(title: "Notification settings")
            }
            Section("Sharing") {
                Button {
                    router.push(.screen("sharing"))
                } label: {
                    AppListRow(
                        title: "Share your plan",
                        subtitle: "Send a schedule snapshot to a teammate or another device.",
                        systemImage: "square.and.arrow.up"
                    )
                }
            }
            Section("About") {
                AppValueRow(label: "Focus", value: "Student-athlete")
            }
        }
    }
}