import Foundation

enum AppInfo {
    /// Public repository; the link is hidden in the UI when this is nil.
    static let repositoryURL: URL? = URL(string: "https://github.com/lucabartmann/MouseTune")

    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "dev"
    }
}
