import ApplicationServices
import Cocoa

final class EventTapManager {
    static let shared = EventTapManager()
    var onButtonSeen: ((Int) -> Void)?

    private var tap: CFMachPort?
    private var source: CFRunLoopSource?
    private var scaler = ScrollScaler()

    @discardableResult
    func start() -> Bool {
        if let tap {
            if !CGEvent.tapIsEnabled(tap: tap) { CGEvent.tapEnable(tap: tap, enable: true) }
            return true
        }
        guard AXIsProcessTrusted() else { return false }

        let types: [CGEventType] = [.scrollWheel, .otherMouseDown, .otherMouseUp, .otherMouseDragged]
        let mask = types.reduce(CGEventMask(0)) { $0 | (CGEventMask(1) << CGEventMask($1.rawValue)) }
        let callback: CGEventTapCallBack = { _, type, event, refcon in
            guard let refcon else { return Unmanaged.passUnretained(event) }
            let mgr = Unmanaged<EventTapManager>.fromOpaque(refcon).takeUnretainedValue()
            return mgr.handle(type: type, event: event)
        }
        guard let newTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap,
            eventsOfInterest: mask, callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else { return false }

        let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, newTap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), src, .commonModes)
        CGEvent.tapEnable(tap: newTap, enable: true)
        tap = newTap
        source = src
        return true
    }

    private func handle(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        switch type {
        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
            return Unmanaged.passUnretained(event)
        case .scrollWheel:
            return handleScroll(event)
        case .otherMouseDown, .otherMouseUp, .otherMouseDragged:
            return handleButton(type: type, event: event)
        default:
            return Unmanaged.passUnretained(event)
        }
    }

    // MARK: Scrolling

    private func handleScroll(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        let pass = Unmanaged.passUnretained(event)
        // Trackpad / Magic Mouse are continuous; only the wheel is touched.
        if event.getIntegerValueField(.scrollWheelEventIsContinuous) != 0 { return pass }

        let cfg = AppModel.shared.config
        let systemIsNatural = (UserDefaults.standard.object(forKey: "com.apple.swipescrolldirection") as? Bool) ?? true
        let dir = cfg.scrollDirection.factor(systemIsNatural: systemIsNatural)
        if cfg.scrollSpeed == 1.0 && dir == 1 { return pass }
        let f = cfg.scrollSpeed * dir

        let lineFields: [CGEventField] = [.scrollWheelEventFixedPtDeltaAxis1, .scrollWheelEventFixedPtDeltaAxis2]
        let intFields: [CGEventField] = [.scrollWheelEventDeltaAxis1, .scrollWheelEventDeltaAxis2]
        let pointFields: [CGEventField] = [.scrollWheelEventPointDeltaAxis1, .scrollWheelEventPointDeltaAxis2]

        var hadInput = false
        var anyOutput = false
        for axis in 0..<2 {
            let lineIn = event.getDoubleValueField(lineFields[axis])
            let pointIn = event.getDoubleValueField(pointFields[axis])
            if lineIn == 0 && pointIn == 0 { continue }
            hadInput = true

            let lineOut = scaler.scale(lineIn, axis: axis, channel: 0, factor: f)
            let pointOut = scaler.scale(pointIn, axis: axis, channel: 1, factor: f)

            event.setIntegerValueField(intFields[axis], value: Int64(lineOut))
            event.setDoubleValueField(lineFields[axis], value: lineOut)
            event.setIntegerValueField(pointFields[axis], value: Int64(pointOut))
            if lineOut != 0 || pointOut != 0 { anyOutput = true }
        }
        if hadInput && !anyOutput { return nil }
        return pass
    }

    // MARK: Buttons

    private func handleButton(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        let n = Int(event.getIntegerValueField(.mouseEventButtonNumber))
        let action = AppModel.shared.config.action(forButton: n)
        let isDown = type == .otherMouseDown
        if isDown {
            DispatchQueue.main.async { [weak self] in self?.onButtonSeen?(n) }
        }
        switch action {
        case .passthrough:
            return Unmanaged.passUnretained(event)
        case .none:
            return nil
        case .middleClick:
            event.setIntegerValueField(.mouseEventButtonNumber, value: 2)
            return Unmanaged.passUnretained(event)
        default:
            if isDown { DispatchQueue.main.async { Actions.perform(action) } }
            return nil
        }
    }
}
