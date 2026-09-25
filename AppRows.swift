import SwiftUI

// List rows. Compose these instead of hand-building HStacks: they already
// handle icon tinting, line limits, truncation and the trailing-value layout
// that grouped lists expect.

/// Icon + title + optional subtitle, with an optional trailing value.
struct AppListRow: View {
    let title: String
    var subtitle: String? = nil
    var systemImage: String? = nil
    var tint: Color = AppTheme.accent
    var value: String? = nil

    var body: some View {
        HStack(spacing: AppTheme.compactSpacing) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.body)
                    .foregroundStyle(tint)
                    .frame(width: AppTheme.iconSize, alignment: .center)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.body)
                    .foregroundStyle(AppTheme.primaryText)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppTheme.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineLimit(2)
                }
            }
            if let value {
                Spacer(minLength: AppTheme.compactSpacing)
                Text(value)
                    .font(AppTheme.monospacedValue)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .contentShape(Rectangle())
    }
}

/// A label with a right-aligned value — the standard settings/detail pairing.
struct AppValueRow: View {
    let label: String
    let value: String
    var systemImage: String? = nil

    var body: some View {
        HStack {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: AppTheme.iconSize, alignment: .center)
            }
            Text(label)
            Spacer(minLength: AppTheme.compactSpacing)
            Text(value)
                .font(AppTheme.monospacedValue)
                .foregroundStyle(AppTheme.secondaryText)
        }
    }
}

/// A row that reads as tappable inside a plain (non-Form) container.
struct AppDisclosureRow<Label: View>: View {
    @ViewBuilder let label: () -> Label
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                label()
                Spacer(minLength: AppTheme.compactSpacing)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// A completion row: tapping the leading circle toggles, tapping the row opens.
struct AppCheckRow: View {
    let title: String
    var subtitle: String? = nil
    let isComplete: Bool
    let toggle: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.compactSpacing) {
            Button(action: toggle) {
                Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isComplete ? AppTheme.positive : AppTheme.secondaryText)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .frame(minWidth: AppTheme.minimumTapTarget, alignment: .leading)
            .accessibilityLabel(isComplete ? "Mark not done" : "Mark done")

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .strikethrough(isComplete, color: AppTheme.secondaryText)
                    .foregroundStyle(isComplete ? AppTheme.secondaryText : AppTheme.primaryText)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppTheme.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

/// A section heading for plain (non-Form) layouts, with an optional action.
struct AppSectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(AppTheme.headline)
            Spacer(minLength: AppTheme.compactSpacing)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(AppTheme.callout)
            }
        }
    }
}
