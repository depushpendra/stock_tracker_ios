import Foundation
import Core
import Domain

public struct EchoFeedConfiguration: Sendable {
    public let webSocketURL: URL
    public let tickIntervalNanoseconds: UInt64
    public let symbolsPerTick: Int

    public init(
        webSocketURL: URL = URL(string: "wss://ws.postman-echo.com/raw")!,
        tickIntervalNanoseconds: UInt64 = 800_000_000,
        symbolsPerTick: Int = 2
    ) {
        self.webSocketURL = webSocketURL
        self.tickIntervalNanoseconds = tickIntervalNanoseconds
        self.symbolsPerTick = max(1, symbolsPerTick)
    }
}

public actor EchoPriceFeedEngine {
    public typealias StatusHandler = @Sendable (ConnectionStatus) -> Void
    public typealias QuoteHandler = @Sendable (PriceUpdateMessage) -> Void

    private let webSocket: any WebSocketClient
    private let configuration: EchoFeedConfiguration
    private let symbols: [StockSymbol]
    private var prices: [Symbol: Decimal]
    private var previousPrices: [Symbol: Decimal]
    private var roundRobinIndex: Int = 0

    private var feedTask: Task<Void, Never>?
    private var onStatus: StatusHandler?
    private var onQuote: QuoteHandler?

    public init(
        webSocket: any WebSocketClient,
        symbols: [StockSymbol],
        configuration: EchoFeedConfiguration = EchoFeedConfiguration()
    ) {
        self.webSocket = webSocket
        self.configuration = configuration
        self.symbols = symbols
        self.prices = Dictionary(uniqueKeysWithValues: symbols.map { ($0.symbol, $0.seedPrice) })
        self.previousPrices = prices
    }

    public func setHandlers(onStatus: @escaping StatusHandler, onQuote: @escaping QuoteHandler) {
        self.onStatus = onStatus
        self.onQuote = onQuote
    }

    public func start() {
        guard feedTask == nil else { return }
        feedTask = Task { [weak self] in
            await self?.runFeedLoop()
        }
    }

    public func stop() async {
        feedTask?.cancel()
        feedTask = nil
        await webSocket.disconnect()
        onStatus?(.disconnected)
    }

    private func runFeedLoop() async {
        onStatus?(.connecting)
        do {
            try await webSocket.connect(to: configuration.webSocketURL)
            onStatus?(.connected)
        } catch {
            onStatus?(.failed(error.localizedDescription))
            feedTask = nil
            return
        }

        while !Task.isCancelled {
            do {
                try await sendRoundRobinUpdates { echoed in
                    try handleEcho(echoed)
                }
            } catch {
                if Task.isCancelled { break }
                onStatus?(.failed(error.localizedDescription))
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                onStatus?(.connecting)
                do {
                    try await webSocket.connect(to: configuration.webSocketURL)
                    onStatus?(.connected)
                } catch {
                    onStatus?(.failed(error.localizedDescription))
                    break
                }
            }
            try? await Task.sleep(nanoseconds: configuration.tickIntervalNanoseconds)
        }

        await webSocket.disconnect()
        onStatus?(.disconnected)
        feedTask = nil
    }

    private func sendRoundRobinUpdates(handleEcho: (String) throws -> Void) async throws {
        guard !symbols.isEmpty else { return }
        for _ in 0..<configuration.symbolsPerTick {
            let symbol = symbols[roundRobinIndex % symbols.count]
            roundRobinIndex += 1
            try await sendUpdate(for: symbol)
            let echoed = try await webSocket.receive()
            try handleEcho(echoed)
        }
    }

    private func sendUpdate(for symbol: StockSymbol) async throws {
        let current = prices[symbol.symbol] ?? symbol.seedPrice
        let delta = Decimal(Double.random(in: -2.5 ... 2.5))
        let next = max(current + delta, 0.01)
        previousPrices[symbol.symbol] = current
        prices[symbol.symbol] = next

        let message = PriceUpdateMessage(
            symbol: symbol.symbol.rawValue,
            price: next,
            sentAt: .now
        )
        let payload = try PriceUpdateMessageEncoder.encode(message)
        try await webSocket.send(text: payload)
    }

    private func handleEcho(_ text: String) throws {
        let message = try PriceUpdateMessageDecoder.decode(from: text)
        let symbol = Symbol(rawValue: message.symbol)
        guard symbols.contains(where: { $0.symbol == symbol }) else { return }

        let previous = prices[symbol] ?? message.price
        previousPrices[symbol] = previous
        prices[symbol] = message.price
        onQuote?(message)
    }
}
