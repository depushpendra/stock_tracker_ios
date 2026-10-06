/// App-scoped feed lifecycle (Start/Stop). Screens subscribe only; they do not own the connection.
public struct QuoteFeedSession: Sendable {
    private let startFeed: StartPriceFeedUseCase
    private let stopFeed: StopPriceFeedUseCase

    public init(startFeed: StartPriceFeedUseCase, stopFeed: StopPriceFeedUseCase) {
        self.startFeed = startFeed
        self.stopFeed = stopFeed
    }

    public func start() async {
        await startFeed.execute()
    }

    public func stop() async {
        await stopFeed.execute()
    }
}
