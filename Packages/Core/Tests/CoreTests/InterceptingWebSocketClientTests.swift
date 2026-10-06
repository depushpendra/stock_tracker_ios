import XCTest
@testable import Core
final class InterceptingWebSocketClientTests: XCTestCase {
    func testConnectNotifiesInterceptors() async throws {
        let mock = WebSocketClientTestDouble()
        let spy = WebSocketInterceptorSpy()
        let client = InterceptingWebSocketClient(inner: mock, interceptors: [spy])

        try await client.connect(to: URL(string: "wss://example.com")!)

        let phases = await spy.connectPhases
        XCTAssertEqual(phases, [.willConnect, .didConnect])
    }

    func testSendFailureNotifiesInterceptor() async {
        let mock = WebSocketClientTestDouble()
        await mock.setSendError(WebSocketClientError.sendFailed as Error?)
        let spy = WebSocketInterceptorSpy()
        let client = InterceptingWebSocketClient(inner: mock, interceptors: [spy])

        do {
            try await client.send(text: "{}")
            XCTFail("Expected send to throw")
        } catch {
            let failures = await spy.failures
            XCTAssertEqual(failures.count, 1)
            XCTAssertEqual(failures.first?.1, .send)
        }
    }
}
