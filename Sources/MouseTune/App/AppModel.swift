import ApplicationServices
import Cocoa
import Combine

final class AppModel: ObservableObject {
    static let shared = AppModel()
    private static let defaultsKey = "MouseTuneConfig"

    @Published var config: Config { didSet { save(); PointerSpeed.apply(config) } }
    @Published var tapRunning = false
    @Published var accessibilityTrusted = false
    @Published var lastButton: Int?

    private var timer: Timer?
    private var tick = 0

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.defaultsKey),
           let cfg = try? JSONDecoder().decode(Config.self, from: data) {
            config = cfg
        } else {
            config = Config()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: Self.defaultsKey)
        }
    }

    func start() {
        EventTapManager.shared.onButtonSeen = { [weak self] n in self?.lastButton = n }
        if !config.onboardingDone {
            DispatchQueue.main.async { OnboardingController.shared.show() }
        } else if !AXIsProcessTrusted() {
            requestAccessibility()
        }
        refresh()
        PointerSpeed.apply(config)

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.refresh()
            self.tick += 1
            if self.tick % 3 == 0 { PointerSpeed.apply(self.config) }
        }
        let nc = NotificationCenter.default
        nc.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: .main) { _ in
            PointerSpeed.restore()
        }
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            PointerSpeed.apply(self.config)
        }
    }

    /// Localized string for the current UI language.
    func t(_ key: L10n) -> String { Strings.text(key, config.language) }

    func t(_ key: L10n, _ args: CVarArg...) -> String {
        String(format: Strings.text(key, config.language), arguments: args)
    }

    func requestAccessibility() {
        _ = AXIsProcessTrustedWithOptions(["AXTrustedCheckOptionPrompt": true] as CFDictionary)
    }

    func refresh() {
        let trusted = AXIsProcessTrusted()
        if accessibilityTrusted != trusted { accessibilityTrusted = trusted }
        let running = EventTapManager.shared.start()
        if tapRunning != running { tapRunning = running }
    }
}
