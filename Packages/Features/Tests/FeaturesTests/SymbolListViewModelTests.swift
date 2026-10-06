import Foundation
import Testing
@testable import Features
import Domain
import TestSupport

@MainActor
@Suite("SymbolListViewModel")
struct SymbolListViewModelTests {
    @Test("Start and stop invoke repository")
    func toggleFeed() async {
        let mock = QuoteFeedRepositoryMock()
        await mock.setQuotes([
            Quote(symbol: Symbol(rawValue: "AAPL"), name: "Apple", price: 1, change: 0, updatedAt: .now),
        ])
        let vm = makeViewModel(mock: mock)
        vm.startObservingIfNeeded()

        await vm.toggleFeed()
        #expect(await mock.startFeedCallCount == 1)

        await mock.setConnectionStatus(.connected)
        await waitUntil { vm.connectionStatus == .connected }

        await vm.toggleFeed()
        #expect(await mock.stopFeedCallCount == 1)
    }

    private func waitUntil(
        timeoutNanoseconds: UInt64 = 500_000_000,
        pollNanoseconds: UInt64 = 5_000_000,
        condition: @escaping @MainActor () -> Bool
    ) async {
        let deadline = DispatchTime.now().uptimeNanoseconds + timeoutNanoseconds
        while DispatchTime.now().uptimeNanoseconds < deadline {
            if await MainActor.run(body: condition) { return }
            try? await Task.sleep(nanoseconds: pollNanoseconds)
        }
        Issue.record("Timed out waiting for condition")
    }

    @Test("Sort by price reorders displayed quotes")
    func sortByPrice() async {
        let mock = QuoteFeedRepositoryMock()
        let vm = makeViewModel(mock: mock)
        vm.startObservingIfNeeded()
        await mock.setQuotes([
            Quote(symbol: Symbol(rawValue: "AAPL"), name: "Apple", price: 10, change: 1, updatedAt: .now),
            Quote(symbol: Symbol(rawValue: "NVDA"), name: "NVIDIA", price: 100, change: 2, updatedAt: .now),
        ])
        vm.applySort(.price)
        try? await Task.sleep(nanoseconds: 50_000_000)
        #expect(vm.quotes.first?.symbol.rawValue == "NVDA")
    }

    private func makeViewModel(mock: QuoteFeedRepositoryMock) -> SymbolListViewModel {
        SymbolListViewModel(
            observeQuotes: ObserveQuotesUseCase(repository: mock),
            observeConnection: ObserveConnectionStatusUseCase(repository: mock),
            quoteFeedSession: QuoteFeedSession(
                startFeed: StartPriceFeedUseCase(repository: mock),
                stopFeed: StopPriceFeedUseCase(repository: mock)
            )
        )
    }
}
