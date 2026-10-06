import Foundation

public struct StartPriceFeedUseCase: Sendable {
    private let repository: any QuoteFeedRepository

    public init(repository: any QuoteFeedRepository) {
        self.repository = repository
    }

    public func execute() async {
        await repository.startFeed()
    }
}
