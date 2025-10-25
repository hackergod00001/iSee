//
//  iseeApp.swift
//  isee
//
//  Created by Upmanyu Jha and Updated on 10/25/2025.
//


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
