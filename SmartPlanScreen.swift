import SwiftUI
import SwiftData

struct SmartPlanScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PlanItem.startTime) private var items: [PlanItem]
    @State private var isAnalyzing = false
    @State private var planReady = false
    @State private var didApplyPlan = false
    @State private var didRejectPlan = false
    @State private var appliedItem: PlanItem?
    @State private var isShowingWhy = false

    private var openPriorityItems: [PlanItem] {
        items.filter { $0.priority == .high && !$0.isComplete }
    }

    private var nextStudyBlock: Date {
        let calendar = Calendar.current
        let base = calendar.date(byAdding: .hour, value: 1, to: .now) ?? .now
        let hour = calendar.component(.hour, from: base)
        return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: base) ?? base
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.looseSpacing) {
                hero
                if isAnalyzing {
                    analyzingState
                } else if didRejectPlan {
                    AppEmptyState(
                        title: "No changes made",
                        systemImage: "checkmark.circle",
                        message: "Your existing schedule stays in place. You can generate another proposal whenever priorities change.",
                        actionTitle: "Generate another plan"
                    ) {
                        didRejectPlan = false
                        generatePlan()
                    }
                } else if planReady {
                    proposal
                } else {
                    recommendations
                    PrimaryActionButton(title: "Generate schedule proposal", systemImage: "sparkles") {
                        generatePlan()
                    }
                }
            }
            .appScreenPadding()
            .padding(.vertical, AppTheme.spacing)
        }
        .background(AppTheme.background)
        .navigationTitle("Smart Plan")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingWhy) {
            whySheet
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing) {
            Image(systemName: "sparkles")
                .font(AppTheme.title)
            Text("Protect your\nhighest-impact work.")
                .font(AppTheme.largeTitle)
            Text("Your plan keeps school and training in balance by placing priority work ahead of your busiest sessions.")
                .font(AppTheme.callout)
        }
        .foregroundStyle(AppTheme.contrastText)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.looseSpacing)
        .background(AppTheme.contrastSurface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    private var recommendations: some View {
        VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
            AppSectionHeader(title: "Today’s adjustment")
            if let priority = openPriorityItems.first {
                AppCard {
                    VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
                        AppBadge(text: "PRIORITY")
                        Text(priority.title)
                            .font(AppTheme.headline)
                        Text("Schedule a focused block before training so this is finished without squeezing recovery.")
                            .font(AppTheme.callout)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
            } else {
                AppCard {
                    AppListRow(
                        title: "Your priorities are covered",
                        subtitle: "Add a priority item when you want a smarter scheduling suggestion.",
                        systemImage: "checkmark.seal.fill",
                        tint: AppTheme.positive
                    )
                }
            }
        }
    }

    private var analyzingState: some View {
        VStack(spacing: AppTheme.spacing) {
            ProgressView()
                .controlSize(.large)
            Text("Analyzing your schedule…")
                .font(AppTheme.headline)
            Text("Checking deadlines, training, travel, recovery, and open study windows.")
                .font(AppTheme.callout)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .appCardStyle(padding: AppTheme.looseSpacing)
    }

    private var proposal: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing) {
            AppSectionHeader(title: didApplyPlan ? "Schedule updated" : "Proposed changes")
            AppCard {
                VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
                    Label("Protect \(openPriorityItems.first?.title ?? "your highest-priority task")", systemImage: "bolt.fill")
                        .font(AppTheme.headline)
                    Text("Add a focused 45-minute study block before the next training commitment.")
                        .font(AppTheme.callout)
                        .foregroundStyle(AppTheme.secondaryText)
                    Label("Add a 15-minute recovery buffer after practice", systemImage: "heart.text.square")
                    Label("Keep protected sleep and existing training unchanged", systemImage: "bed.double.fill")
                }
            }
            Button("Why this change?") {
                isShowingWhy = true
            }
            .buttonStyle(.bordered)

            if didApplyPlan {
                SecondaryActionButton(title: "Undo", systemImage: "arrow.uturn.backward") {
                    undoPlan()
                }
            } else {
                HStack {
                    Button("Reject", role: .cancel) {
                        didRejectPlan = true
                        planReady = false
                    }
                    .buttonStyle(.bordered)
                    Button("Accept Changes", systemImage: "checkmark") {
                        applyPlan()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }

    private var whySheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppTheme.spacing) {
                Text("Why this change?")
                    .font(AppTheme.title)
                Text("Your highest-priority work is still open, and the proposal protects a focused block before the next training commitment. It keeps your existing training, recovery, and sleep periods in place.")
                    .font(AppTheme.body)
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
            }
            .appScreenPadding()
            .padding(.vertical, AppTheme.looseSpacing)
            .navigationTitle("AI transparency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { isShowingWhy = false }
                }
            }
        }
    }

    private func generatePlan() {
        isAnalyzing = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            isAnalyzing = false
            planReady = true
        }
    }

    private func applyPlan() {
        guard !didApplyPlan else { return }
        let item = PlanItem(
            title: "Dual AI focus block",
            startTime: nextStudyBlock,
            durationMinutes: 45,
            kind: .study,
            notes: "Accepted schedule proposal: protects high-priority work before training.",
            priority: .high,
            bufferMinutes: 15
        )
        withAnimation(AppTheme.spring) {
            modelContext.insert(item)
            appliedItem = item
            didApplyPlan = true
        }
    }

    private func undoPlan() {
        guard let appliedItem else { return }
        withAnimation(AppTheme.spring) {
            modelContext.delete(appliedItem)
            self.appliedItem = nil
            didApplyPlan = false
        }
    }
}