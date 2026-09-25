import Foundation
import SwiftData

enum PlanKind: String, CaseIterable, Identifiable {
    case classSession = "Class"
    case study = "Study"
    case training = "Training"
    case recovery = "Recovery"
    case game = "Game"
    case exam = "Exam"
    case assignment = "Assignment"
    case homework = "Homework"
    case project = "Project"
    case teamMeeting = "Team meeting"
    case travel = "Travel"
    case personal = "Personal"
    case meal = "Meal"
    case breakTime = "Break"
    case sleep = "Sleep"
    case appointment = "Appointment"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .classSession:
            return "book.closed.fill"
        case .study:
            return "pencil.and.list.clipboard"
        case .training:
            return "figure.run"
        case .recovery:
            return "figure.cooldown"
        case .game:
            return "sportscourt.fill"
        case .exam:
            return "checklist"
        case .assignment:
            return "doc.text.fill"
        case .homework:
            return "pencil"
        case .project:
            return "folder.fill"
        case .teamMeeting:
            return "person.3.fill"
        case .travel:
            return "bus.fill"
        case .personal:
            return "person.fill"
        case .meal:
            return "fork.knife"
        case .breakTime:
            return "cup.and.saucer.fill"
        case .sleep:
            return "bed.double.fill"
        case .appointment:
            return "stethoscope"
        }
    }
}

enum PlanPriority: String, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .low:
            return "arrow.down.circle"
        case .medium:
            return "equal.circle"
        case .high:
            return "bolt.fill"
        }
    }
}

@Model
final class PlanItem {
    var identifier: UUID
    var title: String
    var startTime: Date
    var durationMinutes: Int
    var kindRaw: String
    var notes: String
    var isComplete: Bool
    var isPriority: Bool
    var priorityRaw: String = PlanPriority.medium.rawValue
    var location: String = ""
    var preparationMinutes: Int = 0
    var travelMinutes: Int = 0
    var bufferMinutes: Int = 0
    var isInProgress: Bool = false
    var reminderMinutes: Int?
    var calendarEventIdentifier: String?

    init(
        title: String,
        startTime: Date,
        durationMinutes: Int,
        kind: PlanKind,
        notes: String = "",
        isComplete: Bool = false,
        isPriority: Bool = false,
        priority: PlanPriority = .medium,
        location: String = "",
        preparationMinutes: Int = 0,
        travelMinutes: Int = 0,
        bufferMinutes: Int = 0,
        reminderMinutes: Int? = 15,
        calendarEventIdentifier: String? = nil
    ) {
        identifier = UUID()
        self.title = title
        self.startTime = startTime
        self.durationMinutes = durationMinutes
        kindRaw = kind.rawValue
        self.notes = notes
        self.isComplete = isComplete
        self.isPriority = isPriority || priority == .high
        priorityRaw = isPriority ? PlanPriority.high.rawValue : priority.rawValue
        self.location = location
        self.preparationMinutes = preparationMinutes
        self.travelMinutes = travelMinutes
        self.bufferMinutes = bufferMinutes
        self.reminderMinutes = reminderMinutes
        self.calendarEventIdentifier = calendarEventIdentifier
    }

    var kind: PlanKind {
        get { PlanKind(rawValue: kindRaw) ?? .study }
        set { kindRaw = newValue.rawValue }
    }

    var endTime: Date {
        startTime.addingTimeInterval(TimeInterval(durationMinutes * 60))
    }

    var priority: PlanPriority {
        get {
            PlanPriority(rawValue: priorityRaw) ?? (isPriority ? .high : .medium)
        }
        set {
            priorityRaw = newValue.rawValue
            isPriority = newValue == .high
        }
    }

    var totalReservedMinutes: Int {
        durationMinutes + preparationMinutes + travelMinutes + bufferMinutes
    }
}