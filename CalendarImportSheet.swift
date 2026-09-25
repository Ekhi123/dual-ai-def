import SwiftUI
import SwiftData

struct CalendarImportSheet: View {
    let existingEventIdentifiers: Set<String>

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var events: [CalendarImportEvent] = []
    @State private var selectedIdentifiers: Set<String> = []
    @State private var errorMessage: String?
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Finding upcoming events…")
                } else if let errorMessage {
                    ContentUnavailableView(
                        "Calendar unavailable",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text(errorMessage)
                    )
                } else if events.isEmpty {
                    ContentUnavailableView(
                        "No new events",
                        systemImage: "calendar",
                        description: Text("Your next two weeks are already clear or imported.")
                    )
                } else {
                    List {
                        Section("Next two weeks") {
                            ForEach(events) { event in
                                Toggle(isOn: selectionBinding(for: event.id)) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(event.title)
                                        Text(AppFormat.dateTime(event.startTime))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Import Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Import \(selectedIdentifiers.count)") {
                        importSelectedEvents()
                    }
                    .disabled(selectedIdentifiers.isEmpty)
                }
            }
        }
        .task {
            await loadEvents()
        }
    }

    private func selectionBinding(for identifier: String) -> Binding<Bool> {
        Binding(
            get: { selectedIdentifiers.contains(identifier) },
            set: { isSelected in
                if isSelected {
                    selectedIdentifiers.insert(identifier)
                } else {
                    selectedIdentifiers.remove(identifier)
                }
            }
        )
    }

    @MainActor
    private func loadEvents() async {
        do {
            let importedEvents = try await PlannerCalendar.upcomingEvents()
            events = importedEvents.filter { !existingEventIdentifiers.contains($0.id) }
            selectedIdentifiers = Set(events.map(\.id))
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func importSelectedEvents() {
        for event in events where selectedIdentifiers.contains(event.id) {
            let newItem = PlanItem(
                title: event.title,
                startTime: event.startTime,
                durationMinutes: event.durationMinutes,
                kind: event.kind,
                notes: event.notes,
                reminderMinutes: 15,
                calendarEventIdentifier: event.id
            )
            modelContext.insert(newItem)
            Task {
                await PlannerNotifications.schedule(for: newItem)
            }
        }
        dismiss()
    }
}