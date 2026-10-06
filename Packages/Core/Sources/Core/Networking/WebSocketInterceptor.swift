import Foundation

public enum WebSocketPhase: Sendable, Equatable {
    case connect
    case send
    case receive
    case disconnect
}

public protocol WebSocketInterceptor: Sendable {
    func willConnect(to url: URL) async
    func didConnect(to url: URL) async
    func willSend(text: String) async
    func didSend(text: String) async
    func willReceive(text: String) async
    func didReceive(text: String) async
    func didFail(_ error: Error, phase: WebSocketPhase) async
}

public struct PassthroughWebSocketInterceptor: WebSocketInterceptor {
    public init() {}

    public func willConnect(to url: URL) async {}
    public func didConnect(to url: URL) async {}
    public func willSend(text: String) async {}
    public func didSend(text: String) async {}
    public func willReceive(text: String) async {}
    public func didReceive(text: String) async {}
    public func didFail(_ error: Error, phase: WebSocketPhase) async {}
}

public struct LoggingWebSocketInterceptor: WebSocketInterceptor {
    private let logger: any Logger

    public init(logger: any Logger) {
        self.logger = logger
    }

    public func willConnect(to url: URL) async {
        logger.info("WebSocket connecting", metadata: ["host": url.host ?? "unknown"])
    }

    public func didConnect(to url: URL) async {
        logger.info("WebSocket connected", metadata: ["host": url.host ?? "unknown"])
    }

    public func willSend(text: String) async {
        logger.debug("WebSocket send", metadata: ["bytes": "\(text.utf8.count)"])
    }

    public func didSend(text: String) async {}

    public func willReceive(text: String) async {}

    public func didReceive(text: String) async {
        logger.debug("WebSocket receive", metadata: ["bytes": "\(text.utf8.count)"])
    }

    public func didFail(_ error: Error, phase: WebSocketPhase) async {
        logger.error(
            "WebSocket failure",
            metadata: ["phase": "\(phase)", "error": String(describing: error)]
        )
    }
}
