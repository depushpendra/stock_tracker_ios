import Foundation
import Testing
@testable import Domain

@Suite("QuoteFeedSession")
struct QuoteFeedSessionTests {
    @Test("Start and stop delegate to use cases")
    func startStop() async {
        let mock = SessionQuoteFeedRepository()
        let session = QuoteFeedSession(
            startFeed: StartPriceFeedUseCase(repository: mock),
            stopFeed: StopPriceFeedUseCase(repository: mock)
        )

        await session.start()
        #expect(await mock.startFeedCallCount == 1)

        await session.stop()
        #expect(await mock.stopFeedCallCount == 1)
    }
}

private actor SessionQuoteFeedRepository: QuoteFeedRepository {
    private(set) var startFeedCallCount = 0
    private(set) var stopFeedCallCount = 0

    nonisolated func quotesStream() -> AsyncStream<[Quote]> {
        AsyncStream { $0.finish() }
    }

    nonisolated func connectionStatusStream() -> AsyncStream<ConnectionStatus> {
        AsyncStream { $0.finish() }
    }

    func startFeed() async { startFeedCallCount += 1 }
    func stopFeed() async { stopFeedCallCount += 1 }
    func quote(for symbol: Symbol) async -> Quote? { nil }
    func symbolMetadata(for symbol: Symbol) async -> StockSymbol? { nil }
}
