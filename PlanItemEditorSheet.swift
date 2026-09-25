import SwiftUI

struct PlanItemEditorSheet: View {
    @Binding var draft: PlanDraft
    let save: () -> Void

    var body: some View {
        AppEditorSheet(
            title: "New plan item",
            canSave: !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            save: save
        ) {
            Section("Plan") {
                AppTextFieldRow(label: "Title", text: $draft.title, prompt: "What needs your focus?")
                AppEnumPickerRow(label: "Type", selection: $draft.kind)
                AppEnumPickerRow(label: "Priority", selection: $draft.priority)
                AppDateRow(label: "Start", date: $draft.startTime, components: [.date, .hourAndMinute])
                AppStepperRow(label: "Duration", value: $draft.durationMinutes, range: 15...240, unit: "min")
                AppStepperRow(label: "Reminder", value: $draft.reminderMinutes, range: 0...120, unit: "min before")
            }
            Section("Details") {
                AppTextFieldRow(label: "Location", text: $draft.location, prompt: "Optional")
                AppStepperRow(label: "Preparation", value: $draft.preparationMinutes, range: 0...90, unit: "min")
                AppStepperRow(label: "Travel", value: $draft.travelMinutes, range: 0...180, unit: "min")
                AppStepperRow(label: "Buffer", value: $draft.bufferMinutes, range: 0...60, unit: "min")
                AppNotesRow(label: "Notes", text: $draft.notes)
            }
        }
    }
}