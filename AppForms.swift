import SwiftUI

// Form fields for add/edit screens. Each is a `Form`/`Section` row already
// wired for keyboard type, submit behaviour and accessibility, so an editor
// screen is a list of these plus a save action.

struct AppTextFieldRow: View {
    let label: String
    @Binding var text: String
    var prompt: String? = nil
    var axis: Axis = .horizontal
    var contentType: UITextContentType? = nil
    var keyboard: UIKeyboardType = .default
    var capitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        TextField(
            label,
            text: $text,
            prompt: prompt.map { Text($0) },
            axis: axis
        )
        .textContentType(contentType)
        .keyboardType(keyboard)
        .textInputAutocapitalization(capitalization)
        .autocorrectionDisabled(keyboard == .emailAddress || keyboard == .URL)
    }
}

/// Multi-line notes field with a minimum height, for a `Section`.
struct AppNotesRow: View {
    let label: String
    @Binding var text: String
    var minHeight: CGFloat = 96

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(AppTheme.caption)
                .foregroundStyle(AppTheme.secondaryText)
            TextEditor(text: $text)
                .frame(minHeight: minHeight)
                .scrollContentBackground(.hidden)
        }
    }
}

struct AppToggleRow: View {
    let label: String
    var systemImage: String? = nil
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            if let systemImage {
                Label(label, systemImage: systemImage)
            } else {
                Text(label)
            }
        }
    }
}

struct AppStepperRow: View {
    let label: String
    @Binding var value: Int
    var range: ClosedRange<Int> = 0...99
    var unit: String? = nil

    var body: some View {
        Stepper(value: $value, in: range) {
            HStack {
                Text(label)
                Spacer(minLength: AppTheme.compactSpacing)
                Text(unit.map { "\(value) \($0)" } ?? "\(value)")
                    .font(AppTheme.monospacedValue)
                    .foregroundStyle(AppTheme.secondaryText)
                    .contentTransition(.numericText())
            }
        }
    }
}

struct AppDateRow: View {
    let label: String
    @Binding var date: Date
    var components: DatePickerComponents = [.date]
    var range: PartialRangeFrom<Date>? = nil

    var body: some View {
        if let range {
            DatePicker(label, selection: $date, in: range, displayedComponents: components)
        } else {
            DatePicker(label, selection: $date, displayedComponents: components)
        }
    }
}

/// Inline picker over any `CaseIterable` enum whose raw value is a String.
struct AppEnumPickerRow<Value>: View
where Value: CaseIterable & Hashable & RawRepresentable, Value.RawValue == String,
      Value.AllCases: RandomAccessCollection {
    let label: String
    @Binding var selection: Value

    var body: some View {
        Picker(label, selection: $selection) {
            ForEach(Value.allCases, id: \.self) { value in
                Text(value.rawValue.capitalized).tag(value)
            }
        }
    }
}

/// A destructive row for delete actions inside a `Form`.
struct AppDeleteRow: View {
    var title: String = "Delete"
    let action: () -> Void

    var body: some View {
        Button(role: .destructive, action: action) {
            HStack {
                Spacer()
                Text(title)
                Spacer()
            }
        }
    }
}
