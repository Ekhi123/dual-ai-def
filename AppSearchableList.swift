import SwiftUI

/// A searchable list that handles the three states every list has: content,
/// nothing-yet, and nothing-matched. Pass the full collection and a matcher;
/// the wrapper filters, and shows the right empty view for the reason it is
/// empty. Screens should not re-implement this branching.
///
///     AppSearchableList(
///         items: tasks,
///         query: $query,
///         matches: { $0.title.localizedCaseInsensitiveContains($1) },
///         empty: AppEmptyState(
///             title: "No tasks yet", systemImage: "checklist",
///             message: "Add your first task to get started.",
///             actionTitle: "Add Task", action: { isAdding = true }
///         )
///     ) { task in
///         AppCheckRow(title: task.title, isComplete: task.isDone) {
///             task.isDone.toggle()
///         }
///     }
struct AppSearchableList<Item: Identifiable, Row: View, Empty: View>: View {
    let items: [Item]
    @Binding var query: String
    let matches: (Item, String) -> Bool
    let empty: Empty
    var prompt: String = "Search"
    var onDelete: ((Item) -> Void)? = nil
    @ViewBuilder let row: (Item) -> Row

    private var filtered: [Item] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return items }
        return items.filter { matches($0, trimmed) }
    }

    var body: some View {
        Group {
            if items.isEmpty {
                empty
            } else if filtered.isEmpty {
                AppNoSearchResults(query: query)
            } else {
                List {
                    ForEach(filtered) { item in
                        row(item)
                    }
                    .onDelete { offsets in
                        guard let onDelete else { return }
                        for index in offsets {
                            onDelete(filtered[index])
                        }
                    }
                }
            }
        }
        .searchable(text: $query, prompt: prompt)
    }
}

/// The same three-state branching without search, for a plain list.
struct AppContentList<Item: Identifiable, Row: View, Empty: View>: View {
    let items: [Item]
    let empty: Empty
    var onDelete: ((Item) -> Void)? = nil
    @ViewBuilder let row: (Item) -> Row

    var body: some View {
        if items.isEmpty {
            empty
        } else {
            List {
                ForEach(items) { item in
                    row(item)
                }
                .onDelete { offsets in
                    guard let onDelete else { return }
                    for index in offsets {
                        onDelete(items[index])
                    }
                }
            }
        }
    }
}
