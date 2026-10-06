import Foundation

public actor URLSessionWebSocketClient: WebSocketClient {
    private let session: URLSession
    private var task: URLSessionWebSocketTask?

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func connect(to url: URL) async throws {
        task?.cancel(with: .goingAway, reason: nil)
        let webSocketTask = session.webSocketTask(with: url)
        task = webSocketTask
        webSocketTask.resume()
    }

    public func send(text: String) async throws {
        let webSocketTask = try currentTask()
        try await webSocketTask.send(.string(text))
    }

    public func receive() async throws -> String {
        let webSocketTask = try currentTask()
        let message = try await webSocketTask.receive()
        switch message {
        case .string(let text):
            return text
        case .data(let data):
            guard let text = String(data: data, encoding: .utf8) else {
                throw WebSocketClientError.receiveFailed
            }
            return text
        @unknown default:
            throw WebSocketClientError.receiveFailed
        }
    }

    public func disconnect() async {
        task?.cancel(with: .normalClosure, reason: nil)
        task = nil
    }

    private func currentTask() throws -> URLSessionWebSocketTask {
        guard let task else {
            throw WebSocketClientError.notConnected
        }
        return task
    }
}
