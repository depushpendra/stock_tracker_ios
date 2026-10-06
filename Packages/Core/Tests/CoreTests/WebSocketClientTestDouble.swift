import Foundation
@testable import Core

actor WebSocketClientTestDouble: WebSocketClient {
    private(set) var connectURL: URL?
    private(set) var sentMessages: [String] = []
    private(set) var disconnectCount = 0

    private var receiveQueue: [Result<String, Error>] = []
    private var sendError: Error?

    func configureNextReceive(_ text: String) {
        receiveQueue = [.success(text)]
    }

    func setSendError(_ error: Error?) {
        sendError = error
    }

    func connect(to url: URL) async throws {
        connectURL = url
    }

    func send(text: String) async throws {
        if let sendError { throw sendError }
        sentMessages.append(text)
    }

    func receive() async throws -> String {
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

    func disconnect() async {
        disconnectCount += 1
    }
}

actor WebSocketInterceptorSpy: WebSocketInterceptor {
    enum ConnectPhase: Equatable, Sendable {
        case willConnect
        case didConnect
    }

    private(set) var connectPhases: [ConnectPhase] = []
    private(set) var failures: [(Error, WebSocketPhase)] = []

    func willConnect(to url: URL) async {
        connectPhases.append(.willConnect)
    }

    func didConnect(to url: URL) async {
        connectPhases.append(.didConnect)
    }

    func willSend(text: String) async {}
    func didSend(text: String) async {}
    func willReceive(text: String) async {}
    func didReceive(text: String) async {}

    func didFail(_ error: Error, phase: WebSocketPhase) async {
        failures.append((error, phase))
    }
}
