import Foundation
import Domain

public actor QuoteFeedRepositoryMock: QuoteFeedRepository {
    public private(set) var startFeedCallCount = 0
    public private(set) var stopFeedCallCount = 0

    private var quotes: [Quote] = []
    private var connectionStatus: ConnectionStatus = .disconnected
    private var metadata: [Symbol: StockSymbol] = [:]

    private var quoteContinuations: [UUID: AsyncStream<[Quote]>.Continuation] = [:]
    private var statusContinuations: [UUID: AsyncStream<ConnectionStatus>.Continuation] = [:]

    public init() {}

    public func setQuotes(_ quotes: [Quote]) {
        self.quotes = quotes
        emitQuotes()
    }

    public func setConnectionStatus(_ status: ConnectionStatus) {
        connectionStatus = status
        emitStatus()
    }

    public func setMetadata(_ items: [StockSymbol]) {
        metadata = Dictionary(uniqueKeysWithValues: items.map { ($0.symbol, $0) })
    }

    nonisolated public func quotesStream() -> AsyncStream<[Quote]> {
        AsyncStream { continuation in
            Task { await self.registerQuotesStream(continuation) }
        }
    }

    nonisolated public func connectionStatusStream() -> AsyncStream<ConnectionStatus> {
        AsyncStream { continuation in
            Task { await self.registerStatusStream(continuation) }
        }
    }

    public func startFeed() async {
        startFeedCallCount += 1
        setConnectionStatus(.connected)
    }

    public func stopFeed() async {
        stopFeedCallCount += 1
        setConnectionStatus(.disconnected)
    }

    public func quote(for symbol: Symbol) async -> Quote? {
        quotes.first { $0.symbol == symbol }
    }

    public func symbolMetadata(for symbol: Symbol) async -> StockSymbol? {
        metadata[symbol]
    }

    private func registerQuotesStream(_ continuation: AsyncStream<[Quote]>.Continuation) {
        let id = UUID()
        quoteContinuations[id] = continuation
        continuation.yield(quotes)
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeQuoteContinuation(id: id) }
        }
    }

    private func registerStatusStream(_ continuation: AsyncStream<ConnectionStatus>.Continuation) {
        let id = UUID()
        statusContinuations[id] = continuation
        continuation.yield(connectionStatus)
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeStatusContinuation(id: id) }
        }
    }

    private func removeQuoteContinuation(id: UUID) {
        quoteContinuations.removeValue(forKey: id)
    }

    private func removeStatusContinuation(id: UUID) {
        statusContinuations.removeValue(forKey: id)
    }

    private func emitQuotes() {
        let snapshot = quotes
        quoteContinuations.values.forEach { $0.yield(snapshot) }
    }

    private func emitStatus() {
        statusContinuations.values.forEach { $0.yield(connectionStatus) }
    }
}
