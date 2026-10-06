import Foundation

/// Application navigation contract (Coordinator pattern).
@MainActor
public protocol AppCoordinating: AnyObject {
    func showSymbolDetail(_ symbol: Symbol)
    /// Handles deep links such as `stocktracker://symbol/NVDA`.
    @discardableResult
    func openURL(_ url: URL) -> Bool
}

public enum AppRoute: Hashable, Sendable {
    case symbolDetail(Symbol)
}

public enum DeepLinkParser {
    public static func symbol(from url: URL) -> Symbol? {
        guard url.scheme?.lowercased() == "stocktracker" else { return nil }
        if url.host?.lowercased() == "symbol" {
            let ticker = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            guard !ticker.isEmpty else { return nil }
            return Symbol(rawValue: ticker.uppercased())
        }
        return nil
    }
}
