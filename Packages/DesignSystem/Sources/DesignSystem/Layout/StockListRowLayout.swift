import SwiftUI

/// Lays out icon, title, and price in reading order; `layoutDirection` mirrors the row with the navigation bar.
public struct StockListRowLayout<Icon: View, Title: View, Price: View>: View {
    @Environment(\.layoutPreferences) private var layoutPreferences

    private let icon: Icon
    private let title: Title
    private let price: Price

    public init(
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder title: () -> Title,
        @ViewBuilder price: () -> Price
    ) {
        self.icon = icon()
        self.title = title()
        self.price = price()
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            icon
            title
                .frame(maxWidth: .infinity, alignment: .leading)
            price
        }
        .environment(\.layoutDirection, layoutPreferences.layoutDirection)
    }
}
