import Foundation

public struct SortQuotesUseCase: Sendable {
    public init() {}

    public func execute(quotes: [Quote], sortBy: QuoteSortOption) -> [Quote] {
        switch sortBy {
        case .price:
            return quotes.sorted { lhs, rhs in
                if lhs.price == rhs.price {
                    return lhs.symbol.rawValue < rhs.symbol.rawValue
                }
                return lhs.price > rhs.price
            }
        case .priceChange:
            return quotes.sorted { lhs, rhs in
                if lhs.change == rhs.change {
                    return lhs.symbol.rawValue < rhs.symbol.rawValue
                }
                return lhs.change > rhs.change
            }
        }
    }
}
