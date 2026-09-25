import SwiftUI
import SwiftData

struct PlanItemDestination: View {
    @Query(sort: \PlanItem.startTime) private var items: [PlanItem]
    let id: UUID

    var body: some View {
        if let item = items.first(where: { $0.identifier == id }) {
            PlanItemDetailScreen(item: item)
        } else {
            AppErrorState(message: "This plan item is no longer available.")
        }
    }
}