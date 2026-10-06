import Foundation

public struct StockSymbol: Hashable, Sendable, Codable {
    public let symbol: Symbol
    public let name: String
    public let description: String
    public let seedPrice: Decimal
    public let currencyCode: CurrencyCode
    public let exchange: String
    public let sector: String
    public let country: String

    public init(
        symbol: Symbol,
        name: String,
        description: String,
        seedPrice: Decimal,
        currencyCode: CurrencyCode = .usd,
        exchange: String = "NASDAQ",
        sector: String = "Technology",
        country: String = "United States"
    ) {
        self.symbol = symbol
        self.name = name
        self.description = description
        self.seedPrice = seedPrice
        self.currencyCode = currencyCode
        self.exchange = exchange
        self.sector = sector
        self.country = country
    }
}
