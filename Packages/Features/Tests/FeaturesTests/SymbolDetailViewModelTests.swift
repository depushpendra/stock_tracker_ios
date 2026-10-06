import Foundation
import Testing
@testable import Features
import Domain
import TestSupport

@MainActor
@Suite("SymbolDetailViewModel")
struct SymbolDetailViewModelTests {
    @Test("Detail quote updates when shared stream emits")
    func updatesFromSharedStream() async {
        let mock = QuoteFeedRepositoryMock()
        let symbol = Symbol(rawValue: "NVDA")
        await mock.setQuotes([
            Quote(symbol: symbol, name: "NVIDIA", price: 100, change: 0, updatedAt: .now),
        ])
        await mock.setMetadata([
            StockSymbol(symbol: symbol, name: "NVIDIA", description: "GPU", seedPrice: 100),
        ])

        let observe = ObserveQuotesUseCase(repository: mock)
        let vm = SymbolDetailViewModel(
            symbol: symbol,
            getDetails: GetSymbolDetailsUseCase(repository: mock),
            observeQuotes: observe
        )
        vm.startObservingIfNeeded()

        try? await Task.sleep(nanoseconds: 50_000_000)

        await mock.setQuotes([
            Quote(symbol: symbol, name: "NVIDIA", price: 150, change: 50, updatedAt: .now),
        ])

        try? await Task.sleep(nanoseconds: 50_000_000)
        #expect(vm.quote?.price == 150)
    }
}
