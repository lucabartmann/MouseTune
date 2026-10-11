import SwiftUI

enum ScrollDirection: String, CaseIterable, Identifiable, Codable {
    case system, natural, classic
    var id: String { rawValue }

    var l10n: L10n {
        switch self {
        case .system: return .directionSystem
        case .natural: return .directionNatural
        case .classic: return .directionClassic
        }
    }

    /// Multiplier applied to wheel deltas. macOS has already applied its own
    /// "natural scrolling" flip before the event reaches the tap, so the result
    /// is defined absolutely against the system setting.
    func factor(systemIsNatural: Bool) -> Double {
        switch self {
        case .system: return 1
        case .natural: return systemIsNatural ? 1 : -1
        case .classic: return systemIsNatural ? -1 : 1
        }
    }
}

enum ButtonAction: String, CaseIterable, Identifiable, Codable {
    case passthrough, none, middleClick, back, forward, missionControl, appExpose
    case spaceLeft, spaceRight, copy, paste, screenshot
    case playPause, nextTrack, previousTrack, volumeUp, volumeDown, mute

    var id: String { rawValue }

    var l10n: L10n {
        switch self {
        case .passthrough: return .actionPassthrough
        case .none: return .actionNone
        case .middleClick: return .actionMiddleClick
        case .back: return .actionBack
        case .forward: return .actionForward
        case .missionControl: return .actionMissionControl
        case .appExpose: return .actionAppExpose
        case .spaceLeft: return .actionSpaceLeft
        case .spaceRight: return .actionSpaceRight
        case .copy: return .actionCopy
        case .paste: return .actionPaste
        case .screenshot: return .actionScreenshot
        case .playPause: return .actionPlayPause
        case .nextTrack: return .actionNextTrack
        case .previousTrack: return .actionPreviousTrack
        case .volumeUp: return .actionVolumeUp
        case .volumeDown: return .actionVolumeDown
        case .mute: return .actionMute
        }
    }
}

enum AccentTheme: String, CaseIterable, Identifiable, Codable {
    case blue, purple, pink, orange, green, graphite
    var id: String { rawValue }

    var color: Color {
        switch self {
        case .blue: return Color(red: 0.04, green: 0.52, blue: 1.0)
        case .purple: return Color(red: 0.62, green: 0.34, blue: 0.95)
        case .pink: return Color(red: 0.96, green: 0.27, blue: 0.55)
        case .orange: return Color(red: 1.0, green: 0.58, blue: 0.0)
        case .green: return Color(red: 0.2, green: 0.74, blue: 0.4)
        case .graphite: return Color(red: 0.5, green: 0.52, blue: 0.56)
        }
    }

    var l10n: L10n {
        switch self {
        case .blue: return .accentBlue
        case .purple: return .accentPurple
        case .pink: return .accentPink
        case .orange: return .accentOrange
        case .green: return .accentGreen
        case .graphite: return .accentGraphite
        }
    }
}

/// Everything that is persisted. Decoding is tolerant so newer fields never break old saves.
struct Config: Codable, Equatable {
    var pointerSpeedEnabled = false
    var pointerSpeed = 0.7
    var scrollSpeed = 1.0
    var scrollDirection: ScrollDirection = .system
    var buttonActions: [String: ButtonAction] = [:]
    var language: Language = .system
    var accent: AccentTheme = .blue
    var onboardingDone = false

    enum CodingKeys: String, CodingKey {
        case pointerSpeedEnabled, pointerSpeed, scrollSpeed, scrollDirection, buttonActions
        case language, accent, onboardingDone
    }

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        pointerSpeedEnabled = try c.decodeIfPresent(Bool.self, forKey: .pointerSpeedEnabled) ?? false
        pointerSpeed = try c.decodeIfPresent(Double.self, forKey: .pointerSpeed) ?? 0.7
        scrollSpeed = try c.decodeIfPresent(Double.self, forKey: .scrollSpeed) ?? 1.0
        scrollDirection = try c.decodeIfPresent(ScrollDirection.self, forKey: .scrollDirection) ?? .system
        buttonActions = try c.decodeIfPresent([String: ButtonAction].self, forKey: .buttonActions) ?? [:]
        language = try c.decodeIfPresent(Language.self, forKey: .language) ?? .system
        accent = try c.decodeIfPresent(AccentTheme.self, forKey: .accent) ?? .blue
        onboardingDone = try c.decodeIfPresent(Bool.self, forKey: .onboardingDone) ?? false
    }

    func action(forButton n: Int) -> ButtonAction { buttonActions[String(n)] ?? .passthrough }
    mutating func setAction(_ a: ButtonAction, forButton n: Int) { buttonActions[String(n)] = a }
}
