import Foundation
import Domain

/// Abstraction for live price engines. `EchoPriceFeedEngine` is the demo implementation;
/// production apps swap in a licensed market-data WebSocket client behind the same repository.
public protocol PriceFeedEngine: Sendable {
    func setHandlers(
        onStatus: @escaping @Sendable (ConnectionStatus) -> Void,
        onQuote: @escaping @Sendable (PriceUpdateMessage) -> Void
    ) async
    func start() async
    func stop() async
}

extension EchoPriceFeedEngine: PriceFeedEngine {}
