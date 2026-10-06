import SwiftUI
import Domain

public struct FormattingPreferences: Sendable {
    public var locale: Locale
    public var displayCurrencyCode: CurrencyCode?

    public init(locale: Locale = .autoupdatingCurrent, displayCurrencyCode: CurrencyCode? = nil) {
        self.locale = locale
        self.displayCurrencyCode = displayCurrencyCode
    }

    public static let standard = FormattingPreferences()

    public func currencyCode(for quote: Quote) -> CurrencyCode {
        displayCurrencyCode ?? quote.currencyCode
    }
}

private struct FormattingPreferencesKey: EnvironmentKey {
    static let defaultValue = FormattingPreferences.standard
}

public extension EnvironmentValues {
    var formattingPreferences: FormattingPreferences {
        get { self[FormattingPreferencesKey.self] }
        set { self[FormattingPreferencesKey.self] = newValue }
    }
}

public extension View {
    func formattingPreferences(_ preferences: FormattingPreferences) -> some View {
        environment(\.formattingPreferences, preferences)
    }
}
