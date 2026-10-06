import Foundation
import Domain

public struct AppConfiguration: Sendable, Equatable {
    public let webSocketURL: URL
    public let tickIntervalNanoseconds: UInt64
    public let symbolsPerTick: Int
    public let locale: Locale
    /// When set, formats all prices with this ISO code instead of each symbol’s catalog currency.
    public let displayCurrencyCode: CurrencyCode?

    public init(
        webSocketURL: URL,
        tickIntervalNanoseconds: UInt64 = 800_000_000,
        symbolsPerTick: Int = 2,
        locale: Locale = .autoupdatingCurrent,
        displayCurrencyCode: CurrencyCode? = nil
    ) {
        self.webSocketURL = webSocketURL
        self.tickIntervalNanoseconds = tickIntervalNanoseconds
        self.symbolsPerTick = max(1, symbolsPerTick)
        self.locale = locale
        self.displayCurrencyCode = displayCurrencyCode
    }

    public static let `default` = AppConfiguration(
        webSocketURL: URL(string: "wss://ws.postman-echo.com/raw")!
    )

    public static func load(from bundle: Bundle = .main) -> AppConfiguration {
        guard
            let path = bundle.path(forResource: "AppConfig", ofType: "plist"),
            let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any],
            let urlString = dictionary["WebSocketURL"] as? String,
            let url = URL(string: urlString)
        else {
            return .default
        }

        let tick = dictionary["TickIntervalNanoseconds"] as? UInt64 ?? 800_000_000
        let perTick = dictionary["SymbolsPerTick"] as? Int ?? 2
        let locale: Locale = {
            guard let identifier = dictionary["LocaleIdentifier"] as? String else {
                return .autoupdatingCurrent
            }
            return Locale(identifier: identifier)
        }()
        let displayCurrencyCode: CurrencyCode? = {
            guard let raw = dictionary["CurrencyCode"] as? String else { return nil }
            return CurrencyCode.parse(raw)
        }()

        return AppConfiguration(
            webSocketURL: url,
            tickIntervalNanoseconds: tick,
            symbolsPerTick: perTick,
            locale: locale,
            displayCurrencyCode: displayCurrencyCode
        )
    }
}
