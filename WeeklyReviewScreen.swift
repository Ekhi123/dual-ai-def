import SwiftUI
import SwiftData

struct WeeklyReviewScreen: View {
    @Query(sort: \PlanItem.startTime) private var items: [PlanItem]
    @State private var didApplyRecommendations = false

    private var weekItems: [PlanItem] {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: .now)) ?? .now
        return items.filter { $0.startTime >= start && $0.startTime <= .now }
    }

    private var studyMinutes: Int {
        weekItems.filter { $0.kind == .study }.reduce(0) { $0 + $1.durationMinutes }
    }

    private var trainingMinutes: Int {
        weekItems.filter { $0.kind == .training || $0.kind == .game }.reduce(0) { $0 + $1.durationMinutes }
    }

    private var completion: Double {
        guard !weekItems.isEmpty else { return 0 }
        return Double(weekItems.filter(\.isComplete).count) / Double(weekItems.count)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.looseSpacing) {
                AppMetricRow {
                    AppMetricTile(title: "Study", value: AppFormat.duration(TimeInterval(studyMinutes * 60)), systemImage: "book.closed.fill")
                    AppMetricTile(title: "Training", value: AppFormat.duration(TimeInterval(trainingMinutes * 60)), systemImage: "figure.run")
                }
                AppMetricRow {
                    AppMetricTile(title: "Completed", value: "\(weekItems.filter(\.isComplete).count)", systemImage: "checkmark.circle.fill", tint: AppTheme.positive)
                    AppMetricTile(title: "Plan kept", value: AppFormat.percent(completion), systemImage: "chart.line.uptrend.xyaxis")
                }
                AppBarChart(
                    title: "Study consistency",
                    points: [
                        AppChartPoint(label: "M", value: 45),
                        AppChartPoint(label: "T", value: 75),
                        AppChartPoint(label: "W", value: 60),
                        AppChartPoint(label: "T", value: 90),
                        AppChartPoint(label: "F", value: 45)
                    ]
                )
                insights
                PrimaryActionButton(
                    title: didApplyRecommendations ? "Recommendations applied" : "Apply recommendations",
                    systemImage: didApplyRecommendations ? "checkmark" : "sparkles"
                ) {
                    withAnimation(AppTheme.spring) {
                        didApplyRecommendations = true
                    }
                }
                .disabled(didApplyRecommendations)
            }
            .appScreenPadding()
            .padding(.vertical, AppTheme.spacing)
        }
        .background(AppTheme.background)
        .navigationTitle("Weekly Review")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var insights: some View {
        VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
            AppSectionHeader(title: "Weekly insights")
            AppCard {
                VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
                    Label("You completed \(AppFormat.percent(completion)) of planned tasks.", systemImage: "checkmark.seal.fill")
                    Label("Your longest focused work lands between 4 PM and 7 PM.", systemImage: "clock.arrow.circlepath")
                    Label("Protect a 45-minute recovery block after game days.", systemImage: "heart.text.square")
                }
                .font(AppTheme.callout)
                .foregroundStyle(AppTheme.primaryText)
            }
        }
    }
}