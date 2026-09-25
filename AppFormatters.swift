import Foundation

// Display formatting. Use these instead of building DateFormatters or string
// interpolation in a screen: they are locale-correct, allocation-free at the
// call site, and consistent across screens written by different writers.
enum AppFormat {
    /// "12 Mar 2026"
    static func date(_ date: Date) -> String {
        date.formatted(.dateTime.day().month(.abbreviated).year())
    }

    /// "12 Mar, 14:30"
    static func dateTime(_ date: Date) -> String {
        date.formatted(.dateTime.day().month(.abbreviated).hour().minute())
    }

    /// "14:30"
    static func time(_ date: Date) -> String {
        date.formatted(.dateTime.hour().minute())
    }

    static func weekday(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.abbreviated))
    }

    static func dayNumber(_ date: Date) -> String {
        date.formatted(.dateTime.day())
    }

    /// "2 days ago", "in 3 hours" — for feeds and activity lists.
    static func relative(_ date: Date, to reference: Date = .now) -> String {
        date.formatted(.relative(presentation: .named, unitsStyle: .wide))
    }

    /// "Today", "Tomorrow", "Yesterday", else an abbreviated date.
    static func friendlyDay(_ date: Date, calendar: Calendar = .current) -> String {
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        return AppFormat.date(date)
    }

    /// Locale currency, e.g. "$12.50". Pass a code for a fixed currency.
    static func currency(_ amount: Decimal, code: String? = nil) -> String {
        if let code {
            return amount.formatted(.currency(code: code))
        }
        return amount.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }

    /// "1,240" — grouped integer.
    static func number(_ value: Int) -> String {
        value.formatted(.number)
    }

    /// "12.5" with a fixed number of decimals.
    static func decimal(_ value: Double, places: Int = 1) -> String {
        value.formatted(.number.precision(.fractionLength(places)))
    }

    /// "64%" from a 0...1 fraction.
    static func percent(_ fraction: Double) -> String {
        min(max(fraction, 0), 1).formatted(.percent.precision(.fractionLength(0)))
    }

    /// "1h 25m" / "45m" / "30s" from a seconds count.
    static func duration(_ seconds: TimeInterval) -> String {
        let total = Int(max(0, seconds.rounded()))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        if minutes > 0 { return "\(minutes)m" }
        return "\(total)s"
    }

    /// "2.4 MB"
    static func fileSize(_ bytes: Int64) -> String {
        bytes.formatted(.byteCount(style: .file))
    }
}

extension Calendar {
    /// Start of day, the correct key for grouping records by date.
    func day(of date: Date) -> Date { startOfDay(for: date) }
}
