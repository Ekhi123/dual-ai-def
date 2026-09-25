import SwiftUI

enum AppRoute: Hashable {
    case screen(String)
}

@Observable
final class AppRouter {
    var path: [AppRoute] = []

    func push(_ route: AppRoute) { path.append(route) }
    func pop() {
        if !path.isEmpty { path.removeLast() }
    }
    func popToRoot() { path.removeAll() }
}
