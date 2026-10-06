import Foundation

public struct ObserveConnectionStatusUseCase: Sendable {
    private let repository: any QuoteFeedRepository

    public init(repository: any QuoteFeedRepository) {
        self.repository = repository
    }

    public func execute() -> AsyncStream<ConnectionStatus> {
        repository.connectionStatusStream()
    }
}
