import Foundation

/// Decorator that runs a chain of interceptors around a concrete `WebSocketClient`.
public struct InterceptingWebSocketClient: WebSocketClient {
    private let inner: any WebSocketClient
    private let interceptors: [any WebSocketInterceptor]

    public init(inner: any WebSocketClient, interceptors: [any WebSocketInterceptor]) {
        self.inner = inner
        self.interceptors = interceptors
    }

    public func connect(to url: URL) async throws {
        for interceptor in interceptors {
            await interceptor.willConnect(to: url)
        }
        do {
            try await inner.connect(to: url)
            for interceptor in interceptors {
                await interceptor.didConnect(to: url)
            }
        } catch {
            for interceptor in interceptors {
                await interceptor.didFail(error, phase: .connect)
            }
            throw error
        }
    }

    public func send(text: String) async throws {
        for interceptor in interceptors {
            await interceptor.willSend(text: text)
        }
        do {
            try await inner.send(text: text)
            for interceptor in interceptors {
                await interceptor.didSend(text: text)
            }
        } catch {
            for interceptor in interceptors {
                await interceptor.didFail(error, phase: .send)
            }
            throw error
        }
    }

    public func receive() async throws -> String {
        do {
            let text = try await inner.receive()
            for interceptor in interceptors {
                await interceptor.willReceive(text: text)
            }
            for interceptor in interceptors {
                await interceptor.didReceive(text: text)
            }
            return text
        } catch {
            for interceptor in interceptors {
                await interceptor.didFail(error, phase: .receive)
            }
            throw error
        }
    }

    public func disconnect() async {
        await inner.disconnect()
    }
}
