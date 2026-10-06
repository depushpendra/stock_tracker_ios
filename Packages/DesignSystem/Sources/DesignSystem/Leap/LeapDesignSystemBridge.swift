import SwiftUI

/// Anti-corruption layer for **Leap SDK** UI (implement in app target with Leap SPM).
public struct LeapUIAdapter: Sendable {
    public init() {}

    @MainActor
    public func statusChip(title: String, tint: Color) -> some View {
        Text(title)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.15), in: Capsule())
            .foregroundStyle(tint)
    }

    @MainActor
    public func primaryActionLabel(title: String, isDestructive: Bool) -> some View {
        Text(title)
            .fontWeight(.semibold)
            .foregroundStyle(isDestructive ? ThemeColor.color(.negative) : ThemeColor.color(.accentPrimary))
    }
}

private struct LeapUIAdapterKey: EnvironmentKey {
    static let defaultValue = LeapUIAdapter()
}

public extension EnvironmentValues {
    var leapUI: LeapUIAdapter {
        get { self[LeapUIAdapterKey.self] }
        set { self[LeapUIAdapterKey.self] = newValue }
    }
}
