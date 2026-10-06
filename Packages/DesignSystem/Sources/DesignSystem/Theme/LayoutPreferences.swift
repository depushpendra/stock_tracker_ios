import SwiftUI

public struct LayoutPreferences: Sendable {
    public var locale: Locale
    public var directionOverride: UserLayoutDirectionChoice

    public init(
        locale: Locale = .autoupdatingCurrent,
        directionOverride: UserLayoutDirectionChoice = .automatic
    ) {
        self.locale = locale
        self.directionOverride = directionOverride
    }

    public static let standard = LayoutPreferences()

    public var layoutDirection: LayoutDirection {
        directionOverride.resolvedLayoutDirection(locale: locale)
    }
}

public enum LayoutDirectionResolver {
    public static func direction(for locale: Locale) -> LayoutDirection {
        let languageCode = locale.language.languageCode?.identifier
            ?? locale.identifier.split(separator: "_").first.map(String.init)
            ?? locale.identifier
        if Locale.characterDirection(forLanguage: languageCode) == .rightToLeft {
            return .rightToLeft
        }
        return .leftToRight
    }
}

private struct LayoutPreferencesKey: EnvironmentKey {
    static let defaultValue = LayoutPreferences.standard
}

public extension EnvironmentValues {
    var layoutPreferences: LayoutPreferences {
        get { self[LayoutPreferencesKey.self] }
        set { self[LayoutPreferencesKey.self] = newValue }
    }
}

public extension View {
    /// Applies locale and layout direction to the view tree (including navigation chrome when used on `NavigationStack`).
    func layoutPreferences(_ preferences: LayoutPreferences) -> some View {
        self
            .environment(\.layoutPreferences, preferences)
            .environment(\.locale, preferences.locale)
            .environment(\.layoutDirection, preferences.layoutDirection)
    }

    /// Re-applies layout direction inside screens where `List` / scroll content can drift from the navigation bar.
    func syncLayoutDirectionWithNavigationBar() -> some View {
        modifier(SyncLayoutDirectionModifier())
    }
}

private struct SyncLayoutDirectionModifier: ViewModifier {
    @Environment(\.layoutPreferences) private var layoutPreferences

    func body(content: Content) -> some View {
        content
            .environment(\.layoutDirection, layoutPreferences.layoutDirection)
    }
}
