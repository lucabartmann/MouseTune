import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var model: AppModel
    @State private var step = 0
    private let lastStep = 3

    var body: some View {
        let accent = model.config.accent.color
        VStack(spacing: 0) {
            Group {
                switch step {
                case 0: welcome
                case 1: permission
                case 2: setup
                default: ready
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 40)
            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)))
            .id(step)

            bottomBar
        }
        .frame(width: 520, height: 540)
        .background(
            ZStack {
                Color(nsColor: .windowBackgroundColor)
                LinearGradient(colors: [accent.opacity(0.22), .clear], startPoint: .top, endPoint: .center)
            }
            .ignoresSafeArea()
        )
        .tint(accent)
    }

    // MARK: Steps

    private var welcome: some View {
        VStack(spacing: 16) {
            Spacer()
            AppIconView(size: 104)
            Text(model.t(.obWelcomeTitle)).font(.system(size: 26, weight: .bold, design: .rounded))
            Text(model.t(.obWelcomeBody)).multilineTextAlignment(.center).foregroundStyle(.secondary)
            Spacer().frame(height: 6)
            Text(model.t(.obLanguage)).font(.subheadline.weight(.semibold))
            LanguageChoice()
            Spacer()
        }
    }

    private var permission: some View {
        VStack(spacing: 16) {
            Spacer()
            symbol(model.accessibilityTrusted ? "checkmark.shield.fill" : "hand.raised.fill",
                   tint: model.accessibilityTrusted ? .green : model.config.accent.color)
            Text(model.t(.obPermTitle)).font(.system(size: 24, weight: .bold, design: .rounded))
            Text(model.t(.obPermBody)).multilineTextAlignment(.center).foregroundStyle(.secondary)
            StatusPill(active: model.accessibilityTrusted,
                       text: model.t(model.accessibilityTrusted ? .obPermGranted : .obPermWaiting))
            if !model.accessibilityTrusted {
                HStack {
                    Button(model.t(.obGrant)) {
                        model.requestAccessibility()
                        Permissions.open(.accessibility)
                    }
                    .buttonStyle(.borderedProminent).controlSize(.large)
                }
            }
            Spacer()
        }
    }

    private var setup: some View {
        VStack(spacing: 16) {
            Spacer()
            symbol("slider.horizontal.3", tint: model.config.accent.color)
            Text(model.t(.obSetupTitle)).font(.system(size: 24, weight: .bold, design: .rounded))
            Text(model.t(.obSetupBody)).multilineTextAlignment(.center).foregroundStyle(.secondary)
            Card(icon: "arrow.up.and.down.text.horizontal", title: model.t(.scrollDirection)) {
                DirectionPicker()
                Text(model.t(.scrollHint, model.t(systemScrollIsNatural() ? .systemNatural : .systemClassic)))
                    .font(.caption).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Card(icon: "paintpalette", title: model.t(.sectionAppearance)) { AccentSwatches() }
            Spacer()
        }
    }

    private var ready: some View {
        VStack(spacing: 16) {
            Spacer()
            symbol("checkmark.circle.fill", tint: .green)
            Text(model.t(.obReadyTitle)).font(.system(size: 24, weight: .bold, design: .rounded))
            Text(model.t(.obReadyBody)).multilineTextAlignment(.center).foregroundStyle(.secondary)
            Spacer()
        }
    }

    private func symbol(_ name: String, tint: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: 54, weight: .semibold))
            .foregroundColor(tint)
            .frame(height: 84)
    }

    // MARK: Navigation

    private var bottomBar: some View {
        HStack {
            Button(model.t(.obBack)) { go(step - 1) }.opacity(step == 0 ? 0 : 1).disabled(step == 0)
            Spacer()
            HStack(spacing: 7) {
                ForEach(0...lastStep, id: \.self) { i in
                    Circle().fill(i == step ? model.config.accent.color : Color.primary.opacity(0.18))
                        .frame(width: 7, height: 7)
                }
            }
            Spacer()
            if step == lastStep {
                Button(model.t(.obFinish)) { OnboardingController.shared.close() }
                    .buttonStyle(.borderedProminent).controlSize(.large)
            } else {
                Button(step == 1 && !model.accessibilityTrusted ? model.t(.obSkip) : model.t(.obContinue)) {
                    go(step + 1)
                }
                .buttonStyle(.borderedProminent).controlSize(.large)
            }
        }
        .padding(.horizontal, 28).padding(.vertical, 20)
    }

    private func go(_ next: Int) {
        withAnimation(.easeInOut(duration: 0.25)) { step = min(max(next, 0), lastStep) }
    }
}
