import SwiftUI
import Bootstrap
import DesignSystem
import Domain
import Features

/// Application-level coordinator: owns navigation state and feature entry points (Coordinator pattern).
@MainActor
@Observable
final class AppCoordinator: AppCoordinating {
    var path = NavigationPath()

    let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func showSymbolDetail(_ symbol: Symbol) {
        path.append(symbol)
    }

    @discardableResult
    func openURL(_ url: URL) -> Bool {
        guard let symbol = DeepLinkParser.symbol(from: url) else { return false }
        showSymbolDetail(symbol)
        return true
    }
}

struct AppRootView: View {
    @Bindable var coordinator: AppCoordinator
    @AppStorage("userLayoutDirectionChoice") private var layoutChoiceRaw = UserLayoutDirectionChoice.automatic.rawValue

    var body: some View {
        let layoutChoice = UserLayoutDirectionChoice(rawValue: layoutChoiceRaw) ?? .automatic
        let layoutPrefs = LayoutPreferences(
            locale: coordinator.dependencies.configuration.locale,
            directionOverride: layoutChoice
        )

        NavigationStack(path: $coordinator.path) {
            SymbolListView(viewModel: coordinator.dependencies.listViewModel()) { symbol in
                coordinator.showSymbolDetail(symbol)
            }
            .navigationDestination(for: Symbol.self) { symbol in
                SymbolDetailView(
                    viewModel: coordinator.dependencies.makeSymbolDetailViewModel(symbol: symbol)
                )
            }
        }
        .appTheme(.standard)
        .layoutPreferences(layoutPrefs)
        .formattingPreferences(
            FormattingPreferences(
                locale: coordinator.dependencies.configuration.locale,
                displayCurrencyCode: coordinator.dependencies.configuration.displayCurrencyCode
            )
        )
        .environment(\.userLayoutDirectionChoice, layoutDirectionBinding)
        .onOpenURL { url in
            _ = coordinator.openURL(url)
        }
    }

    private var layoutDirectionBinding: Binding<UserLayoutDirectionChoice> {
        Binding(
            get: { UserLayoutDirectionChoice(rawValue: layoutChoiceRaw) ?? .automatic },
            set: { layoutChoiceRaw = $0.rawValue }
        )
    }
}
