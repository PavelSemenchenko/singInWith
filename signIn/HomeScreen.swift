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
    @StateObject private var userRepository = UserRepository()
    var body: some View {
        VStack{
            Text("Привет, \(userRepository.name)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .onAppear {
                    Task {
                        await userRepository.getUserInfo()
                        print("Current User ID: \(userRepository.name)")
                    }
                }
            /*
            if let displayName = Auth.auth().currentUser?.displayName {
                            Text("Hello, \(displayName),\n This is home page")
                    .font(.title)
                                .fontWeight(.bold)
                        } else {
                            Text("Hello, User ")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
             */
            Spacer()
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
