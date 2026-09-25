import SwiftUI
import SwiftData

struct PlanItemDetailScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: PlanItem
    @State private var isEditing = false
    @State private var isConfirmingDelete = false
    @State private var draft = PlanDraft()

    var body: some View {
        List {
            Section {
                AppValueRow(label: "When", value: AppFormat.dateTime(item.startTime), systemImage: "calendar")
                AppValueRow(label: "Duration", value: AppFormat.duration(TimeInterval(item.durationMinutes * 60)), systemImage: "clock")
                AppValueRow(label: "Type", value: item.kind.rawValue, systemImage: item.kind.symbol)
                AppValueRow(label: "Priority", value: item.priority.rawValue, systemImage: item.priority.symbol)
                if !item.location.isEmpty {
                    AppValueRow(label: "Location", value: item.location, systemImage: "mappin.and.ellipse")
                }
                if item.preparationMinutes > 0 {
                    AppValueRow(label: "Preparation", value: "\(item.preparationMinutes) min", systemImage: "figure.dress.line.vertical.figure")
                }
                if item.travelMinutes > 0 {
                    AppValueRow(label: "Travel", value: "\(item.travelMinutes) min", systemImage: "car.fill")
                }
                if item.bufferMinutes > 0 {
                    AppValueRow(label: "Buffer", value: "\(item.bufferMinutes) min", systemImage: "hourglass")
                }
                if let reminderMinutes = item.reminderMinutes, reminderMinutes > 0 {
                    AppValueRow(label: "Reminder", value: "\(reminderMinutes) min before", systemImage: "bell.badge")
                }
            }

            if !item.notes.isEmpty {
                Section("Notes") {
                    Text(item.notes)
                        .foregroundStyle(AppTheme.primaryText)
                }
            }

            Section {
                Toggle("Completed", isOn: $item.isComplete)
                Button {
                    withAnimation(AppTheme.spring) {
                        item.startTime = item.startTime.addingTimeInterval(30 * 60)
                    }
                } label: {
                    Label("Move 30 minutes later", systemImage: "arrow.right.circle")
                }
                Button {
                    let duplicate = PlanItem(
                        title: "\(item.title) copy",
                        startTime: item.startTime.addingTimeInterval(24 * 60 * 60),
                        durationMinutes: item.durationMinutes,
                        kind: item.kind,
                        notes: item.notes,
                        priority: item.priority,
                        location: item.location,
                        preparationMinutes: item.preparationMinutes,
                        travelMinutes: item.travelMinutes,
                        bufferMinutes: item.bufferMinutes,
                        reminderMinutes: item.reminderMinutes
                    )
                    modelContext.insert(duplicate)
                } label: {
                    Label("Duplicate for tomorrow", systemImage: "plus.square.on.square")
                }
                AppDeleteRow {
                    isConfirmingDelete = true
                }
            }
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    draft = PlanDraft(item: item)
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            PlanItemEditorSheet(draft: $draft) {
                item.title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
                item.startTime = draft.startTime
                item.durationMinutes = draft.durationMinutes
                item.kind = draft.kind
                item.notes = draft.notes
                item.priority = draft.priority
                item.location = draft.location
                item.preparationMinutes = draft.preparationMinutes
                item.travelMinutes = draft.travelMinutes
                item.bufferMinutes = draft.bufferMinutes
                item.reminderMinutes = draft.reminderMinutes == 0 ? nil : draft.reminderMinutes
                Task {
                    await PlannerNotifications.schedule(for: item)
                }
            }
        }
        .appDeleteConfirmation("Delete this plan item?", isPresented: $isConfirmingDelete) {
            let identifier = item.identifier
            modelContext.delete(item)
            Task {
                await PlannerNotifications.remove(for: identifier)
            }
            dismiss()
        }
    }
}