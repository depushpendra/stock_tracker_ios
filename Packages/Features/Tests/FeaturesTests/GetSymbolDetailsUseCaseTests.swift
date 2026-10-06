import Foundation
import Testing
import Domain
import TestSupport

@Suite("GetSymbolDetailsUseCase")
struct GetSymbolDetailsUseCaseTests {
    @Test("Returns metadata and quote when symbol exists")
    func executeReturnsDetails() async {
        let mock = QuoteFeedRepositoryMock()
        let symbol = Symbol(rawValue: "AAPL")
        await mock.setMetadata([
            StockSymbol(symbol: symbol, name: "Apple Inc.", description: "Tech", seedPrice: 100),
        ])
        await mock.setQuotes([
            Quote(symbol: symbol, name: "Apple Inc.", price: 110, change: 10, updatedAt: .now),
        ])

        let useCase = GetSymbolDetailsUseCase(repository: mock)
        let details = await useCase.execute(symbol: symbol)

        #expect(details?.metadata.name == "Apple Inc.")
        #expect(details?.quote?.price == 110)
    }
}
