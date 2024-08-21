//
//  swiftlabelApp.swift
//  swiftlabel
//
//  Created by Kevin Suhajda on 12/08/2024.
//

import SwiftUI

@main
struct swiftlabelApp: App {
    init() {

        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor.black
   
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
