import SwiftUI
import UIKit

public struct StockIconDescriptor: Sendable, Equatable {
    public let sfSymbolName: String
    public let assetName: String?
    public let tint: Color

    public init(sfSymbolName: String, assetName: String? = nil, tint: Color) {
        self.sfSymbolName = sfSymbolName
        self.assetName = assetName
        self.tint = tint
    }
}

/// Maps tickers to SF Symbols and optional bundled logo assets (`StockIcons.xcassets`).
public enum StockIconCatalog {
    private static let bundle = Bundle.module

    public static func descriptor(for ticker: String) -> StockIconDescriptor {
        let key = ticker.uppercased()
        if let mapped = catalog[key] {
            return mapped
        }
        return StockIconDescriptor(
            sfSymbolName: "chart.line.uptrend.xyaxis",
            assetName: nil,
            tint: Color(red: 0.35, green: 0.45, blue: 0.95)
        )
    }

    public static func uiImage(for ticker: String) -> UIImage? {
        guard let asset = descriptor(for: ticker).assetName else { return nil }
        return UIImage(named: asset, in: bundle, compatibleWith: nil)
    }

    private static let catalog: [String: StockIconDescriptor] = [
        "AAPL": .init(sfSymbolName: "apple.logo", tint: .primary),
        "GOOG": .init(sfSymbolName: "magnifyingglass.circle.fill", tint: Color(red: 0.92, green: 0.25, blue: 0.21)),
        "TSLA": .init(sfSymbolName: "bolt.car.fill", tint: Color(red: 0.86, green: 0.12, blue: 0.18)),
        "AMZN": .init(sfSymbolName: "shippingbox.fill", tint: Color(red: 1.0, green: 0.6, blue: 0.05)),
        "MSFT": .init(sfSymbolName: "square.grid.2x2.fill", tint: Color(red: 0.0, green: 0.45, blue: 0.78)),
        "NVDA": .init(sfSymbolName: "cpu.fill", tint: Color(red: 0.47, green: 0.73, blue: 0.0)),
        "META": .init(sfSymbolName: "bubble.left.and.bubble.right.fill", tint: Color(red: 0.23, green: 0.35, blue: 0.95)),
        "NFLX": .init(sfSymbolName: "play.tv.fill", tint: Color(red: 0.89, green: 0.08, blue: 0.14)),
        "AMD": .init(sfSymbolName: "memorychip", tint: Color(red: 0.0, green: 0.55, blue: 0.75)),
        "INTC": .init(sfSymbolName: "circuitboard", tint: Color(red: 0.0, green: 0.45, blue: 0.85)),
        "CRM": .init(sfSymbolName: "cloud.fill", tint: Color(red: 0.0, green: 0.65, blue: 0.85)),
        "ORCL": .init(sfSymbolName: "cylinder.split.1x2.fill", tint: Color(red: 0.86, green: 0.08, blue: 0.0)),
        "ADBE": .init(sfSymbolName: "paintbrush.pointed.fill", tint: Color(red: 0.88, green: 0.0, blue: 0.0)),
        "PYPL": .init(sfSymbolName: "creditcard.fill", tint: Color(red: 0.0, green: 0.3, blue: 0.65)),
        "SHOP": .init(sfSymbolName: "bag.fill", tint: Color(red: 0.55, green: 0.75, blue: 0.25)),
        "UBER": .init(sfSymbolName: "car.fill", tint: Color(red: 0.0, green: 0.0, blue: 0.0)),
        "ABNB": .init(sfSymbolName: "house.lodge.fill", tint: Color(red: 0.92, green: 0.22, blue: 0.28)),
        "COIN": .init(sfSymbolName: "bitcoinsign.circle.fill", tint: Color(red: 0.0, green: 0.48, blue: 0.98)),
        "BA": .init(sfSymbolName: "airplane", tint: Color(red: 0.0, green: 0.2, blue: 0.55)),
        "DIS": .init(sfSymbolName: "sparkles.tv.fill", tint: Color(red: 0.08, green: 0.45, blue: 0.95)),
        "JPM": .init(sfSymbolName: "building.columns.fill", tint: Color(red: 0.45, green: 0.25, blue: 0.65)),
        "V": .init(sfSymbolName: "v.circle.fill", tint: Color(red: 0.0, green: 0.25, blue: 0.55)),
        "MA": .init(sfSymbolName: "creditcard.circle.fill", tint: Color(red: 0.92, green: 0.35, blue: 0.05)),
        "WMT": .init(sfSymbolName: "cart.fill", tint: Color(red: 0.0, green: 0.45, blue: 0.78)),
        "IBM": .init(sfSymbolName: "server.rack", tint: Color(red: 0.0, green: 0.55, blue: 0.85))
    ]
}
