import Foundation
import Testing
@testable import Domain

@Suite("SortQuotesUseCase")
struct SortQuotesUseCaseTests {
    let useCase = SortQuotesUseCase()

    private func quote(symbol: String, price: Decimal, change: Decimal) -> Quote {
        Quote(
            symbol: Symbol(rawValue: symbol),
            name: symbol,
            price: price,
            change: change,
            updatedAt: .now
        )
    }

    @Test("Sorts by price descending with symbol tie-break")
    func sortByPrice() {
        let quotes = [
            quote(symbol: "BBB", price: 100, change: 1),
            quote(symbol: "AAA", price: 100, change: 2),
            quote(symbol: "CCC", price: 200, change: 0),
        ]
        let sorted = useCase.execute(quotes: quotes, sortBy: .price)
        #expect(sorted.map(\.symbol.rawValue) == ["CCC", "AAA", "BBB"])
    }

    @Test("Sorts by price change descending with symbol tie-break")
    func sortByChange() {
        let quotes = [
            quote(symbol: "BBB", price: 50, change: 5),
            quote(symbol: "AAA", price: 60, change: 5),
            quote(symbol: "CCC", price: 70, change: 10),
        ]
        let sorted = useCase.execute(quotes: quotes, sortBy: .priceChange)
        #expect(sorted.map(\.symbol.rawValue) == ["CCC", "AAA", "BBB"])
    }
}

@Suite("PriceUpdateMessage")
struct PriceUpdateMessageTests {
    @Test("Decodes valid echo payload")
    func decodeValid() throws {
        let json = """
        {"v":1,"symbol":"AAPL","price":189.42,"sentAt":"2026-10-05T15:00:00Z"}
        """
        let message = try PriceUpdateMessageDecoder.decode(from: json)
        #expect(message.symbol == "AAPL")
        #expect(message.price == Decimal(string: "189.42"))
    }

    @Test("Rejects unsupported schema version")
    func rejectVersion() {
        let json = """
        {"v":99,"symbol":"AAPL","price":1,"sentAt":"2026-10-05T15:00:00Z"}
        """
        #expect(throws: (any Error).self) {
            _ = try PriceUpdateMessageDecoder.decode(from: json)
        }
    }
}
