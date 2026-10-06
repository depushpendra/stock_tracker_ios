import Foundation

public enum BootstrapError: Error, Equatable, Sendable, LocalizedError {
    case catalogFailed
    case repositoryFailed(String)

    public var errorDescription: String? {
        switch self {
        case .catalogFailed:
            return "Unable to load the stock catalog."
        case .repositoryFailed(let reason):
            return "Unable to start market data: \(reason)"
        }
    }
}
