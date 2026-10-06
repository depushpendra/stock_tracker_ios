import SwiftUI

public struct FeedControlButton: View {
    @Environment(\.appTheme) private var theme

    let title: String
    let isRunning: Bool
    let isEnabled: Bool
    let action: () -> Void

    public init(title: String, isRunning: Bool, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isRunning = isRunning
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(isRunning ? theme.colors.negative : Color.white)
                .background {
                    if isRunning {
                        Capsule()
                            .strokeBorder(theme.colors.negative.opacity(0.45), lineWidth: 1.5)
                            .background(Capsule().fill(theme.colors.negative.opacity(0.12)))
                    } else {
                        Capsule().fill(theme.colors.accentGradient)
                    }
                }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.55)
        .accessibilityIdentifier("feed_control_button")
    }
}
