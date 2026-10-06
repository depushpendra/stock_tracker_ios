import Foundation

/// User-facing copy from this package's String Catalog (`Localizable.xcstrings`).
public typealias LocalizedString = String

/// Catalog key type used by `String(localized:bundle:)`.
public typealias L10nKey = String.LocalizationValue

private enum L10nResources {
    static var bundle: Bundle { Bundle.module }
}

/// Wraps `String(localized:bundle:)` for the localization SPM module.
public func localizedString(_ key: L10nKey) -> LocalizedString {
    String(localized: key, bundle: L10nResources.bundle)
}

/// Runtime key with JSON/catalog fallback when the key is not in `Localizable.xcstrings`.
public func localizedString(key: String, default defaultValue: String) -> LocalizedString {
    L10nResources.bundle.localizedString(forKey: key, value: defaultValue, table: nil)
}
