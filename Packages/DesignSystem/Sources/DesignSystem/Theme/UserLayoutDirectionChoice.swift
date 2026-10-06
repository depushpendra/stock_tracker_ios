import SwiftUI
import Localization

public enum UserLayoutDirectionChoice: String, CaseIterable, Identifiable, Sendable {
    case automatic
    case ltr
    case rtl

    public var id: String { rawValue }

    public func resolvedLayoutDirection(locale: Locale) -> LayoutDirection {
        switch self {
        case .automatic:
            return LayoutDirectionResolver.direction(for: locale)
        case .ltr:
            return .leftToRight
        case .rtl:
            return .rightToLeft
        }
    }
}

private struct UserLayoutDirectionChoiceKey: EnvironmentKey {
    static let defaultValue: Binding<UserLayoutDirectionChoice>? = nil
}

public extension EnvironmentValues {
    var userLayoutDirectionChoice: Binding<UserLayoutDirectionChoice>? {
        get { self[UserLayoutDirectionChoiceKey.self] }
        set { self[UserLayoutDirectionChoiceKey.self] = newValue }
    }
}

public struct LayoutDirectionPickerMenu: View {
    @Binding var choice: UserLayoutDirectionChoice

    public init(choice: Binding<UserLayoutDirectionChoice>) {
        self._choice = choice
    }

    public var body: some View {
        Menu {
            Picker(selection: $choice) {
                Text(L10n.layoutAutomatic).tag(UserLayoutDirectionChoice.automatic)
                Text(L10n.layoutLTR).tag(UserLayoutDirectionChoice.ltr)
                Text(L10n.layoutRTL).tag(UserLayoutDirectionChoice.rtl)
            } label: {
                EmptyView()
            }
        } label: {
            Image(systemName: iconName(for: choice))
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .accessibilityLabel(L10n.layoutDirection)
        }
    }

    private func iconName(for choice: UserLayoutDirectionChoice) -> String {
        switch choice {
        case .automatic:
            return "globe"
        case .ltr:
            return "text.alignleft"
        case .rtl:
            return "text.alignright"
        }
    }
}
