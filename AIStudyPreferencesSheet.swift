import SwiftUI

struct AIStudyPreferencesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("study.weeklyMinutes") private var weeklyMinutes = 480
    @AppStorage("study.dailyMaximum") private var dailyMaximum = 120
    @AppStorage("study.preferredSession") private var preferredSession = 45
    @AppStorage("study.minimumSession") private var minimumSession = 25
    @AppStorage("study.timePreference") private var timePreference = "Afternoon"
    @State private var preferredDays: Set<String> = ["Mon", "Tue", "Wed", "Thu", "Fri"]
    @State private var noStudyDays: Set<String> = ["Sun"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Study target") {
                    Stepper("Weekly study time: \(AppFormat.duration(TimeInterval(weeklyMinutes * 60)))", value: $weeklyMinutes, in: 60...1_260, step: 30)
                    Stepper("Maximum per day: \(AppFormat.duration(TimeInterval(dailyMaximum * 60)))", value: $dailyMaximum, in: 30...300, step: 15)
                    Stepper("Preferred session: \(preferredSession) min", value: $preferredSession, in: 25...120, step: 5)
                    Stepper("Minimum session: \(minimumSession) min", value: $minimumSession, in: 15...60, step: 5)
                }

                Section("When you study best") {
                    Picker("Preferred time", selection: $timePreference) {
                        ForEach(["Morning", "Afternoon", "Evening", "Custom"], id: \.self) { time in
                            Text(time).tag(time)
                        }
                    }
                    dayPicker(title: "Preferred days", selection: $preferredDays)
                    dayPicker(title: "No-study days", selection: $noStudyDays)
                }

                Section {
                    Text("Dual AI will use these limits with training, travel, sleep, and existing calendar events when it proposes study sessions.")
                        .font(AppTheme.callout)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .navigationTitle("Study Planning")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func dayPicker(title: String, selection: Binding<Set<String>>) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
            Text(title)
            HStack(spacing: 4) {
                ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                    if selection.wrappedValue.contains(day) {
                        Button(day) {
                            selection.wrappedValue.remove(day)
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.caption)
                    } else {
                        Button(day) {
                            selection.wrappedValue.insert(day)
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                    }
                }
            }
        }
    }
}