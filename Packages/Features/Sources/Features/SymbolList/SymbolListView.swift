import SwiftUI
import DesignSystem
import Domain
import Localization

public struct SymbolListView: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.layoutPreferences) private var layoutPreferences
    @Environment(\.userLayoutDirectionChoice) private var layoutDirectionChoice

    @Bindable var viewModel: SymbolListViewModel
    let onSelect: (Symbol) -> Void

    public init(viewModel: SymbolListViewModel, onSelect: @escaping (Symbol) -> Void) {
        self.viewModel = viewModel
        self.onSelect = onSelect
    }

    public var body: some View {
        ZStack {
            AppScreenBackground()

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.quotes) { quote in
                        Button {
                            onSelect(quote.symbol)
                        } label: {
                            StockRowCard(quote: quote)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, theme.metrics.listHorizontalInset)
                        .padding(.vertical, 6)
                        .environment(\.layoutDirection, layoutPreferences.layoutDirection)
                        .accessibilityLabel("\(quote.symbol.rawValue), \(quote.name)")
                    }
                }
                .padding(.vertical, 4)
            }
            .scrollIndicators(.automatic)
            .accessibilityIdentifier("stock_list")
            .environment(\.layoutDirection, layoutPreferences.layoutDirection)
        }
        .syncLayoutDirectionWithNavigationBar()
        .navigationTitle(L10n.stocksTitle)
        .toolbarTitleDisplayMode(.large)
        .toolbarBackground(theme.colors.backgroundPrimary.opacity(0.9), for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ConnectionStatusView(status: viewModel.connectionStatus)
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                if let layoutDirectionChoice {
                    LayoutDirectionPickerMenu(choice: layoutDirectionChoice)
                }
                sortMenu
                FeedControlButton(
                    title: viewModel.isFeedRunning ? L10n.stop : L10n.start,
                    isRunning: viewModel.isFeedRunning,
                    isEnabled: viewModel.connectionStatus != .connecting
                ) {
                    Task { await viewModel.toggleFeed() }
                }
            }
        }
        .task { viewModel.startObservingIfNeeded() }
    }

    private var sortMenu: some View {
        Menu {
            Button(L10n.byPrice) {
                viewModel.applySort(.price)
            }
            Button(L10n.byPriceChange) {
                viewModel.applySort(.priceChange)
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(theme.colors.accentPrimary, theme.colors.surfaceCard)
                .font(.title3)
                .accessibilityLabel(L10n.sort)
        }
    }
}
