import SwiftUI

struct PlanItemRow: View {
    let item: PlanItem
    var showDay: Bool = false

    var body: some View {
        HStack(spacing: AppTheme.spacing) {
            VStack(alignment: .leading, spacing: AppTheme.compactSpacing / 2) {
                if showDay {
                    Text(AppFormat.weekday(item.startTime).uppercased())
                        .font(AppTheme.caption.weight(.bold))
                }
                Text(AppFormat.time(item.startTime))
                    .font(AppTheme.caption.monospacedDigit())
            }
            .foregroundStyle(AppTheme.secondaryText)
            .frame(width: AppTheme.minimumTapTarget, alignment: .leading)

            Image(systemName: item.kind.symbol)
                .foregroundStyle(AppTheme.accent)
                .frame(width: AppTheme.iconSize)

            VStack(alignment: .leading, spacing: AppTheme.compactSpacing / 2) {
                Text(item.title)
                    .font(AppTheme.headline)
                    .foregroundStyle(item.isComplete ? AppTheme.secondaryText : AppTheme.primaryText)
                    .strikethrough(item.isComplete)
                Text("\(item.kind.rawValue) · \(AppFormat.duration(TimeInterval(item.durationMinutes * 60)))")
                    .font(AppTheme.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            Spacer(minLength: AppTheme.compactSpacing)
            if item.priority == .high {
                Image(systemName: item.priority.symbol)
                    .font(AppTheme.caption)
                    .foregroundStyle(AppTheme.accent)
            }
        }
        .padding(.vertical, AppTheme.compactSpacing)
    }
}