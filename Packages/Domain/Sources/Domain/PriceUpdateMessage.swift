import Foundation

public struct PriceUpdateMessage: Codable, Sendable, Equatable {
    public static let schemaVersion = 1

    public let v: Int
    public let symbol: String
    public let price: Decimal
    public let sentAt: Date

    public init(v: Int = schemaVersion, symbol: String, price: Decimal, sentAt: Date) {
        self.v = v
        self.symbol = symbol
        self.price = price
        self.sentAt = sentAt
    }
}

public enum PriceUpdateMessageDecoder {
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    public static func decode(from data: Data) throws -> PriceUpdateMessage {
        let message = try decoder.decode(PriceUpdateMessage.self, from: data)
        guard message.v == PriceUpdateMessage.schemaVersion else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Unsupported schema version")
            )
        }
        return message
    }

    public static func decode(from string: String) throws -> PriceUpdateMessage {
        guard let data = string.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Invalid UTF-8")
            )
        }
        return try decode(from: data)
    }
}

public enum PriceUpdateMessageEncoder {
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    public static func encode(_ message: PriceUpdateMessage) throws -> String {
        let data = try encoder.encode(message)
        guard let string = String(data: data, encoding: .utf8) else {
            throw EncodingError.invalidValue(
                message,
                .init(codingPath: [], debugDescription: "Invalid UTF-8")
            )
        }
        return string
    }
}
