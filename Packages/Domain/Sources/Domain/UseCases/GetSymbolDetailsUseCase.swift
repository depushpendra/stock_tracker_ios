import Foundation

public struct SymbolDetails: Sendable, Equatable {
    public let metadata: StockSymbol
    public let quote: Quote?

    public init(metadata: StockSymbol, quote: Quote?) {
        self.metadata = metadata
        self.quote = quote
    }
}

public struct GetSymbolDetailsUseCase: Sendable {
    private let repository: any QuoteFeedRepository

    public init(repository: any QuoteFeedRepository) {
        self.repository = repository
    }

    public func execute(symbol: Symbol) async -> SymbolDetails? {
        guard let metadata = await repository.symbolMetadata(for: symbol) else {
            return nil
        }
        let quote = await repository.quote(for: symbol)
        return SymbolDetails(metadata: metadata, quote: quote)
    }
}
