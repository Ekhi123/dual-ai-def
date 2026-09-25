import SwiftUI

// Buttons, cards and small display pieces. Everything reads its colors and
// metrics from AppTheme, so retuning the theme restyles all of them.

struct PrimaryActionButton: View {
    let title: String
    var systemImage: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                } else {
                    Text(title)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.compactSpacing)
        }
        .buttonStyle(.borderedProminent)
    }
}

struct SecondaryActionButton: View {
    let title: String
    var systemImage: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                } else {
                    Text(title)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.compactSpacing)
        }
        .buttonStyle(.bordered)
    }
}

struct AppCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content().appCardStyle()
    }
}

/// A single headline number with a caption — the building block of a stat row.
struct AppMetricTile: View {
    let title: String
    let value: String
    var systemImage: String? = nil
    var tint: Color = AppTheme.accent

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.caption)
                }
                Text(title)
                    .font(AppTheme.caption)
            }
            .foregroundStyle(tint)
            Text(value)
                .font(AppTheme.title)
                .foregroundStyle(AppTheme.primaryText)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardStyle(padding: AppTheme.compactSpacing * 1.5)
    }
}

/// An evenly spaced row of metric tiles, for the top of a dashboard.
struct AppMetricRow<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(spacing: AppTheme.compactSpacing) {
            content()
        }
    }
}

struct AppBadge: View {
    let text: String
    var tint: Color = AppTheme.accent

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tint.opacity(0.15), in: Capsule())
            .foregroundStyle(tint)
    }
}

/// A selectable filter chip; a row of these is the standard list filter.
struct AppChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.callout)
                .padding(.horizontal, AppTheme.compactSpacing * 1.5)
                .padding(.vertical, AppTheme.compactSpacing * 0.75)
                .background(
                    isSelected ? AppTheme.accent : AppTheme.elevatedSurface,
                    in: Capsule()
                )
                .foregroundStyle(isSelected ? AppTheme.contrastText : AppTheme.primaryText)
        }
        .buttonStyle(.plain)
    }
}

/// Horizontally scrolling chip bar over a String-raw-value enum.
struct AppChipBar<Value>: View
where Value: CaseIterable & Hashable & RawRepresentable, Value.RawValue == String,
      Value.AllCases: RandomAccessCollection {
    @Binding var selection: Value

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: AppTheme.compactSpacing) {
                ForEach(Value.allCases, id: \.self) { value in
                    AppChip(
                        title: value.rawValue.capitalized,
                        isSelected: value == selection
                    ) {
                        withAnimation(AppTheme.quick) { selection = value }
                    }
                }
            }
            .padding(.horizontal, AppTheme.spacing)
        }
        .scrollIndicators(.hidden)
    }
}

/// Circular progress for a 0...1 fraction, with the percentage inside.
struct AppProgressRing: View {
    let fraction: Double
    var size: CGFloat = 64
    var tint: Color = AppTheme.accent

    private var clamped: Double { min(max(fraction, 0), 1) }

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.18), lineWidth: 8)
            Circle()
                .trim(from: 0, to: clamped)
                .stroke(tint, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(clamped.formatted(.percent.precision(.fractionLength(0))))
                .font(.caption.weight(.semibold).monospacedDigit())
                .contentTransition(.numericText())
        }
        .frame(width: size, height: size)
        .animation(AppTheme.spring, value: clamped)
        .accessibilityLabel("Progress")
        .accessibilityValue(clamped.formatted(.percent.precision(.fractionLength(0))))
    }
}

/// A labelled horizontal progress bar for a 0...1 fraction.
struct AppProgressBar: View {
    let label: String
    let fraction: Double
    var tint: Color = AppTheme.accent

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label).font(AppTheme.caption)
                Spacer(minLength: AppTheme.compactSpacing)
                Text(min(max(fraction, 0), 1).formatted(.percent.precision(.fractionLength(0))))
                    .font(.caption.monospacedDigit())
                    .contentTransition(.numericText())
            }
            .foregroundStyle(AppTheme.secondaryText)
            ProgressView(value: min(max(fraction, 0), 1))
                .tint(tint)
        }
        .animation(AppTheme.spring, value: fraction)
    }
}

/// Initials in a tinted circle — an avatar with no image asset.
struct AppMonogram: View {
    let text: String
    var size: CGFloat = 40
    var tint: Color = AppTheme.accent

    private var initials: String {
        let parts = text.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map(String.init)
        return letters.isEmpty ? "?" : letters.joined().uppercased()
    }

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.15), in: Circle())
    }
}
