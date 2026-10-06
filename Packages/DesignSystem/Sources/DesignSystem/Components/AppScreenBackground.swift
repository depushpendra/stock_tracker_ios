import SwiftUI

public struct AppScreenBackground: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public var body: some View {
        ZStack {
            theme.colors.backgroundPrimary
                .ignoresSafeArea()

            GeometryReader { proxy in
                Circle()
                    .fill(theme.colors.gradientStart.opacity(colorScheme == .dark ? 0.22 : 0.18))
                    .frame(width: proxy.size.width * 0.9)
                    .blur(radius: 60)
                    .offset(x: proxy.size.width * 0.35, y: -proxy.size.height * 0.15)

                Circle()
                    .fill(theme.colors.gradientEnd.opacity(colorScheme == .dark ? 0.18 : 0.14))
                    .frame(width: proxy.size.width * 0.75)
                    .blur(radius: 70)
                    .offset(x: -proxy.size.width * 0.35, y: proxy.size.height * 0.55)
            }
            .ignoresSafeArea()
        }
    }
}
