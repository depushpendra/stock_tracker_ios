import Foundation
import os

public struct OSLogLogger: Logger {
    private let logger: os.Logger

    public init(subsystem: String, category: String) {
        logger = os.Logger(subsystem: subsystem, category: category)
    }

    public func log(_ level: LogLevel, _ message: String, metadata: [String: String]) {
        let suffix = metadata.isEmpty ? "" : " | \(metadata.map { "\($0.key)=\($0.value)" }.joined(separator: ", "))"
        let line = message + suffix
        switch level {
        case .debug:
            logger.debug("\(line, privacy: .public)")
        case .info:
            logger.info("\(line, privacy: .public)")
        case .error:
            logger.error("\(line, privacy: .public)")
        }
    }
}
