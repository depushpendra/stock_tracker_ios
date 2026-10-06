import SwiftUI
import Domain
import Localization

public struct ConnectionStatusView: View {
    @Environment(\.appTheme) private var theme

    let status: ConnectionStatus

    public init(status: ConnectionStatus) {
        self.status = status
    }

    public var body: some View {
        HStack(spacing: 8) {
            statusDot
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, theme.metrics.statusPillHorizontal)
        .padding(.vertical, theme.metrics.statusPillVertical)
        .background {
            Capsule()
                .fill(theme.colors.surfaceCard.opacity(0.92))
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
        .overlay {
            Capsule()
                .strokeBorder(theme.colors.surfaceCardStroke, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }

    @ViewBuilder
    private var statusDot: some View {
        if case .connecting = status {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .symbolEffect(.pulse, options: .repeating)
        } else {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
        }
    }

    private var title: String {
        switch status {
        case .disconnected:
            return L10n.disconnected
        case .connecting:
            return L10n.connecting
        case .connected:
            return L10n.connected
        case .failed:
            return L10n.connectionFailed
        }
    }

    private var color: Color {
        switch status {
        case .connected:
            return theme.colors.connectionConnected
        case .connecting:
            return theme.colors.connectionConnecting
        case .disconnected:
            return theme.colors.connectionDisconnected
        case .failed:
            return theme.colors.connectionFailed
        }
    }
}
