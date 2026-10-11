import SwiftUI

/// Small design system shared by the menu popover and the onboarding window.

struct Card<Content: View>: View {
    let icon: String
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            content
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.primary.opacity(0.05)))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Color.primary.opacity(0.07)))
    }
}

/// App glyph on an accent gradient tile.
struct AppGlyph: View {
    @EnvironmentObject var model: AppModel
    var size: CGFloat = 28

    var body: some View {
        let accent = model.config.accent.color
        RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
            .fill(LinearGradient(colors: [accent.opacity(0.95), accent.opacity(0.65)],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: size, height: size)
            .overlay(Image(systemName: "computermouse.fill")
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundColor(.white))
            .shadow(color: accent.opacity(0.35), radius: size * 0.2, y: size * 0.08)
    }
}

struct StatusPill: View {
    let active: Bool
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(active ? Color.green : Color.orange).frame(width: 7, height: 7)
            Text(text).font(.caption.weight(.medium))
        }
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(Capsule().fill(Color.primary.opacity(0.07)))
    }
}

struct AccentSwatches: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        HStack(spacing: 10) {
            ForEach(AccentTheme.allCases) { theme in
                Button { model.config.accent = theme } label: {
                    Circle().fill(theme.color).frame(width: 22, height: 22)
                        .overlay(Circle().strokeBorder(Color.white.opacity(0.9), lineWidth: 2)
                            .opacity(model.config.accent == theme ? 1 : 0))
                        .overlay(Circle().strokeBorder(theme.color, lineWidth: 1)
                            .padding(-3).opacity(model.config.accent == theme ? 1 : 0))
                }
                .buttonStyle(.plain)
                .help(model.t(theme.l10n))
            }
        }
        .padding(3)
    }
}

struct LanguageChoice: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Language.allCases) { lang in
                let selected = model.config.language == lang
                Button { model.config.language = lang } label: {
                    Text(lang.nativeName ?? model.t(.languageSystem))
                        .font(.callout.weight(.medium))
                        .frame(maxWidth: .infinity).padding(.vertical, 9)
                        .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(selected ? model.config.accent.color.opacity(0.18) : Color.primary.opacity(0.05)))
                        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(selected ? model.config.accent.color : Color.primary.opacity(0.08),
                                          lineWidth: selected ? 1.5 : 1))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct DirectionPicker: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        Picker("", selection: $model.config.scrollDirection) {
            ForEach(ScrollDirection.allCases) { Text(model.t($0.l10n)).tag($0) }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }
}

func systemScrollIsNatural() -> Bool {
    (UserDefaults.standard.object(forKey: "com.apple.swipescrolldirection") as? Bool) ?? true
}

/// The real app icon when running from the built bundle; falls back to the themed glyph
/// (e.g. when launched via `swift run`, where no icon is bundled).
struct AppIconView: View {
    var size: CGFloat = 96

    var body: some View {
        if Bundle.main.object(forInfoDictionaryKey: "CFBundleIconFile") != nil {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: size, height: size)
        } else {
            AppGlyph(size: size * 0.82)
        }
    }
}
