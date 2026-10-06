import Foundation

public struct Quote: Hashable, Sendable, Identifiable {
    public var id: Symbol { symbol }
    public let symbol: Symbol
    public let name: String
    public let currencyCode: CurrencyCode
    public let price: Decimal
    /// Change since the session baseline price (seed price when the feed repository was created).
    public let change: Decimal
    /// Change versus the previous tick (last emitted price for this symbol).
    public let tickChange: Decimal
    public let updatedAt: Date

    public init(
        symbol: Symbol,
        name: String,
        currencyCode: CurrencyCode = .usd,
        price: Decimal,
        change: Decimal,
        tickChange: Decimal = 0,
        updatedAt: Date
    ) {
        self.symbol = symbol
        self.name = name
        self.currencyCode = currencyCode
        self.price = price
        self.change = change
        self.tickChange = tickChange
        self.updatedAt = updatedAt
    }
}
