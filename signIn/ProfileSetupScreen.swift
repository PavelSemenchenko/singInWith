//
//  ProfileSetupScreen.swift
//  signIn
//
//  Created by Pavel Semenchenko on 26.11.2023.
//

import SwiftUI

struct ProfileSetupScreen: View {
    @EnvironmentObject private var navigationVM: NavigationRouter
    @EnvironmentObject private var repository: UserRepository
    @State private var name = ""
    @State private var lastName = ""
    
    var body: some View {
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
                do {
                    var service = UserRepository()
                    service.navigationVM = navigationVM
                    try await service.addLastName(name: name, lastName: lastName)
                    navigationVM.pushHome()
                } catch {
                    
                }
            }
            
        }
    }
}

#Preview {
    ProfileSetupScreen()
}
