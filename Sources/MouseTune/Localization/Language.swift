import Foundation

/// UI languages. Add a case here plus a `Strings+xx.swift` table to support a new language.
enum Language: String, CaseIterable, Identifiable, Codable {
    case system, de, en

    var id: String { rawValue }

    /// The concrete language used for rendering (`system` follows the macOS preference).
    var resolved: Language {
        guard self == .system else { return self }
        let preferred = Locale.preferredLanguages.first ?? "en"
        return preferred.hasPrefix("de") ? .de : .en
    }

    /// Name shown in pickers; each language is shown in its own tongue.
    var nativeName: String? {
        switch self {
        case .system: return nil
        case .de: return "Deutsch"
        case .en: return "English"
        }
    }
}
