import Foundation

public struct Symbol: RawRepresentable, Hashable, Sendable, Codable, Identifiable {
    public var rawValue: String

    public var id: String { rawValue }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
