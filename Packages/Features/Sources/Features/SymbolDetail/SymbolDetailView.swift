import SwiftUI
import DesignSystem
import Domain
import Localization

public struct SymbolDetailView: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.layoutPreferences) private var layoutPreferences
    @Environment(\.userLayoutDirectionChoice) private var layoutDirectionChoice

    @Bindable var viewModel: SymbolDetailViewModel

    public init(viewModel: SymbolDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            AppScreenBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if viewModel.isLoadingDetails {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                            .accessibilityIdentifier("detail_loading")
                    }

                    if let quote = viewModel.quote, let name = viewModel.details?.metadata.name {
                        DetailHeroCard(symbol: viewModel.symbol, name: name, quote: quote)
                    }

                    if let metadata = viewModel.details?.metadata, let quote = viewModel.quote {
                        SymbolDetailInfoCard(metadata: metadata, quote: quote)
                    }

                    if let metadata = viewModel.details?.metadata {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(L10n.aboutCompany)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(L10n.symbolDescription(ticker: metadata.symbol.rawValue, fallback: metadata.description))
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(18)
                        .background {
                            RoundedRectangle(cornerRadius: theme.metrics.cardCornerRadius, style: .continuous)
                                .fill(theme.colors.surfaceCard)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: theme.metrics.cardCornerRadius, style: .continuous)
                                .strokeBorder(theme.colors.surfaceCardStroke, lineWidth: 1)
                        }
                    }
                }
                .padding(.horizontal, theme.metrics.listHorizontalInset)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .environment(\.layoutDirection, layoutPreferences.layoutDirection)
        }
        .syncLayoutDirectionWithNavigationBar()
        .navigationTitle(viewModel.symbol.rawValue)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbarBackground(theme.colors.backgroundPrimary.opacity(0.9), for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if let layoutDirectionChoice {
                    LayoutDirectionPickerMenu(choice: layoutDirectionChoice)
                }
            }
        }
        .task(id: viewModel.symbol) {
            viewModel.startObservingIfNeeded()
        }
    }
}
