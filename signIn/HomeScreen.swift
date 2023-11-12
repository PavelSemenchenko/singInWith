//
//  HomeScreen.swift
//  signIn
//
//  Created by Pavel Semenchenko on 03.11.2023.
//

import SwiftUI
import FirebaseAuth

struct HomeScreen: View {
    @EnvironmentObject var navigationVM: NavigationRouter
    
    var body: some View {
        VStack{
            /*Text(
                "Hello " +
                (Auth.auth().currentUser?.displayName ?? "Username not found")
            )*/
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
}

#Preview {
    HomeScreen()
}
