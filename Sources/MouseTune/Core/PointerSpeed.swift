import Foundation
import IOKit
import IOKit.hidsystem

/// Mouse-only pointer acceleration via IOKit (trackpad key is never touched).
enum PointerSpeed {
    private static let handle = NXOpenEventStatus()
    private static let key = "HIDMouseAcceleration" as CFString
    private static let systemDefault = 0.6875
    private static var overriding = false

    private static func current() -> Double? {
        var value = 0.0
        return IOHIDGetAccelerationWithKey(handle, key, &value) == kIOReturnSuccess ? value : nil
    }

    private static func set(_ value: Double) {
        if let cur = current(), abs(cur - value) <= 0.0005 { return }
        IOHIDSetAccelerationWithKey(handle, key, value)
    }

    static func apply(_ config: Config) {
        if config.pointerSpeedEnabled {
            overriding = true
            set(config.pointerSpeed)
        } else if overriding {
            restore()
        }
    }

    static func restore() {
        guard overriding else { return }
        overriding = false
        let domain = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain)
        let value = (domain?["com.apple.mouse.scaling"] as? Double).flatMap { $0 >= 0 ? $0 : nil }
        set(value ?? systemDefault)
    }
}
