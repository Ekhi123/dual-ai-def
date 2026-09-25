import SwiftUI
import SwiftData

struct WeekScheduleScreen: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PlanItem.startTime) private var items: [PlanItem]
    @State private var selectedDate = Calendar.current.startOfDay(for: .now)
    @State private var displayMode: CalendarDisplayMode = .week
    @State private var isPresentingNewItem = false
    @State private var draft = PlanDraft()

    private var days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
    }

    private var selectedItems: [PlanItem] {
        items.filter { Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.looseSpacing) {
                Picker("Calendar view", selection: $displayMode) {
                    ForEach(CalendarDisplayMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppTheme.spacing)

                if displayMode == .week {
                    dayStrip
                } else {
                    monthOverview
                }
                dailyLoad
                timeline
            }
            .padding(.vertical, AppTheme.spacing)
        }
        .background(AppTheme.background)
        .navigationTitle("Calendar")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Optimize Today", systemImage: "sparkles") {
                    router.push(.screen("smart-plan"))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    draft = PlanDraft()
                    draft.startTime = selectedDate
                    isPresentingNewItem = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add calendar event")
            }
        }
        .sheet(isPresented: $isPresentingNewItem) {
            PlanItemEditorSheet(draft: $draft) {
                modelContext.insert(
                    PlanItem(
                        title: draft.title.trimmingCharacters(in: .whitespacesAndNewlines),
                        startTime: draft.startTime,
                        durationMinutes: draft.durationMinutes,
                        kind: draft.kind,
                        notes: draft.notes,
                        priority: draft.priority,
                        location: draft.location,
                        preparationMinutes: draft.preparationMinutes,
                        travelMinutes: draft.travelMinutes,
                        bufferMinutes: draft.bufferMinutes,
                        reminderMinutes: draft.reminderMinutes == 0 ? nil : draft.reminderMinutes
                    )
                )
            }
        }
    }

    private var dayStrip: some View {
        HStack(spacing: AppTheme.compactSpacing) {
            ForEach(days, id: \.self) { day in
                let selected = Calendar.current.isDate(day, inSameDayAs: selectedDate)
                Button {
                    withAnimation(AppTheme.quick) {
                        selectedDate = day
                    }
                } label: {
                    VStack(spacing: AppTheme.compactSpacing / 2) {
                        Text(AppFormat.weekday(day).prefix(1).uppercased())
                            .font(AppTheme.caption.weight(.bold))
                        Text(AppFormat.dayNumber(day))
                            .font(AppTheme.headline.monospacedDigit())
                    }
                    .foregroundStyle(selected ? AppTheme.contrastText : AppTheme.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.compactSpacing)
                    .background(
                        selected ? AppTheme.contrastSurface : AppTheme.surface,
                        in: RoundedRectangle(cornerRadius: AppTheme.compactCornerRadius)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(AppFormat.friendlyDay(day))
            }
        }
        .appScreenPadding()
    }

    private var dailyLoad: some View {
        let studyMinutes = selectedItems.filter { $0.kind == .study }.reduce(0) { $0 + $1.durationMinutes }
        let trainingMinutes = selectedItems.filter { $0.kind == .training || $0.kind == .game }.reduce(0) { $0 + $1.durationMinutes }
        return HStack {
            AppMetricRow {
                AppMetricTile(title: "Study", value: AppFormat.duration(TimeInterval(studyMinutes * 60)), systemImage: "book.closed.fill")
                AppMetricTile(title: "Training", value: AppFormat.duration(TimeInterval(trainingMinutes * 60)), systemImage: "figure.run")
            }
        }
        .appScreenPadding()
    }

    @ViewBuilder
    private var timeline: some View {
        if selectedItems.isEmpty {
            AppEmptyState(
                title: "No sessions planned",
                systemImage: "calendar.badge.plus",
                message: "Use Planner to add a class, study block, or session."
            )
        } else {
            VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
                AppSectionHeader(title: AppFormat.friendlyDay(selectedDate))
                ForEach(selectedItems) { item in
                    Button {
                        router.push(.screen("item-\(item.identifier.uuidString)"))
                    } label: {
                        PlanItemRow(item: item)
                            .padding(.horizontal, AppTheme.spacing)
                            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.compactCornerRadius))
                    }
                    .buttonStyle(.plain)
                }
            }
            .appScreenPadding()
        }
    }

    private var monthOverview: some View {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        let monthDays = (0..<28).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: AppTheme.compactSpacing), count: 7), spacing: AppTheme.compactSpacing) {
            ForEach(monthDays, id: \.self) { day in
                let count = items.filter { calendar.isDate($0.startTime, inSameDayAs: day) }.count
                Button {
                    selectedDate = day
                    displayMode = .week
                } label: {
                    VStack(spacing: 3) {
                        Text(AppFormat.dayNumber(day))
                            .font(AppTheme.callout.weight(calendar.isDateInToday(day) ? .bold : .regular))
                        if count > 0 {
                            Text("\(count)")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(AppTheme.contrastText)
                                .frame(width: 18, height: 18)
                                .background(AppTheme.accent, in: Circle())
                        } else {
                            Color.clear.frame(height: 18)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(
                        calendar.isDate(day, inSameDayAs: selectedDate) ? AppTheme.quietBlue : Color.clear,
                        in: RoundedRectangle(cornerRadius: AppTheme.compactCornerRadius)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(AppFormat.friendlyDay(day)), \(count) events")
            }
        }
        .appScreenPadding()
    }
}

private enum CalendarDisplayMode: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"

    var id: String { rawValue }
}