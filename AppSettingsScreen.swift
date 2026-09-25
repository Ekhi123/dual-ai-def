import SwiftUI

/// The settings screen every app ends up needing: appearance, plus a slot for
/// whatever this product adds. Pass app-specific sections in the builder; the
/// appearance section and navigation title are already here.
///
///     AppSettingsScreen {
///         Section("Reminders") {
///             AppToggleRow(label: "Daily reminder", isOn: $store.remindsDaily)
///         }
///     }
struct AppSettingsScreen<Sections: View>: View {
    @ViewBuilder let sections: Sections

    @Environment(AppPreferences.self) private var preferences

    var body: some View {
        @Bindable var preferences = preferences
        Form {
            sections
            Section("Appearance") {
                Picker("Theme", selection: $preferences.appearance) {
                    ForEach(AppAppearance.allCases) { appearance in
                        Text(appearance.rawValue.capitalized).tag(appearance)
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }
}

/// A settings row that opens the system Settings app for this app — the right
/// destination for notification and privacy permissions, which cannot be
/// changed in-app.
struct AppSystemSettingsLink: View {
    var title: String = "Open iOS Settings"

    var body: some View {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            Link(title, destination: url)
        }
    }
}
