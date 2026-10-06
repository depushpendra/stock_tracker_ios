import Foundation
import Observation
import Core
import Domain

@MainActor
@Observable
public final class SymbolListViewModel {
    public private(set) var quotes: [Quote] = []
    public private(set) var connectionStatus: ConnectionStatus = .disconnected
    public var sortOption: QuoteSortOption = .price

    private let observeQuotes: ObserveQuotesUseCase
    private let observeConnection: ObserveConnectionStatusUseCase
    private let quoteFeedSession: QuoteFeedSession
    private let sortQuotes: SortQuotesUseCase
    private let telemetry: any AppTelemetry

    private var statusTask: Task<Void, Never>?
    private var quotesTask: Task<Void, Never>?
    private var latestQuotes: [Quote] = []
    private var isObserving = false

    public init(
        observeQuotes: ObserveQuotesUseCase,
        observeConnection: ObserveConnectionStatusUseCase,
        quoteFeedSession: QuoteFeedSession,
        sortQuotes: SortQuotesUseCase = SortQuotesUseCase(),
        telemetry: any AppTelemetry = NoOpAppTelemetry()
    ) {
        self.observeQuotes = observeQuotes
        self.observeConnection = observeConnection
        self.quoteFeedSession = quoteFeedSession
        self.sortQuotes = sortQuotes
        self.telemetry = telemetry
    }

    public func startObservingIfNeeded() {
        guard !isObserving else { return }
        isObserving = true
        statusTask = Task { @MainActor in
            for await status in observeConnection.execute() {
                connectionStatus = status
                await telemetry.record(.connectionStatusChanged(status))
            }
        }
        quotesTask = Task { @MainActor in
            await observeQuoteUpdates()
        }
    }

    public var isFeedRunning: Bool {
        switch connectionStatus {
        case .connected, .connecting:
            return true
        case .disconnected, .failed:
            return false
        }
    }

    public func toggleFeed() async {
        if isFeedRunning {
            await quoteFeedSession.stop()
            await telemetry.record(.feedStopped)
        } else {
            await quoteFeedSession.start()
            await telemetry.record(.feedStarted)
        }
    }

    public func applySort(_ option: QuoteSortOption) {
        sortOption = option
        quotes = sortQuotes.execute(quotes: latestQuotes, sortBy: option)
    }

    private func observeQuoteUpdates() async {
        for await snapshot in observeQuotes.execute() {
            latestQuotes = snapshot
            quotes = sortQuotes.execute(quotes: snapshot, sortBy: sortOption)
        }
    }
}
