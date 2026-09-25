import SwiftData

/// First-launch sample data.
///
/// The ios-app skill requires a first build to open with 5-8 realistic records
/// rather than an empty screen — and to insert them only when the store is
/// actually empty, so they never duplicate on relaunch. That check is the same
/// every time, so it lives here; the lead only supplies the records.
///
///     try AppSeed.ifEmpty(Task.self, in: context) {
///         [Task(title: "Renew passport", due: .now.addingTimeInterval(86_400 * 9)),
///          Task(title: "Book dentist", due: .now.addingTimeInterval(86_400 * 2))]
///     }
enum AppSeed {
    /// Inserts `make()` only when no rows of `model` exist yet.
    @discardableResult
    static func ifEmpty<Model: PersistentModel>(
        _ model: Model.Type,
        in context: ModelContext,
        make: () -> [Model]
    ) throws -> Bool {
        var descriptor = FetchDescriptor<Model>()
        descriptor.fetchLimit = 1
        guard try context.fetch(descriptor).isEmpty else { return false }
        for item in make() {
            context.insert(item)
        }
        try context.save()
        return true
    }
}
