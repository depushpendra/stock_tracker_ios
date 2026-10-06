import SwiftUI

public struct StockSymbolIconView: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let ticker: String
    var size: CGFloat = 44

    public init(ticker: String, size: CGFloat = 44) {
        self.ticker = ticker
        self.size = size
    }

    public var body: some View {
        let descriptor = StockIconCatalog.descriptor(for: ticker)
        let corner = size * 0.28

        ZStack {
            if let uiImage = StockIconCatalog.uiImage(for: ticker) {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(theme.colors.surfaceCard)
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.18)
            } else {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(descriptor.tint.opacity(colorScheme == .dark ? 0.22 : 0.12))
                Image(systemName: descriptor.sfSymbolName)
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundStyle(iconForeground(for: descriptor))
                    .symbolRenderingMode(.hierarchical)
            }
        }
        .frame(width: size, height: size)
        .overlay {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(theme.colors.surfaceCardStroke, lineWidth: 1)
        }
        .accessibilityLabel(ticker)
    }

    private func iconForeground(for descriptor: StockIconDescriptor) -> Color {
        if descriptor.sfSymbolName == "apple.logo" {
            return colorScheme == .dark ? .white : .primary
        }
        return descriptor.tint
    }
}
