import Foundation
import Domain

public enum AppTelemetryEvent: Sendable, Equatable {
    case appLaunched
    case bootstrapSucceeded
    case bootstrapFailed(reason: String)
    case feedStarted
    case feedStopped
    case connectionStatusChanged(ConnectionStatus)
}

public protocol AppTelemetry: Sendable {
    func record(_ event: AppTelemetryEvent) async
}

public struct NoOpAppTelemetry: AppTelemetry {
    public init() {}
    public func record(_ event: AppTelemetryEvent) async {}
}

public actor OSLogAppTelemetry: AppTelemetry {
    private let logger: OSLogLogger

    public init(subsystem: String = "com.stocktracker.app", category: String = "telemetry") {
        logger = OSLogLogger(subsystem: subsystem, category: category)
    }

    public func record(_ event: AppTelemetryEvent) async {
        switch event {
        case .appLaunched:
            logger.info("App launched")
        case .bootstrapSucceeded:
            logger.info("Bootstrap succeeded")
        case .bootstrapFailed(let reason):
            logger.error("Bootstrap failed", metadata: ["reason": reason])
        case .feedStarted:
            logger.info("Price feed started")
        case .feedStopped:
            logger.info("Price feed stopped")
        case .connectionStatusChanged(let status):
            logger.info("Connection status", metadata: ["status": Self.statusLabel(status)])
        }
    }

    private static func statusLabel(_ status: ConnectionStatus) -> String {
        switch status {
        case .disconnected:
            return "disconnected"
        case .connecting:
            return "connecting"
        case .connected:
            return "connected"
        case .failed:
            return "failed"
        }
    }
}
