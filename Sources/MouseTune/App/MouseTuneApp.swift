import SwiftUI

@main
struct MouseTuneApp: App {
    @StateObject private var model = AppModel.shared

    init() { AppModel.shared.start() }

    var body: some Scene {
        MenuBarExtra("MouseTune", systemImage: "computermouse") {
            MenuView().environmentObject(model)
        }
        .menuBarExtraStyle(.window)
    }
}
