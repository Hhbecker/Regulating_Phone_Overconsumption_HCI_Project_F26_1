import SwiftUI

struct RootView: View {
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .obstacles:
                        ObstaclesView()
                    case .obstacleDemo(let obstacle):
                        ObstacleDemoView(obstacle: obstacle)
                    case .rules:
                        // "Done" on the final screen pops all the way back to Welcome.
                        RulesView(onFinish: { path.removeAll() })
                    }
                }
        }
        .tint(.tgForest)
    }
}
