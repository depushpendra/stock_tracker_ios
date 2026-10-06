import Core
import Domain
import Data

public enum QuoteFeedRepositoryFactory {
    public static func makeLive(
        configuration: AppConfiguration,
        webSocket: any WebSocketClient,
        catalog: SymbolCatalogProvider = BundledSymbolCatalog()
    ) throws -> any QuoteFeedRepository {
        let echoConfiguration = EchoFeedConfiguration(
            webSocketURL: configuration.webSocketURL,
            tickIntervalNanoseconds: configuration.tickIntervalNanoseconds,
            symbolsPerTick: configuration.symbolsPerTick
        )
        return try LiveQuoteFeedRepository(
            catalog: catalog,
            webSocket: webSocket,
            configuration: echoConfiguration
        )
    }
}
