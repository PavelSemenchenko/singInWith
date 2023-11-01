//
//  ContentView.swift
//  signIn
//
//  Created by Pavel Semenchenko on 31.10.2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseAuthCombineSwift

// need add Push Notification in Capabilities
//        + Background modes
//        + Remote notifications

// firebase - cloud messaging !!! add apple key`s *
// sertifacation- keys- turn Aple push notification + sign in with apple

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .onAppear {
            AuthService().authWithPhoneNumber(phone: "+380688880168")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

class AuthService {
    func authWithPhoneNumber(phone: String = "+380688880168") {
        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { verificationID, error in
            print(verificationID)
            print(error)
            
            guard let verificationID = verificationID else {
                // show error to user
                return
            }
            // next screen
            self.signInWithPhone(verificationID: verificationID, verificationCode: "123456")
            
        }
        // ContentView(verificationID: verificationID) - переход на второй экран
    }
    
    func signInWithPhone(verificationID: String, verificationCode: String) {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        
        Auth.auth().signIn(with: credential) { result, error in
            print(result?.user.uid)
            print(result?.additionalUserInfo?.isNewUser)
        }
    }
}
