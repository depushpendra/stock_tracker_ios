import Foundation
import Domain

actor QuoteStore {
    private var quotesBySymbol: [Symbol: Quote] = [:]
    private var metadataBySymbol: [Symbol: StockSymbol] = [:]
    private var sessionBaselineBySymbol: [Symbol: Decimal] = [:]
    private var lastPriceBySymbol: [Symbol: Decimal] = [:]

    private var quoteContinuations: [UUID: AsyncStream<[Quote]>.Continuation] = [:]
    private var statusContinuations: [UUID: AsyncStream<ConnectionStatus>.Continuation] = [:]
    private var connectionStatus: ConnectionStatus = .disconnected

    init(symbols: [StockSymbol]) {
        let now = Date.now
        for stock in symbols {
            metadataBySymbol[stock.symbol] = stock
            sessionBaselineBySymbol[stock.symbol] = stock.seedPrice
            lastPriceBySymbol[stock.symbol] = stock.seedPrice
            quotesBySymbol[stock.symbol] = Quote(
                symbol: stock.symbol,
                name: stock.name,
                currencyCode: stock.currencyCode,
                price: stock.seedPrice,
                change: 0,
                tickChange: 0,
                updatedAt: now
            )
        }
    }

    func registerQuotesStream() -> AsyncStream<[Quote]> {
        AsyncStream { continuation in
            let id = UUID()
            quoteContinuations[id] = continuation
            continuation.yield(sortedSnapshot())
            continuation.onTermination = { [weak self] _ in
                Task { await self?.removeQuoteContinuation(id: id) }
            }
        }
    }

    func registerStatusStream() -> AsyncStream<ConnectionStatus> {
        AsyncStream { continuation in
            let id = UUID()
            statusContinuations[id] = continuation
            continuation.yield(connectionStatus)
            continuation.onTermination = { [weak self] _ in
                Task { await self?.removeStatusContinuation(id: id) }
            }
        }
    }

    func setConnectionStatus(_ status: ConnectionStatus) {
        connectionStatus = status
        statusContinuations.values.forEach { $0.yield(status) }
    }

    func merge(message: PriceUpdateMessage) {
        let symbol = Symbol(rawValue: message.symbol)
        guard let metadata = metadataBySymbol[symbol] else { return }

        let baseline = sessionBaselineBySymbol[symbol] ?? metadata.seedPrice
        let previousTick = lastPriceBySymbol[symbol] ?? message.price
        let tickChange = message.price - previousTick
        lastPriceBySymbol[symbol] = message.price

        quotesBySymbol[symbol] = Quote(
            symbol: symbol,
            name: metadata.name,
            currencyCode: metadata.currencyCode,
            price: message.price,
            change: message.price - baseline,
            tickChange: tickChange,
            updatedAt: message.sentAt
        )
        emitQuotes()
    }

    func quote(for symbol: Symbol) -> Quote? {
        quotesBySymbol[symbol]
    }

    func symbolMetadata(for symbol: Symbol) -> StockSymbol? {
        metadataBySymbol[symbol]
    }

    private func removeQuoteContinuation(id: UUID) {
        quoteContinuations.removeValue(forKey: id)
    }

    private func removeStatusContinuation(id: UUID) {
        statusContinuations.removeValue(forKey: id)
    }

    private func emitQuotes() {
        let snapshot = sortedSnapshot()
        quoteContinuations.values.forEach { $0.yield(snapshot) }
    }

    private func sortedSnapshot() -> [Quote] {
        quotesBySymbol.values.sorted { $0.symbol.rawValue < $1.symbol.rawValue }
    }
}
