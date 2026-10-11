import Foundation

/// UI languages. Add a case here plus a `Strings+xx.swift` table to support a new language.
enum Language: String, CaseIterable, Identifiable, Codable {
    case system, en, de, fr, es, pt, it, nb, sv, da

    var id: String { rawValue }

    /// The concrete language used for rendering (`system` follows the macOS preference).
    var resolved: Language {
        guard self == .system else { return self }
        let preferred = Locale.preferredLanguages.first?.lowercased() ?? "en"
        // Norwegian Bokmål/Nynorsk/generic all map to the Bokmål table.
        if preferred.hasPrefix("no") || preferred.hasPrefix("nn") { return .nb }
        return Language.allCases.first { $0 != .system && preferred.hasPrefix($0.rawValue) } ?? .en
    }

    /// Name shown in pickers; each language is shown in its own tongue.
    var nativeName: String? {
        switch self {
        case .system: return nil
        case .en: return "English"
        case .de: return "Deutsch"
        case .fr: return "Français"
        case .es: return "Español"
        case .pt: return "Português"
        case .it: return "Italiano"
        case .nb: return "Norsk"
        case .sv: return "Svenska"
        case .da: return "Dansk"
        }
    }

    /// Flag emoji shown next to the name (`system` uses an SF Symbol instead).
    var flag: String? {
        switch self {
        case .system: return nil
        case .en: return "🇬🇧"
        case .de: return "🇩🇪"
        case .fr: return "🇫🇷"
        case .es: return "🇪🇸"
        case .pt: return "🇵🇹"
        case .it: return "🇮🇹"
        case .nb: return "🇳🇴"
        case .sv: return "🇸🇪"
        case .da: return "🇩🇰"
        }
    }
}
