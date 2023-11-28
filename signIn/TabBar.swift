//
//  TabBar.swift
//  signIn
//
//  Created by Pavel Semenchenko on 28.11.2023.
//

import SwiftUI

enum TabBarId: Int, Hashable {
    case home = 0
    case profile = 1
    case content = 2
}

struct TabBar: View {
    @State var currentTab = TabBarId.home
    @EnvironmentObject private var navigationVM: NavigationRouter
    
    var body: some View {
        TabView(selection: $currentTab) {
            ContentView().tabItem {
                Text("sign in")
            }.tag(TabBarId.content)
            
            HomeScreen().tabItem {
                    Text("home") }
            .tag(TabBarId.home)
             
            ProfileSetupScreen()
                .tabItem { 
                    Text("Profile") }
                .tag(TabBarId.profile)
        }
    }
}

#Preview {
    TabBar()
}
