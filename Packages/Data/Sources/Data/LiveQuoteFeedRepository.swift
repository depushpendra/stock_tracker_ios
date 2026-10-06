import Foundation
import Core
import Domain

public actor LiveQuoteFeedRepository: QuoteFeedRepository {
    private let store: QuoteStore
    private let engine: EchoPriceFeedEngine
    private let metadataIndex: SymbolMetadataIndex

    private var handlersConfigured = false

    public init(
        catalog: SymbolCatalogProvider,
        webSocket: any WebSocketClient,
        configuration: EchoFeedConfiguration = EchoFeedConfiguration()
    ) throws {
        let symbols = try catalog.allSymbols()
        metadataIndex = SymbolMetadataIndex(symbols: symbols)
        store = QuoteStore(symbols: symbols)
        engine = EchoPriceFeedEngine(webSocket: webSocket, symbols: symbols, configuration: configuration)
    }

    private func configureHandlersIfNeeded() async {
        guard !handlersConfigured else { return }
        handlersConfigured = true
        await engine.setHandlers(
            onStatus: { [store] status in
                Task { await store.setConnectionStatus(status) }
            },
            onQuote: { [store] message in
                Task { await store.merge(message: message) }
            }
        )
    }

    nonisolated public func quotesStream() -> AsyncStream<[Quote]> {
        AsyncStream { continuation in
            Task { await self.bridgeQuotes(to: continuation) }
        }
    }

    nonisolated public func connectionStatusStream() -> AsyncStream<ConnectionStatus> {
        AsyncStream { continuation in
            Task { await self.bridgeStatus(to: continuation) }
        }
    }

    private func bridgeQuotes(to continuation: AsyncStream<[Quote]>.Continuation) async {
        let stream = await store.registerQuotesStream()
        for await snapshot in stream {
            continuation.yield(snapshot)
        }
    }

    private func bridgeStatus(to continuation: AsyncStream<ConnectionStatus>.Continuation) async {
        let stream = await store.registerStatusStream()
        for await status in stream {
            continuation.yield(status)
        }
    }

    public func startFeed() async {
        await configureHandlersIfNeeded()
        await engine.start()
    }

    public func stopFeed() async {
        await engine.stop()
    }

    public func quote(for symbol: Symbol) async -> Quote? {
        await store.quote(for: symbol)
    }

    public func symbolMetadata(for symbol: Symbol) async -> StockSymbol? {
        metadataIndex.metadata(for: symbol)
    }
}

struct SymbolMetadataIndex: Sendable {
    private let bySymbol: [Symbol: StockSymbol]

    init(symbols: [StockSymbol]) {
        bySymbol = Dictionary(uniqueKeysWithValues: symbols.map { ($0.symbol, $0) })
    }

    func metadata(for symbol: Symbol) -> StockSymbol? {
        bySymbol[symbol]
    }
}
