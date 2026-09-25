import SwiftUI
import SwiftData

struct PlannerScreen: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PlanItem.startTime) private var items: [PlanItem]
    @State private var query = ""
    @State private var isPresentingNewItem = false
    @State private var isPresentingCalendarImport = false
    @State private var isPresentingStudyPreferences = false
    @State private var draft = PlanDraft()

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
                    Label("Structured planning, not chat", systemImage: "sparkles")
                        .font(AppTheme.headline)
                    Text("Add commitments, set study boundaries, and preview changes before Dual AI updates your schedule.")
                        .font(AppTheme.callout)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .padding(.vertical, AppTheme.compactSpacing)
            }

            Section("Plan with Dual AI") {
                Menu {
                    ForEach(PlanKind.allCases) { kind in
                        Button {
                            presentNewItem(of: kind)
                        } label: {
                            Label(kind.rawValue, systemImage: kind.symbol)
                        }
                    }
                } label: {
                    AppListRow(title: "Add information", subtitle: "Exam, training, travel, study, and more", systemImage: "plus.circle.fill")
                }
                Button {
                    isPresentingStudyPreferences = true
                } label: {
                    AppListRow(title: "Study planning", subtitle: "Time goals, session length, and preferred days", systemImage: "timer")
                }
                Button {
                    router.push(.screen("smart-plan"))
                } label: {
                    AppListRow(title: "Reorganize", subtitle: "Preview deadline-aware schedule changes", systemImage: "arrow.triangle.2.circlepath")
                }
                Button {
                    router.push(.screen("weekly-review"))
                } label: {
                    AppListRow(title: "Weekly review", subtitle: "Consistency, completion, and next-week recommendations", systemImage: "chart.bar.xaxis")
                }
            }

            Section("Your plan") {
                if filteredItems.isEmpty {
                    ContentUnavailableView(
                        query.isEmpty ? "No upcoming items" : "No matching items",
                        systemImage: query.isEmpty ? "calendar.badge.plus" : "magnifyingglass",
                        description: Text(query.isEmpty ? "Use Add information to build your first plan." : "Try another task, course, or event type.")
                    )
                } else {
                    ForEach(filteredItems) { item in
                        Button {
                            router.push(.screen("item-\(item.identifier.uuidString)"))
                        } label: {
                            PlanItemRow(item: item, showDay: true)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteOffsets)
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $query, prompt: "Search your plan")
        .navigationTitle("AI Planner")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.push(.screen("smart-plan"))
                } label: {
                    Label("Smart Plan", systemImage: "sparkles")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingCalendarImport = true
                } label: {
                    Image(systemName: "calendar.badge.arrow.down")
                }
                .accessibilityLabel("Import calendar events")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presentNewItem()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add plan item")
            }
        }
        .sheet(isPresented: $isPresentingNewItem) {
            PlanItemEditorSheet(draft: $draft) {
                let newItem = PlanItem(
                    title: draft.title.trimmingCharacters(in: .whitespacesAndNewlines),
                    startTime: draft.startTime,
                    durationMinutes: draft.durationMinutes,
                    kind: draft.kind,
                    notes: draft.notes,
                    priority: draft.priority,
                    location: draft.location,
                    preparationMinutes: draft.preparationMinutes,
                    travelMinutes: draft.travelMinutes,
                    bufferMinutes: draft.bufferMinutes,
                    reminderMinutes: draft.reminderMinutes == 0 ? nil : draft.reminderMinutes
                )
                modelContext.insert(newItem)
                Task {
                    await PlannerNotifications.schedule(for: newItem)
                }
            }
        }
        .sheet(isPresented: $isPresentingCalendarImport) {
            CalendarImportSheet(existingEventIdentifiers: Set(items.compactMap(\.calendarEventIdentifier)))
        }
        .sheet(isPresented: $isPresentingStudyPreferences) {
            AIStudyPreferencesSheet()
        }
    }

    private func presentNewItem() {
        draft = PlanDraft()
        isPresentingNewItem = true
    }

    private func presentNewItem(of kind: PlanKind) {
        draft = PlanDraft()
        draft.kind = kind
        isPresentingNewItem = true
    }

    private var filteredItems: [PlanItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return items }
        return items.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed)
                || $0.kind.rawValue.localizedCaseInsensitiveContains(trimmed)
        }
    }

    private func deleteOffsets(_ offsets: IndexSet) {
        for index in offsets {
            delete(filteredItems[index])
        }
    }

    private func delete(_ item: PlanItem) {
        let identifier = item.identifier
        withAnimation(AppTheme.spring) {
            modelContext.delete(item)
        }
        Task {
            await PlannerNotifications.remove(for: identifier)
        }
    }
}