import Foundation
import Core

/// Thread-safe WebSocket test double (actor) for strict-concurrency test targets.
public actor WebSocketClientTestDouble: WebSocketClient {
    public private(set) var connectURL: URL?
    public private(set) var sentMessages: [String] = []
    public private(set) var disconnectCount = 0

    private var receiveQueue: [Result<String, Error>] = []
    private var sendError: Error?

    public init() {}

    public func setSendError(_ error: Error?) {
        sendError = error
    }

    public func configureReceiveQueue(_ queue: [Result<String, Error>]) {
        receiveQueue = queue
    }

    public func configureNextReceive(_ text: String) {
        receiveQueue = [.success(text)]
    }

    public func connect(to url: URL) async throws {
        connectURL = url
    }

    public func send(text: String) async throws {
        if let sendError { throw sendError }
        sentMessages.append(text)
    }

    public func receive() async throws -> String {
        guard !receiveQueue.isEmpty else {
            throw WebSocketClientError.receiveFailed
        }
        let next = receiveQueue.removeFirst()
        switch next {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }

    public func disconnect() async {
        disconnectCount += 1
    }
}

public actor WebSocketInterceptorSpy: WebSocketInterceptor {
    public enum ConnectPhase: Equatable, Sendable {
        case willConnect
        case didConnect
    }

    public private(set) var connectPhases: [ConnectPhase] = []
    public private(set) var failures: [(Error, WebSocketPhase)] = []

    public init() {}

    public func willConnect(to url: URL) async {
        connectPhases.append(.willConnect)
    }

    public func didConnect(to url: URL) async {
        connectPhases.append(.didConnect)
    }

    public func willSend(text: String) async {}
    public func didSend(text: String) async {}
    public func willReceive(text: String) async {}
    public func didReceive(text: String) async {}

    public func didFail(_ error: Error, phase: WebSocketPhase) async {
        failures.append((error, phase))
    }
}
