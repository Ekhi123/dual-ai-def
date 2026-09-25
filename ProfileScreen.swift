import SwiftUI
import SwiftData

struct ProfileScreen: View {
    @AppStorage("profile.name") private var name = "Jordan Lee"
    @AppStorage("profile.university") private var university = "Northbridge University"
    @AppStorage("profile.sport") private var sport = "Basketball"
    @AppStorage("profile.team") private var team = "Northbridge Hawks"
    @AppStorage("profile.level") private var level = "NCAA D1"
    @AppStorage("profile.degree") private var degree = "Kinesiology"
    @AppStorage("profile.studyDuration") private var studyDuration = 45
    @AppStorage("profile.notifications") private var notificationsEnabled = true
    @AppStorage("profile.coachNotifications") private var coachNotificationsEnabled = true
    @AppStorage("profile.canvasDemoImported") private var canvasDemoImported = false
    @State private var isPresentingCanvas = false
    @State private var selectedPlan = "Annual"
    @State private var isShowingPurchaseConfirmation = false

    var body: some View {
        List {
            Section {
                HStack(spacing: AppTheme.spacing) {
                    AppMonogram(text: name, size: 58)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(name)
                            .font(AppTheme.title)
                        Text("\(sport) · \(university)")
                            .font(AppTheme.callout)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
                .padding(.vertical, AppTheme.compactSpacing)
            }

            Section("Personal") {
                TextField("Name", text: $name)
                TextField("University", text: $university)
                TextField("Degree or program", text: $degree)
                AppValueRow(label: "Academic year", value: "Sophomore", systemImage: "graduationcap")
            }

            Section("Athlete") {
                TextField("Sport", text: $sport)
                TextField("Team", text: $team)
                Picker("Competitive level", selection: $level) {
                    ForEach(["NCAA D1", "NCAA D2", "NCAA D3", "NAIA", "Other"], id: \.self) { level in
                        Text(level).tag(level)
                    }
                }
                AppValueRow(label: "Training", value: "Mon–Fri · 5:00 PM", systemImage: "figure.run")
                AppValueRow(label: "Next game", value: "Sunday · 1:00 PM", systemImage: "sportscourt")
            }

            Section("Academic") {
                AppValueRow(label: "Courses", value: "5 active", systemImage: "books.vertical")
                Button {
                    isPresentingCanvas = true
                } label: {
                    AppListRow(
                        title: "Canvas",
                        subtitle: canvasDemoImported ? "Sample assignments added locally" : "Preview a local course import",
                        systemImage: "rectangle.connected.to.line.below",
                        tint: AppTheme.accent
                    )
                }
            }

            Section("Study & Recovery") {
                Stepper(value: $studyDuration, in: 25...120, step: 5) {
                    AppValueRow(label: "Preferred study session", value: "\(studyDuration) min", systemImage: "timer")
                }
                AppValueRow(label: "Study window", value: "Afternoon", systemImage: "sun.max")
                AppValueRow(label: "Sleep protection", value: "10:45 PM–7:00 AM", systemImage: "bed.double")
                AppValueRow(label: "Your pattern", value: "Longer sessions after 4 PM", systemImage: "chart.line.uptrend.xyaxis")
            }

            Section("Integrations") {
                AppValueRow(label: "Apple Calendar", value: "Available to import", systemImage: "calendar")
                AppValueRow(label: "Google Calendar", value: "Not connected", systemImage: "g.circle")
                AppValueRow(label: "Team Calendar", value: "Local schedule", systemImage: "person.3")
            }

            Section("Notifications") {
                Toggle("Task and event reminders", isOn: $notificationsEnabled)
                Toggle("AI Coach recommendations", isOn: $coachNotificationsEnabled)
                AppValueRow(label: "Overdue task alerts", value: "On", systemImage: "exclamationmark.badge")
            }

            Section {
                Picker("Plan", selection: $selectedPlan) {
                    Text("Monthly").tag("Monthly")
                    Text("Annual").tag("Annual")
                }
                .pickerStyle(.segmented)
                Button("Continue \(selectedPlan)") {
                    isShowingPurchaseConfirmation = true
                }
                .buttonStyle(.borderedProminent)
            } header: {
                Text("Dual AI Plus")
            } footer: {
                Text("Prototype purchase selection only. No payment is processed.")
            }
        }
        .navigationTitle("Profile")
        .sheet(isPresented: $isPresentingCanvas) {
            CanvasIntegrationSheet(didImportSample: $canvasDemoImported)
        }
        .alert("Plan selected", isPresented: $isShowingPurchaseConfirmation) {
            Button("Done", role: .cancel) {}
        } message: {
            Text("\(selectedPlan) is selected for this prototype. No charge has been made.")
        }
    }
}

struct CanvasIntegrationSheet: View {
    @Binding var didImportSample: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                Section {
                    AppListRow(
                        title: "Canvas preview",
                        subtitle: "This local prototype previews a typical Canvas import. No Canvas account is connected.",
                        systemImage: "rectangle.connected.to.line.below"
                    )
                }

                Section("Sample import") {
                    AppValueRow(label: "BIOL 214", value: "Lab report · Tomorrow", systemImage: "testtube.2")
                    AppValueRow(label: "ECON 201", value: "Problem set · Friday", systemImage: "function")
                    AppValueRow(label: "HIST 106", value: "Reading · Monday", systemImage: "book.closed")
                }
            }
            .navigationTitle("Connect Canvas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(didImportSample ? "Added" : "Add sample assignments") {
                        addSampleAssignments()
                        dismiss()
                    }
                    .disabled(didImportSample)
                }
            }
        }
    }

    private func addSampleAssignments() {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now) ?? .now
        let friday = calendar.nextDate(after: .now, matching: DateComponents(weekday: 6), matchingPolicy: .nextTime) ?? tomorrow
        let monday = calendar.nextDate(after: .now, matching: DateComponents(weekday: 2), matchingPolicy: .nextTime) ?? tomorrow
        modelContext.insert(PlanItem(title: "Canvas: Biology lab report", startTime: tomorrow, durationMinutes: 60, kind: .assignment, notes: "Demo Canvas import.", priority: .high))
        modelContext.insert(PlanItem(title: "Canvas: Economics problem set", startTime: friday, durationMinutes: 45, kind: .homework, notes: "Demo Canvas import.", priority: .medium))
        modelContext.insert(PlanItem(title: "Canvas: History reading", startTime: monday, durationMinutes: 40, kind: .study, notes: "Demo Canvas import.", priority: .low))
        didImportSample = true
    }
}