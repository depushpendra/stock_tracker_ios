import Foundation
import Core
import Domain
import Features
import Data

public enum CompositionRoot {
    public static func make(configuration: AppConfiguration = AppConfiguration.load()) -> Result<AppDependencies, BootstrapError> {
        let logger = OSLogLogger(subsystem: "com.stocktracker.app", category: "network")
        let telemetry = OSLogAppTelemetry()
        let metricsRecorder = WebSocketMetricsRecorder()
        let webSocket = InterceptingWebSocketClient(
            inner: URLSessionWebSocketClient(),
            interceptors: [
                LoggingWebSocketInterceptor(logger: logger),
                MetricWebSocketInterceptor(recorder: metricsRecorder, logger: logger)
            ]
        )

        do {
            let repository = try QuoteFeedRepositoryFactory.makeLive(
                configuration: configuration,
                webSocket: webSocket
            )
            let dependencies = AppDependencies(
                repository: repository,
                configuration: configuration,
                metricsRecorder: metricsRecorder,
                telemetry: telemetry
            )
            Task { await telemetry.record(.bootstrapSucceeded) }
            return .success(dependencies)
        } catch CatalogError.missingResource {
            Task { await telemetry.record(.bootstrapFailed(reason: "catalogFailed")) }
            return .failure(.catalogFailed)
        } catch {
            Task { await telemetry.record(.bootstrapFailed(reason: error.localizedDescription)) }
            return .failure(.repositoryFailed(error.localizedDescription))
        }
    }
}

public final class AppDependencies: Sendable {
    public let configuration: AppConfiguration
    public let metricsRecorder: WebSocketMetricsRecorder
    public let telemetry: any AppTelemetry

    private let repository: any QuoteFeedRepository
    private let quoteFeedSession: QuoteFeedSession
    private let observeQuotes: ObserveQuotesUseCase
    private let observeConnection: ObserveConnectionStatusUseCase
    private let getSymbolDetails: GetSymbolDetailsUseCase

    @MainActor private var cachedListViewModel: SymbolListViewModel?
    @MainActor private var cachedDetailViewModels: [Symbol: SymbolDetailViewModel] = [:]

    public init(
        repository: any QuoteFeedRepository,
        configuration: AppConfiguration,
        metricsRecorder: WebSocketMetricsRecorder,
        telemetry: any AppTelemetry
    ) {
        self.repository = repository
        self.configuration = configuration
        self.metricsRecorder = metricsRecorder
        self.telemetry = telemetry
        self.observeQuotes = ObserveQuotesUseCase(repository: repository)
        self.observeConnection = ObserveConnectionStatusUseCase(repository: repository)
        self.getSymbolDetails = GetSymbolDetailsUseCase(repository: repository)
        self.quoteFeedSession = QuoteFeedSession(
            startFeed: StartPriceFeedUseCase(repository: repository),
            stopFeed: StopPriceFeedUseCase(repository: repository)
        )
    }

    @MainActor
    public func listViewModel() -> SymbolListViewModel {
        if let cachedListViewModel {
            return cachedListViewModel
        }
        let viewModel = SymbolListViewModel(
            observeQuotes: observeQuotes,
            observeConnection: observeConnection,
            quoteFeedSession: quoteFeedSession,
            telemetry: telemetry
        )
        cachedListViewModel = viewModel
        return viewModel
    }

    @MainActor
    public func makeSymbolDetailViewModel(symbol: Symbol) -> SymbolDetailViewModel {
        if let cached = cachedDetailViewModels[symbol] {
            return cached
        }
        let viewModel = SymbolDetailViewModel(
            symbol: symbol,
            getDetails: getSymbolDetails,
            observeQuotes: observeQuotes
        )
        cachedDetailViewModels[symbol] = viewModel
        return viewModel
    }
}
