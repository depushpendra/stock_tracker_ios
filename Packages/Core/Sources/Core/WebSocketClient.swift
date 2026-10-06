import Foundation

public enum WebSocketClientError: Error, Equatable, Sendable {
    case notConnected
    case sendFailed
    case receiveFailed
    case closed
}

public protocol WebSocketClient: Sendable {
    func connect(to url: URL) async throws
    func send(text: String) async throws
    func receive() async throws -> String
    func disconnect() async
}
