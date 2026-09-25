import SwiftUI

struct FocusModeScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: PlanItem
    @State private var startedAt = Date.now
    @State private var pausedAt: Date?
    @State private var accumulatedPause: TimeInterval = 0
    @State private var didComplete = false

    private var totalSeconds: TimeInterval {
        TimeInterval(item.durationMinutes * 60)
    }

    private var elapsed: TimeInterval {
        let activeEnd = pausedAt ?? .now
        return Swift.max(0, activeEnd.timeIntervalSince(startedAt) - accumulatedPause)
    }

    private var remaining: TimeInterval {
        Swift.max(0, totalSeconds - elapsed)
    }

    private var progress: Double {
        guard totalSeconds > 0 else { return 1 }
        return Swift.min(1, elapsed / totalSeconds)
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { _ in
            VStack(spacing: AppTheme.looseSpacing) {
                Spacer()
                AppBadge(text: item.kind.rawValue.uppercased(), tint: AppTheme.accent)
                Text(item.title)
                    .font(AppTheme.largeTitle)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.primaryText)
                    .padding(.horizontal, AppTheme.looseSpacing)
                AppProgressRing(fraction: progress, size: 156, tint: AppTheme.accent)
                Text(AppFormat.duration(remaining))
                    .font(.system(size: 48, weight: .bold, design: .rounded).monospacedDigit())
                    .contentTransition(.numericText())
                Text(pausedAt == nil ? "Stay with this one thing." : "Paused")
                    .font(AppTheme.callout)
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
                HStack(spacing: AppTheme.spacing) {
                    Button(pausedAt == nil ? "Pause" : "Resume") {
                        togglePause()
                    }
                    .buttonStyle(.bordered)

                    Button("Complete", systemImage: "checkmark") {
                        complete()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.bottom, AppTheme.looseSpacing)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(AppTheme.spacing)
            .background(AppTheme.background)
        }
        .sensoryFeedback(.success, trigger: didComplete)
    }

    private func togglePause() {
        if let pausedAt {
            accumulatedPause += Date.now.timeIntervalSince(pausedAt)
            self.pausedAt = nil
        } else {
            pausedAt = .now
        }
    }

    private func complete() {
        withAnimation(AppTheme.spring) {
            item.isComplete = true
            item.isInProgress = false
            didComplete.toggle()
        }
        dismiss()
    }
}