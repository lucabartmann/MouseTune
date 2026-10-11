import Foundation

/// Every user-visible string. Tables live in `Strings+xx.swift`;
/// the unit tests make sure each table covers every case.
enum L10n: String, CaseIterable {
    case tabControls, tabSettings, statusActive, statusInactive
    case permissionTitle, permissionBody, openAccessibility, openInputMonitoring
    case sectionPointer, pointerOverride
    case sectionScroll, scrollSpeed, scrollDirection, scrollHint, systemNatural, systemClassic
    case directionSystem, directionNatural, directionClassic
    case sectionButtons, buttonMiddle, buttonBack, buttonForward, buttonOther, lastDetected, pressAButton
    case actionPassthrough, actionNone, actionMiddleClick, actionBack, actionForward
    case actionMissionControl, actionAppExpose, actionSpaceLeft, actionSpaceRight
    case actionCopy, actionPaste, actionScreenshot
    case actionPlayPause, actionNextTrack, actionPreviousTrack
    case actionVolumeUp, actionVolumeDown, actionMute
    case sectionLanguage, languageSystem
    case sectionAppearance, accentBlue, accentPurple, accentPink, accentOrange, accentGreen, accentGraphite
    case sectionGeneral, launchAtLogin, showWelcome, viewOnGitHub, version, quit
    case obWelcomeTitle, obWelcomeBody, obLanguage
    case obPermTitle, obPermBody, obPermGranted, obPermWaiting, obGrant
    case obSetupTitle, obSetupBody
    case obReadyTitle, obReadyBody
    case obContinue, obBack, obSkip, obFinish
}

enum Strings {
    static func text(_ key: L10n, _ language: Language) -> String {
        table(for: language)[key] ?? en[key] ?? key.rawValue
    }

    static func table(for language: Language) -> [L10n: String] {
        switch language.resolved {
        case .de: return de
        case .fr: return fr
        case .es: return es
        case .pt: return pt
        case .it: return it
        case .nb: return nb
        case .sv: return sv
        case .da: return da
        case .en, .system: return en
        }
    }
}
