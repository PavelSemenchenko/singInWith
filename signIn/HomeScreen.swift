//
//  HomeScreen.swift
//  signIn
//
//  Created by Pavel Semenchenko on 03.11.2023.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var navigationVM: NavigationRouter
    
    var body: some View {
        Text("Hello, This is home page")
            .font(.largeTitle)
            .fontWeight(.bold)
        Button(action: {
            AuthService.signOut()
            navigationVM.pushScreen(route: .signIn)
        }) {
            Text("Sign Out")
        }
    }
}

#Preview {
    HomeScreen()
}
