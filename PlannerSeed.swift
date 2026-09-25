import Foundation
import SwiftData

enum PlannerSeed {
    static func insertIfNeeded(in context: ModelContext) {
        do {
            try AppSeed.ifEmpty(PlanItem.self, in: context) {
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: .now)

                func time(_ dayOffset: Int, _ hour: Int, _ minute: Int = 0) -> Date {
                    let day = calendar.date(byAdding: .day, value: dayOffset, to: today) ?? today
                    return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
                }

                return [
                    PlanItem(title: "Biology lab", startTime: time(0, 9), durationMinutes: 75, kind: .classSession),
                    PlanItem(title: "Finish econ problem set", startTime: time(0, 14), durationMinutes: 90, kind: .assignment, notes: "Submit before midnight.", priority: .high),
                    PlanItem(title: "Recovery lunch", startTime: time(0, 12, 30), durationMinutes: 30, kind: .meal),
                    PlanItem(title: "Team practice", startTime: time(0, 17), durationMinutes: 120, kind: .training),
                    PlanItem(title: "Mobility reset", startTime: time(0, 20), durationMinutes: 25, kind: .recovery),
                    PlanItem(title: "English seminar", startTime: time(1, 10), durationMinutes: 60, kind: .classSession),
                    PlanItem(title: "Film review", startTime: time(1, 16), durationMinutes: 45, kind: .study),
                    PlanItem(title: "Away-game bus travel", startTime: time(2, 12), durationMinutes: 75, kind: .travel, notes: "Bring reading and headphones.", preparationMinutes: 15),
                    PlanItem(title: "Strength session", startTime: time(2, 16), durationMinutes: 75, kind: .training),
                    PlanItem(title: "Conference match", startTime: time(4, 13), durationMinutes: 120, kind: .game, priority: .high)
                ]
            }
        } catch {
            assertionFailure("Unable to seed planner data: \(error)")
        }
    }
}