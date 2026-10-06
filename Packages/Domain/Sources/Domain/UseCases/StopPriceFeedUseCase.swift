import Foundation

public struct StopPriceFeedUseCase: Sendable {
    private let repository: any QuoteFeedRepository

    public init(repository: any QuoteFeedRepository) {
        self.repository = repository
    }

    public func execute() async {
        await repository.stopFeed()
    }
}
