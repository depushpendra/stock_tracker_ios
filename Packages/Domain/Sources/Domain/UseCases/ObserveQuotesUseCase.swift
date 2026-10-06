import Foundation

public struct ObserveQuotesUseCase: Sendable {
    private let repository: any QuoteFeedRepository
    private let sortQuotes: SortQuotesUseCase

    public init(repository: any QuoteFeedRepository, sortQuotes: SortQuotesUseCase = SortQuotesUseCase()) {
        self.repository = repository
        self.sortQuotes = sortQuotes
    }

    public func execute() -> AsyncStream<[Quote]> {
        repository.quotesStream()
    }

    public func execute(sortBy: QuoteSortOption) -> AsyncStream<[Quote]> {
        let sortQuotes = sortQuotes
        return AsyncStream { continuation in
            let task = Task {
                for await quotes in repository.quotesStream() {
                    continuation.yield(sortQuotes.execute(quotes: quotes, sortBy: sortBy))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
