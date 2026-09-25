import Foundation

struct PlanDraft {
    var title = ""
    var startTime = Date.now
    var durationMinutes = 60
    var kind: PlanKind = .study
    var notes = ""
    var priority: PlanPriority = .medium
    var location = ""
    var preparationMinutes = 0
    var travelMinutes = 0
    var bufferMinutes = 0
    var reminderMinutes = 15

    init() {}

    init(item: PlanItem) {
        title = item.title
        startTime = item.startTime
        durationMinutes = item.durationMinutes
        kind = item.kind
        notes = item.notes
        priority = item.priority
        location = item.location
        preparationMinutes = item.preparationMinutes
        travelMinutes = item.travelMinutes
        bufferMinutes = item.bufferMinutes
        reminderMinutes = item.reminderMinutes ?? 15
    }
}