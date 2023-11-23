//
//  SignUpScreen.swift
//  signIn
//
//  Created by Pavel Semenchenko on 09.11.2023.
//

import SwiftUI

struct SignUpScreen: View {
    @EnvironmentObject private var navigationVM: NavigationRouter
    @EnvironmentObject private var repository: UserRepository
    @State private var name = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            Text("Hello, new user").font(.title)
            //add upload image
            TextField("Enter Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
                .padding()
            TextField("Enter password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
                .padding()
            TextField("Enter your first name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
                .padding()
            TextField("Enter your last name", text: $lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
                .padding()
            
            Button("Save Profile") {
                guard !name.isEmpty, !lastName.isEmpty else { return }
                Task {
                   await repository.signUp(email: email, password: password)
                }
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
            .disabled(name.isEmpty)
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
