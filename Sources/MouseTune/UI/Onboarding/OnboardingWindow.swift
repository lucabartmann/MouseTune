import SwiftUI

/// Hosts the onboarding in a regular window (the app itself has no Dock icon or main window).
final class OnboardingController: NSObject, NSWindowDelegate {
    static let shared = OnboardingController()
    private var window: NSWindow?

    func show() {
        if window == nil {
            let host = NSHostingController(rootView: OnboardingView().environmentObject(AppModel.shared))
            let w = NSWindow(contentViewController: host)
            w.styleMask = [.titled, .closable, .fullSizeContentView]
            w.titleVisibility = .hidden
            w.titlebarAppearsTransparent = true
            w.isMovableByWindowBackground = true
            w.isReleasedWhenClosed = false
            w.setContentSize(NSSize(width: 520, height: 540))
            w.delegate = self
            w.center()
            window = w
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    func close() { window?.close() }

    func windowWillClose(_ notification: Notification) {
        AppModel.shared.config.onboardingDone = true
        window = nil
    }
}
