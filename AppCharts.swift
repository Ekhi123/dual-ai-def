import Charts
import SwiftUI

/// One plotted point. Map domain records into these rather than making the
/// chart views generic over a model.
struct AppChartPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    var date: Date? = nil

    init(label: String, value: Double, date: Date? = nil) {
        self.label = label
        self.value = value
        self.date = date
    }
}

/// Labelled bar chart, sized for a card on a dashboard.
struct AppBarChart: View {
    let title: String
    let points: [AppChartPoint]
    var tint: Color = AppTheme.accent
    var height: CGFloat = 180

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
            Text(title).font(AppTheme.headline)
            if points.isEmpty {
                Text("Not enough data yet.")
                    .font(AppTheme.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(height: height, alignment: .center)
                    .frame(maxWidth: .infinity)
            } else {
                Chart(points) { point in
                    BarMark(
                        x: .value("Category", point.label),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(tint)
                    .cornerRadius(AppTheme.compactCornerRadius / 2)
                }
                .frame(height: height)
            }
        }
        .appCardStyle()
    }
}

/// Time-series line chart. Points must carry a `date`; those without are
/// skipped rather than plotted at an arbitrary position.
struct AppTrendChart: View {
    let title: String
    let points: [AppChartPoint]
    var tint: Color = AppTheme.accent
    var height: CGFloat = 180

    private var dated: [AppChartPoint] { points.filter { $0.date != nil } }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
            Text(title).font(AppTheme.headline)
            if dated.isEmpty {
                Text("Not enough data yet.")
                    .font(AppTheme.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(height: height, alignment: .center)
                    .frame(maxWidth: .infinity)
            } else {
                Chart(dated) { point in
                    LineMark(
                        x: .value("Date", point.date ?? .now),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(tint)
                    .interpolationMethod(.catmullRom)
                    AreaMark(
                        x: .value("Date", point.date ?? .now),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(tint.opacity(0.12))
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: height)
            }
        }
        .appCardStyle()
    }
}
