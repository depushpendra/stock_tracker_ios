import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class SymbolDetailViewModel {
    public let symbol: Symbol

    public private(set) var details: SymbolDetails?
    public private(set) var quote: Quote?
    public private(set) var isLoadingDetails = true

    private let getDetails: GetSymbolDetailsUseCase
    private let observeQuotes: ObserveQuotesUseCase
    private var observeTask: Task<Void, Never>?
    private var isObserving = false

    public init(symbol: Symbol, getDetails: GetSymbolDetailsUseCase, observeQuotes: ObserveQuotesUseCase) {
        self.symbol = symbol
        self.getDetails = getDetails
        self.observeQuotes = observeQuotes
    }

    public func startObservingIfNeeded() {
        guard !isObserving else { return }
        isObserving = true
        observeTask = Task { @MainActor in
            await loadDetailsIfNeeded()
            for await quotes in observeQuotes.execute() {
                if let updated = quotes.first(where: { $0.symbol == symbol }) {
                    quote = updated
                }
            }
        }
    }

    private func loadDetailsIfNeeded() async {
        guard details == nil else {
            isLoadingDetails = false
            return
        }
        defer { isLoadingDetails = false }
        guard !Task.isCancelled else { return }
        details = await getDetails.execute(symbol: symbol)
        guard !Task.isCancelled else { return }
        quote = details?.quote
    }
}
