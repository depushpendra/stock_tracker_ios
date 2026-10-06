import Foundation

public struct WebSocketMetrics: Sendable, Equatable {
    public var connectCount: Int = 0
    public var sendCount: Int = 0
    public var receiveCount: Int = 0
    public var failureCount: Int = 0
}

public actor WebSocketMetricsRecorder {
    public private(set) var metrics = WebSocketMetrics()

    public init() {}

    func recordConnect() { metrics.connectCount += 1 }
    func recordSend() { metrics.sendCount += 1 }
    func recordReceive() { metrics.receiveCount += 1 }
    func recordFailure() { metrics.failureCount += 1 }

    public func snapshot() -> WebSocketMetrics {
        metrics
    }
}

public struct MetricWebSocketInterceptor: WebSocketInterceptor {
    private let recorder: WebSocketMetricsRecorder
    private let logger: any Logger

    public init(recorder: WebSocketMetricsRecorder, logger: any Logger) {
        self.recorder = recorder
        self.logger = logger
    }

    public func willConnect(to url: URL) async {}

    public func didConnect(to url: URL) async {
        await recorder.recordConnect()
        logger.info("WebSocket connected", metadata: ["host": url.host ?? "unknown"])
    }

    public func willSend(text: String) async {}

    public func didSend(text: String) async {
        await recorder.recordSend()
    }

    public func willReceive(text: String) async {}

    public func didReceive(text: String) async {
        await recorder.recordReceive()
    }

    public func didFail(_ error: Error, phase: WebSocketPhase) async {
        await recorder.recordFailure()
        logger.error("WebSocket failure", metadata: ["phase": "\(phase)", "error": String(describing: error)])
    }
}
