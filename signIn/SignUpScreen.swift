//
//  SignUpScreen.swift
//  signIn
//
//  Created by Pavel Semenchenko on 09.11.2023.
//

import SwiftUI

struct SignUpScreen: View {
    @EnvironmentObject private var navigationVM: NavigationRouter
    @State private var userName = ""
    
    var body: some View {
        VStack {
            Text("Hello, new user")
            TextField("Enter your name", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
        }
    }
}

#Preview {
    SignUpScreen()
}
