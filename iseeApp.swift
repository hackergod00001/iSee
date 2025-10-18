import SwiftUI

@main
struct iseeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var menuBarController = MenuBarController()
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView(controller: menuBarController)
        } label: {
            Image(systemName: menuBarController.menuBarIcon)
                .foregroundColor(menuBarController.iconColor)
        }
        .menuBarExtraStyle(.menu)
    }
}
