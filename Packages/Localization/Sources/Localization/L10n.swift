import Foundation

/// Type-safe access to String Catalog keys (`Localizable.xcstrings` in this module).
public enum L10n {
    public static let stocksTitle = localizedString("Stocks")
    public static let sort = localizedString("Sort")
    public static let byPrice = localizedString("By Price")
    public static let byPriceChange = localizedString("By Price Change")
    public static let start = localizedString("Start")
    public static let stop = localizedString("Stop")

    public static let disconnected = localizedString("Disconnected")
    public static let connecting = localizedString("Connecting")
    public static let connected = localizedString("Connected")
    public static let connectionFailed = localizedString("Connection failed")

    public static func priceChangeUp(_ value: String) -> String {
        localizedString("Up \(value)")
    }

    public static func priceChangeDown(_ value: String) -> String {
        localizedString("Down \(value)")
    }

    public static let noChange = localizedString("No change")
    public static let aboutCompany = localizedString("About")
    public static let marketData = localizedString("Market data")
    public static let currency = localizedString("Currency")
    public static let exchange = localizedString("Exchange")
    public static let sector = localizedString("Sector")
    public static let country = localizedString("Country")
    public static let sessionChange = localizedString("Session change")
    public static let sessionChangePercent = localizedString("Session change %")
    public static let tickChange = localizedString("Tick change")
    public static let openPrice = localizedString("Session open")
    public static let lastUpdated = localizedString("Last updated")

    public static let layoutDirection = localizedString("Layout direction")
    public static let layoutAutomatic = localizedString("Automatic")
    public static let layoutLTR = localizedString("Left to right")
    public static let layoutRTL = localizedString("Right to left")

    public static func symbolDescription(ticker: String, fallback: String) -> String {
        let key = "symbol.\(ticker.lowercased()).description"
        return localizedString(key: key, default: fallback)
    }
}
