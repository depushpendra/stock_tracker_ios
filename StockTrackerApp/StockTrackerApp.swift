import SwiftUI
import Bootstrap
import Core

@main
struct StockTrackerApp: App {
    @State private var dependenciesResult = CompositionRoot.make()

    var body: some Scene {
        WindowGroup {
            switch dependenciesResult {
            case .success(let dependencies):
                AppRootView(coordinator: AppCoordinator(dependencies: dependencies))
                    .task {
                        await dependencies.telemetry.record(.appLaunched)
                    }
            case .failure(let error):
                BootstrapFailureView(message: error.localizedDescription)
            }
        }
    }
}

private struct BootstrapFailureView: View {
    let message: String

    var body: some View {
        ContentUnavailableView(
            "Unable to Start",
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
    }
}
