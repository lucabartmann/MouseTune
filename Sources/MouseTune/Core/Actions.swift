import Cocoa

/// Executes non-passthrough button actions by synthesizing key / media events.
enum Actions {
    static func perform(_ action: ButtonAction) {
        switch action {
        case .back: key(33, .maskCommand)
        case .forward: key(30, .maskCommand)
        case .missionControl:
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Mission Control.app"))
        case .appExpose: key(125, [.maskControl, .maskSecondaryFn])
        case .spaceLeft: key(123, [.maskControl, .maskSecondaryFn])
        case .spaceRight: key(124, [.maskControl, .maskSecondaryFn])
        case .copy: key(8, .maskCommand)
        case .paste: key(9, .maskCommand)
        case .screenshot: key(21, [.maskShift, .maskCommand])
        case .playPause: media(16)
        case .nextTrack: media(17)
        case .previousTrack: media(18)
        case .volumeUp: media(0)
        case .volumeDown: media(1)
        case .mute: media(7)
        case .passthrough, .none, .middleClick: break
        }
    }

    private static func key(_ code: CGKeyCode, _ flags: CGEventFlags) {
        let src = CGEventSource(stateID: .hidSystemState)
        for down in [true, false] {
            guard let e = CGEvent(keyboardEventSource: src, virtualKey: code, keyDown: down) else { continue }
            e.flags = flags
            e.post(tap: .cghidEventTap)
        }
    }

    private static func media(_ keyType: Int) {
        for state in [0xA, 0xB] {
            NSEvent.otherEvent(
                with: .systemDefined, location: .zero,
                modifierFlags: NSEvent.ModifierFlags(rawValue: UInt(state << 8)),
                timestamp: 0, windowNumber: 0, context: nil, subtype: 8,
                data1: (keyType << 16) | (state << 8), data2: -1
            )?.cgEvent?.post(tap: .cghidEventTap)
        }
    }
}
