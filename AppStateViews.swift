import SwiftUI

// Every screen that can be empty, loading or broken uses these rather than a
// blank view — the first-impression rule in the ios-app skill.

/// Empty state with an SF Symbol and an optional primary action.
struct AppEmptyState: View {
    let title: String
    let systemImage: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        } actions: {
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

/// A search that matched nothing — distinct from "no data yet".
struct AppNoSearchResults: View {
    let query: String

    var body: some View {
        ContentUnavailableView.search(text: query)
    }
}

struct AppLoadingState: View {
    var message: String = "Loading…"

    var body: some View {
        VStack(spacing: AppTheme.spacing) {
            ProgressView()
            Text(message)
                .font(AppTheme.callout)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// A recoverable failure with a retry. Use for work that can be retried, not
/// as a placeholder for a feature that was never built.
struct AppErrorState: View {
    let message: String
    var retry: (() -> Void)? = nil

    var body: some View {
        ContentUnavailableView {
            Label("Something went wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            if let retry {
                Button("Try Again", action: retry)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}
