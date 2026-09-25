import SwiftUI
import SwiftData

struct TodayDashboardScreen: View {
    @Environment(AppRouter.self) private var router
    @Query(sort: \PlanItem.startTime) private var items: [PlanItem]
    @State private var focusedItem: PlanItem?
    @State private var isShowingRecommendation = false
    @State private var completionFeedback = false

    private var todayItems: [PlanItem] {
        items.filter { Calendar.current.isDateInToday($0.startTime) }
    }

    private var currentItem: PlanItem? {
        todayItems.first(where: { $0.isInProgress && !$0.isComplete })
            ?? todayItems.first(where: { $0.priority == .high && !$0.isComplete })
            ?? todayItems.first(where: { !$0.isComplete })
    }

    private var completion: Double {
        guard !todayItems.isEmpty else { return 0 }
        return Double(todayItems.filter(\.isComplete).count) / Double(todayItems.count)
    }

    private var nextItem: PlanItem? {
        todayItems.first { item in
            item.identifier != currentItem?.identifier && !item.isComplete
        }
    }

    private var plannedMinutes: Int {
        todayItems.reduce(0) { $0 + $1.totalReservedMinutes }
    }

    private var freeMinutes: Int {
        Swift.max(0, 7 * 60 - plannedMinutes)
    }

