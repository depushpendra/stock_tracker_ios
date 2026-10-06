import XCTest
import Core
import Domain
import TestSupport
@testable import Data

final class BundledSymbolCatalogTests: XCTestCase {
    func testLoadsTwentyFiveSymbols() throws {
        let catalog = BundledSymbolCatalog()
        let symbols = try catalog.allSymbols()
        XCTAssertEqual(symbols.count, 25)
        XCTAssertTrue(symbols.contains { $0.symbol.rawValue == "NVDA" })
    }

    func testLoadsCurrencyCodes() throws {
        let catalog = BundledSymbolCatalog()
        let symbols = try catalog.allSymbols()
        let byTicker = Dictionary(uniqueKeysWithValues: symbols.map { ($0.symbol.rawValue, $0.currencyCode) })
        XCTAssertEqual(byTicker["AAPL"], .usd)
        XCTAssertEqual(byTicker["ABNB"], .aed)
        XCTAssertEqual(byTicker["IBM"], .inr)
    }

    func testCatalogEntriesIncludeMarketMetadata() throws {
        let catalog = BundledSymbolCatalog()
        let symbols = try catalog.allSymbols()
        XCTAssertTrue(symbols.allSatisfy { !$0.exchange.isEmpty && !$0.sector.isEmpty && !$0.country.isEmpty })
    }
}

final class LiveQuoteFeedRepositoryTests: XCTestCase {
    func testMalformedEchoDoesNotClearQuotes() async throws {
        let catalog = BundledSymbolCatalog()
        let mock = WebSocketClientTestDouble()
        let repository = try LiveQuoteFeedRepository(catalog: catalog, webSocket: mock)

        let initial = await repository.quote(for: Symbol(rawValue: "AAPL"))
        XCTAssertNotNil(initial)

        await mock.configureNextReceive("{ invalid json")
        await repository.startFeed()
        try await Task.sleep(nanoseconds: 100_000_000)
        await repository.stopFeed()

        let after = await repository.quote(for: Symbol(rawValue: "AAPL"))
        XCTAssertEqual(after?.price, initial?.price)
    }

    func testMultipleQuoteStreamsReceiveSameSnapshot() async throws {
        let catalog = BundledSymbolCatalog()
        let mock = WebSocketClientTestDouble()
        let repository = try LiveQuoteFeedRepository(catalog: catalog, webSocket: mock)

        let streamA = repository.quotesStream()
        let streamB = repository.quotesStream()

        let firstA = await firstQuote(from: streamA)
        let firstB = await firstQuote(from: streamB)
        XCTAssertEqual(firstA?.count, 25)
        XCTAssertEqual(firstA?.map(\.symbol), firstB?.map(\.symbol))
    }

    private func firstQuote(from stream: AsyncStream<[Quote]>) async -> [Quote]? {
        var iterator = stream.makeAsyncIterator()
        return await iterator.next()
    }
}
