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
            if let displayName = Auth.auth().currentUser?.displayName {
                            Text("Hello, \(displayName),\n This is home page")
                    .font(.title)
                                .fontWeight(.bold)
                        } else {
                            Text("Hello, User ")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
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
