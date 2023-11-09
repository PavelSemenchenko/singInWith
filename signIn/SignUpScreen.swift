//
//  SignUpScreen.swift
//  signIn
//
//  Created by Pavel Semenchenko on 09.11.2023.
//

import SwiftUI

struct SignUpScreen: View {
    @EnvironmentObject private var navigationVM: NavigationRouter
    @State private var userFirstName = ""
    @State private var userLastName = ""
    
    var body: some View {
        VStack {
            Text("Hello, new user").font(.title)
            //add upload image
            TextField("Enter your first name", text: $userFirstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
                .padding()
            TextField("Enter your last name", text: $userLastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
                .padding()
            
            Button("Save Profile") {
                guard !userFirstName.isEmpty, !userLastName.isEmpty else { return }
                /*
                // Save user profile to Firestore
                FirestoreService.shared
                    .createUser(uid: 
                    authViewModel.user?.uid ?? "",
                        userFirstName: userFirstName,
                        userLastName: userLastName)
                */
                
                // Navigate to the home screen
                navigationVM.pushScreen(route: .home)
            }
            .disabled(userFirstName.isEmpty)
            .padding()
            .cornerRadius(8)
            /*
            Button(action: {
                
            }, label: {
                Text("Done")
            })*/
        }
    }
}

#Preview {
    SignUpScreen()
}
