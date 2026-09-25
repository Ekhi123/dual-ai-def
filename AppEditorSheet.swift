import SwiftUI

/// The add/edit sheet scaffold: navigation title, Cancel, and a Save that
/// disables itself until the content is valid. Wrap the form fields and pass
/// `canSave`; the sheet owns dismissal so no screen repeats that wiring.
///
///     .sheet(isPresented: $isAdding) {
///         AppEditorSheet(title: "New Task", canSave: !draft.title.isEmpty) {
///             store.add(draft)
///         } content: {
///             AppTextFieldRow(label: "Title", text: $draft.title)
///         }
///     }
struct AppEditorSheet<Content: View>: View {
    let title: String
    var saveTitle: String = "Save"
    var canSave: Bool = true
    let save: () -> Void
    @ViewBuilder let content: () -> Content

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                content()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(saveTitle) {
                        save()
                        dismiss()
                    }
                    .disabled(!canSave)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

/// A confirmation for destructive actions, so screens don't each write one.
extension View {
    func appDeleteConfirmation(
        _ title: String,
        isPresented: Binding<Bool>,
        delete: @escaping () -> Void
    ) -> some View {
        confirmationDialog(title, isPresented: isPresented, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: delete)
            Button("Cancel", role: .cancel) {}
        }
    }
}
