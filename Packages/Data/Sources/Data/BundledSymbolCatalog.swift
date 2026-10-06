import Foundation
import Domain

public protocol SymbolCatalogProvider: Sendable {
    func allSymbols() throws -> [StockSymbol]
}

public struct BundledSymbolCatalog: SymbolCatalogProvider {
    private struct DTO: Decodable {
        let symbol: String
        let name: String
        let description: String
        let seedPrice: Decimal
        let currencyCode: String?
        let exchange: String?
        let sector: String?
        let country: String?
    }

    private let bundle: Bundle

    public init() {
        self.bundle = .module
    }

    public init(bundle: Bundle) {
        self.bundle = bundle
    }

    public func allSymbols() throws -> [StockSymbol] {
        guard let url = bundle.url(forResource: "symbols", withExtension: "json") else {
            throw CatalogError.missingResource
        }
        let data = try Foundation.Data(contentsOf: url)
        let decoder = JSONDecoder()
        let dtos = try decoder.decode([DTO].self, from: data)
        return dtos.map {
            let currency = $0.currencyCode.flatMap(CurrencyCode.parse) ?? .usd
            return StockSymbol(
                symbol: Symbol(rawValue: $0.symbol),
                name: $0.name,
                description: $0.description,
                seedPrice: $0.seedPrice,
                currencyCode: currency,
                exchange: $0.exchange ?? "NASDAQ",
                sector: $0.sector ?? "Technology",
                country: $0.country ?? "United States"
            )
        }
    }
}

public enum CatalogError: Error, Equatable {
    case missingResource
}
