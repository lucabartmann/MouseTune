import SwiftUI

struct MenuView: View {
    @EnvironmentObject var model: AppModel
    @State private var tab: Tab = .controls
    @State private var launchAtLogin = LoginItem.isEnabled

    enum Tab { case controls, settings }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            if !model.tapRunning { permissionBanner }
            Picker("", selection: $tab) {
                Text(model.t(.tabControls)).tag(Tab.controls)
                Text(model.t(.tabSettings)).tag(Tab.settings)
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            switch tab {
            case .controls: controls
            case .settings: settings
            }
            footer
        }
        .padding(16)
        .frame(width: 400)
        .tint(model.config.accent.color)
    }

    // MARK: Chrome

    private var header: some View {
        HStack(spacing: 10) {
            AppGlyph(size: 30)
            Text("MouseTune").font(.headline)
            Spacer()
            StatusPill(active: model.tapRunning, text: model.t(model.tapRunning ? .statusActive : .statusInactive))
        }
    }

    private var footer: some View {
        HStack {
            Text(model.t(.version, AppInfo.version)).font(.caption).foregroundStyle(.secondary)
            if let url = AppInfo.repositoryURL {
                Link(model.t(.viewOnGitHub), destination: url).font(.caption)
            }
            Spacer()
            Button(model.t(.quit)) { NSApplication.shared.terminate(nil) }
                .keyboardShortcut("q")
        }
    }

    private var permissionBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(model.t(.permissionTitle), systemImage: "exclamationmark.triangle.fill")
                .font(.subheadline.weight(.semibold)).foregroundColor(.orange)
            Text(model.t(.permissionBody)).font(.caption).fixedSize(horizontal: false, vertical: true)
            HStack {
                Button(model.t(.openAccessibility)) { Permissions.open(.accessibility) }
                Button(model.t(.openInputMonitoring)) { Permissions.open(.inputMonitoring) }
            }
            .controlSize(.small)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.orange.opacity(0.14)))
    }

    // MARK: Controls tab

    private var controls: some View {
        VStack(spacing: 12) {
            Card(icon: "cursorarrow.motionlines", title: model.t(.sectionPointer)) {
                Toggle(model.t(.pointerOverride), isOn: $model.config.pointerSpeedEnabled)
                HStack {
                    Slider(value: $model.config.pointerSpeed, in: 0.1...3.0)
                        .disabled(!model.config.pointerSpeedEnabled)
                    Text(String(format: "%.2f", model.config.pointerSpeed))
                        .monospacedDigit().frame(width: 40, alignment: .trailing)
                }
            }
            Card(icon: "arrow.up.and.down.text.horizontal", title: model.t(.sectionScroll)) {
                HStack {
                    Text(model.t(.scrollSpeed))
                    Slider(value: $model.config.scrollSpeed, in: 0.2...4.0)
                    Text(String(format: "%.1f×", model.config.scrollSpeed))
                        .monospacedDigit().frame(width: 40, alignment: .trailing)
                }
                DirectionPicker()
                Text(model.t(.scrollHint, model.t(systemScrollIsNatural() ? .systemNatural : .systemClassic)))
                    .font(.caption).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Card(icon: "computermouse", title: model.t(.sectionButtons)) {
                ForEach(Array(2...7), id: \.self) { n in
                    HStack {
                        Text(buttonLabel(n))
                        Spacer()
                        Picker("", selection: Binding(
                            get: { model.config.action(forButton: n) },
                            set: { model.config.setAction($0, forButton: n) }
                        )) {
                            ForEach(ButtonAction.allCases) { Text(model.t($0.l10n)).tag($0) }
                        }
                        .labelsHidden()
                        .frame(width: 180)
                    }
                }
                Text(model.lastButton.map { model.t(.lastDetected, $0) } ?? model.t(.pressAButton))
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private func buttonLabel(_ n: Int) -> String {
        switch n {
        case 2: return model.t(.buttonMiddle, n)
        case 3: return model.t(.buttonBack, n)
        case 4: return model.t(.buttonForward, n)
        default: return model.t(.buttonOther, n)
        }
    }

    // MARK: Settings tab

    private var settings: some View {
        VStack(spacing: 12) {
            Card(icon: "globe", title: model.t(.sectionLanguage)) { LanguageChoice() }
            Card(icon: "paintpalette", title: model.t(.sectionAppearance)) { AccentSwatches() }
            Card(icon: "gearshape", title: model.t(.sectionGeneral)) {
                Toggle(model.t(.launchAtLogin), isOn: Binding(
                    get: { launchAtLogin },
                    set: { LoginItem.set($0); launchAtLogin = LoginItem.isEnabled }
                ))
                Button(model.t(.showWelcome)) { OnboardingController.shared.show() }
            }
        }
    }
}
