import SwiftUI
import SwiftData

struct PlannerSharingScreen: View {
    @Query(sort: \PlanItem.startTime) private var items: [PlanItem]

    private var shareText: String {
        let upcomingItems = items
            .filter { $0.endTime >= .now }
            .prefix(12)

        let entries = upcomingItems.map { item in
            "• \(AppFormat.dateTime(item.startTime)) — \(item.title) (\(item.kind.rawValue))"
        }
        return (["My AI Smart Planner schedule"] + entries).joined(separator: "\n")
    }

    var body: some View {
        List {
            Section {
                ShareLink(item: shareText) {
                    Label("Share upcoming plan", systemImage: "square.and.arrow.up")
                }
            } footer: {
                Text("Send a readable snapshot through Messages, Mail, AirDrop, or another sharing app.")
            }

            Section("Sharing status") {
                AppValueRow(label: "This device", value: "Ready", systemImage: "iphone")
                AppValueRow(label: "Live team plan", value: "Needs cloud data", systemImage: "person.2")
            }
        }
        .navigationTitle("Share Plan")
        .navigationBarTitleDisplayMode(.inline)
    }
}