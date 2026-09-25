import EventKit
import Foundation
import UserNotifications

struct CalendarImportEvent: Identifiable {
    let id: String
    let title: String
    let startTime: Date
    let durationMinutes: Int
    let kind: PlanKind
    let notes: String
}

enum PlannerCalendar {
    static func upcomingEvents() async throws -> [CalendarImportEvent] {
        let eventStore = EKEventStore()
        let isGranted = try await eventStore.requestFullAccessToEvents()
        guard isGranted else {
            throw CalendarImportError.accessDenied
        }

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        let end = calendar.date(byAdding: .day, value: 14, to: start) ?? start
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)

        return eventStore.events(matching: predicate)
            .filter { !$0.isAllDay }
            .sorted { $0.startDate < $1.startDate }
            .map { event in
                CalendarImportEvent(
                    id: event.eventIdentifier ?? UUID().uuidString,
                    title: event.title ?? "Calendar event",
                    startTime: event.startDate,
                    durationMinutes: Swift.max(15, Int(event.endDate.timeIntervalSince(event.startDate) / 60)),
                    kind: suggestedKind(for: event.title ?? ""),
                    notes: event.notes ?? ""
                )
            }
    }

    private static func suggestedKind(for title: String) -> PlanKind {
        let normalizedTitle = title.lowercased()
        if normalizedTitle.contains("practice") || normalizedTitle.contains("workout") {
            return .training
        }
        if normalizedTitle.contains("class") || normalizedTitle.contains("lecture") {
            return .classSession
        }
        return .study
    }
}

enum CalendarImportError: LocalizedError {
    case accessDenied

    var errorDescription: String? {
        "Calendar access is needed to import upcoming events."
    }
}

enum PlannerNotifications {
    static func schedule(for item: PlanItem) async {
        await remove(for: item.identifier)
        guard let reminderMinutes = item.reminderMinutes, reminderMinutes > 0 else { return }

        let triggerDate = item.startTime.addingTimeInterval(TimeInterval(-reminderMinutes * 60))
        guard triggerDate > .now else { return }

        do {
            let center = UNUserNotificationCenter.current()
            let isGranted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            guard isGranted else { return }

            let content = UNMutableNotificationContent()
            content.title = item.title
            content.body = "Starts in \(reminderMinutes) minutes."
            content.sound = .default

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: triggerDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: notificationIdentifier(for: item.identifier),
                content: content,
                trigger: trigger
            )
            try await center.add(request)
        } catch {
            return
        }
    }

    static func remove(for identifier: UUID) async {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationIdentifier(for: identifier)])
    }

    private static func notificationIdentifier(for identifier: UUID) -> String {
        "planner-reminder-\(identifier.uuidString)"
    }
}