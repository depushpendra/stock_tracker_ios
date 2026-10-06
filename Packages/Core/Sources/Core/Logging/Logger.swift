import Foundation

public enum LogLevel: Sendable {
    case debug
    case info
    case error
}

public protocol Logger: Sendable {
    func log(_ level: LogLevel, _ message: String, metadata: [String: String])
}

public extension Logger {
    func debug(_ message: String, metadata: [String: String] = [:]) {
        log(.debug, message, metadata: metadata)
    }

    func info(_ message: String, metadata: [String: String] = [:]) {
        log(.info, message, metadata: metadata)
    }

    func error(_ message: String, metadata: [String: String] = [:]) {
        log(.error, message, metadata: metadata)
    }
}

public struct NoOpLogger: Logger {
    public init() {}

    public func log(_ level: LogLevel, _ message: String, metadata: [String: String]) {}
}
