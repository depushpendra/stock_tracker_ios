import XCTest
@testable import Core
final class URLSessionWebSocketClientTests: XCTestCase {
    func testMockEchoRoundTrip() async throws {
        let mock = WebSocketClientTestDouble()
        let url = URL(string: "wss://ws.postman-echo.com/raw")!
        try await mock.connect(to: url)
        await mock.configureNextReceive("{\"v\":1,\"symbol\":\"AAPL\",\"price\":1,\"sentAt\":\"2026-10-05T15:00:00Z\"}")
        try await mock.send(text: "ping")
        let response = try await mock.receive()
        let sent = await mock.sentMessages
        XCTAssertEqual(sent, ["ping"])
        XCTAssertTrue(response.contains("AAPL"))
        await mock.disconnect()
        let disconnectCount = await mock.disconnectCount
        XCTAssertEqual(disconnectCount, 1)
    }

    func testNotConnectedThrows() async {
        let client = URLSessionWebSocketClient()
        do {
            _ = try await client.send(text: "x")
            XCTFail("Expected not connected")
        } catch WebSocketClientError.notConnected {
            // expected
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }
}