    private var conflicts: [PlanItem] {
        let ordered = todayItems.sorted { $0.startTime < $1.startTime }
        return zip(ordered, ordered.dropFirst()).compactMap { first, second in
            first.endTime > second.startTime ? second : nil
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.looseSpacing) {
                header
                progressSummary
                currentTask
                coachRecommendation
                availability
                overloadWarning
                upcomingSchedule
            }
            .appScreenPadding()
            .padding(.vertical, AppTheme.spacing)
        }
        .background(AppTheme.background)
        .navigationTitle("Today")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.push(.screen("settings"))
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .accessibilityLabel("Settings")
            }
        }
        .sheet(item: $focusedItem) { item in
            FocusModeScreen(item: item)
        }
        .sheet(isPresented: $isShowingRecommendation) {
            recommendationSheet
        }
        .sensoryFeedback(.success, trigger: completionFeedback)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
            Text("Good morning, Jordan")
                .font(AppTheme.largeTitle)
                .foregroundStyle(AppTheme.primaryText)
            Text("Make room for what moves you forward.")
                .font(AppTheme.callout)
                .foregroundStyle(AppTheme.secondaryText)
        }
    }

    private var progressSummary: some View {
        HStack(spacing: AppTheme.spacing) {
            AppProgressRing(fraction: completion, size: AppTheme.minimumTapTarget + AppTheme.spacing)
            VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
                Text("DAILY PROGRESS")
                    .font(AppTheme.caption.weight(.bold))
                    .foregroundStyle(AppTheme.secondaryText)
                Text("\(todayItems.filter(\.isComplete).count) of \(todayItems.count) complete")
                    .font(AppTheme.headline)
                    .foregroundStyle(AppTheme.primaryText)
                AppProgressBar(label: "Today", fraction: completion)
            }
        }
        .appCardStyle()
    }

    @ViewBuilder
    private var currentTask: some View {
        if let currentItem {
            VStack(alignment: .leading, spacing: AppTheme.spacing) {
                HStack {
                    AppBadge(text: currentItem.kind.rawValue, tint: AppTheme.contrastText)
                    Spacer()
                    Label(currentItem.priority.rawValue, systemImage: currentItem.priority.symbol)
                        .font(AppTheme.caption.weight(.semibold))
                }
                Text("CURRENT FOCUS")
                    .font(AppTheme.caption.weight(.bold))
                Text(currentItem.title)
                    .font(AppTheme.title)
                    .multilineTextAlignment(.leading)
                HStack {
                    Label("\(AppFormat.time(currentItem.startTime)) – \(AppFormat.time(currentItem.endTime))", systemImage: "clock")
                    Spacer()
                    Text(AppFormat.duration(TimeInterval(currentItem.durationMinutes * 60)))
                }
                .font(AppTheme.callout)
                HStack {
                    Button(currentItem.isInProgress ? "In Focus" : "Start", systemImage: currentItem.isInProgress ? "timer" : "play.fill") {
                        withAnimation(AppTheme.spring) {
                            currentItem.isInProgress = true
                            focusedItem = currentItem
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Complete", systemImage: "checkmark") {
                        complete(currentItem)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        router.push(.screen("item-\(currentItem.identifier.uuidString)"))
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .foregroundStyle(AppTheme.contrastText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppTheme.spacing)
            .background(AppTheme.contrastSurface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        } else {
            AppEmptyState(
                title: "Your day is clear",
                systemImage: "checkmark.circle",
                message: "Add a class, task, or session to build your plan."
            )
        }
    }

    private var coachRecommendation: some View {
        Button {
            isShowingRecommendation = true
        } label: {
            HStack(spacing: AppTheme.spacing) {
                Image(systemName: "sparkles")
                    .font(AppTheme.title)
                    .foregroundStyle(AppTheme.accent)
                VStack(alignment: .leading, spacing: 3) {
                    Text("What should I do?")
                        .font(AppTheme.headline)
                    Text(recommendationReason)
                        .font(AppTheme.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .appCardStyle()
        }
        .buttonStyle(.plain)
    }

    private var availability: some View {
        VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
            AppSectionHeader(title: "Available time")
            AppMetricRow {
                AppMetricTile(title: "Free today", value: AppFormat.duration(TimeInterval(freeMinutes * 60)), systemImage: "clock.badge.checkmark", tint: AppTheme.positive)
                AppMetricTile(title: "Next opening", value: nextItem.map { AppFormat.time($0.endTime) } ?? "Open", systemImage: "calendar")
            }
        }
    }

    @ViewBuilder
    private var overloadWarning: some View {
        if plannedMinutes > 7 * 60 || !conflicts.isEmpty {
            AppCard {
                VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
                    Label(
                        plannedMinutes > 7 * 60 ? "Your day is overloaded" : "Schedule conflict detected",
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .font(AppTheme.headline)
                    .foregroundStyle(AppTheme.warning)
                    Text(overloadDetail)
                        .font(AppTheme.callout)
                        .foregroundStyle(AppTheme.secondaryText)
                    Button("Reorganize Schedule") {
                        router.push(.screen("smart-plan"))
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private var upcomingSchedule: some View {
        VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
            AppSectionHeader(title: "Upcoming tasks", actionTitle: "View calendar") {
                router.push(.screen("smart-plan"))
            }
            ForEach(todayItems.filter { $0.identifier != currentItem?.identifier }) { item in
                Button {
                    router.push(.screen("item-\(item.identifier.uuidString)"))
                } label: {
                    PlanItemRow(item: item)
                }
                .buttonStyle(.plain)
                Divider()
            }
        }
    }

    private var recommendationReason: String {
        if let currentItem {
            return "\(currentItem.title) is \(currentItem.priority.rawValue.lowercased()) priority and fits your next focused block."
        }
        return "Your schedule is clear. Use this time for recovery or add your next priority."
    }

    private var overloadDetail: String {
        if plannedMinutes > 7 * 60 {
            return "Planned: \(AppFormat.duration(TimeInterval(plannedMinutes * 60))). Available: 7h 0m. Over capacity by \(AppFormat.duration(TimeInterval((plannedMinutes - 7 * 60) * 60)))."
        }
        return "\(conflicts.count) event\(conflicts.count == 1 ? "" : "s") overlaps another commitment. Review the proposed adjustment before changing your day."
    }

    @ViewBuilder
    private var recommendationSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppTheme.looseSpacing) {
                Image(systemName: "sparkles")
                    .font(.system(size: 42))
                    .foregroundStyle(AppTheme.accent)
                Text(currentItem?.title ?? "Use this free time to recover")
                    .font(AppTheme.largeTitle)
                Text(recommendationReason)
                    .font(AppTheme.body)
                    .foregroundStyle(AppTheme.secondaryText)
                if let currentItem {
                    PrimaryActionButton(title: "Start", systemImage: "play.fill") {
                        currentItem.isInProgress = true
                        isShowingRecommendation = false
                        focusedItem = currentItem
                    }
                    SecondaryActionButton(title: "View task", systemImage: "arrow.right") {
                        isShowingRecommendation = false
                        router.push(.screen("item-\(currentItem.identifier.uuidString)"))
                    }
                }
                Spacer()
            }
            .appScreenPadding()
            .padding(.vertical, AppTheme.looseSpacing)
            .navigationTitle("AI Coach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { isShowingRecommendation = false }
                }
            }
        }
    }

    private func complete(_ item: PlanItem) {
        withAnimation(AppTheme.spring) {
            item.isComplete = true
            item.isInProgress = false
            completionFeedback.toggle()
        }
    }
}