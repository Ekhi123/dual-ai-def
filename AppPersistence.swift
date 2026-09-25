import SwiftData

enum AppPersistence {
    // The lead supplies domain-specific @Model types and installs the returned
    // container with .modelContainer(...) at the app root. Never erase a store
    // or fall back to in-memory persistence on a production load error.
    static func container(
        for models: any PersistentModel.Type...,
        inMemory: Bool = false
    ) throws -> ModelContainer {
        let schema = Schema(models)
        let configuration = ModelConfiguration(
            schema: schema, isStoredInMemoryOnly: inMemory
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
