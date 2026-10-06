import Foundation

public protocol QuoteFeedRepository: Sendable {
    func quotesStream() -> AsyncStream<[Quote]>
    func connectionStatusStream() -> AsyncStream<ConnectionStatus>
    func startFeed() async
    func stopFeed() async
    func quote(for symbol: Symbol) async -> Quote?
    func symbolMetadata(for symbol: Symbol) async -> StockSymbol?
}
