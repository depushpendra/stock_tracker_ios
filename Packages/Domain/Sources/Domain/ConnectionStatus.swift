import Foundation

public enum ConnectionStatus: Equatable, Sendable {
    case disconnected
    case connecting
    case connected
    case failed(String)
}
