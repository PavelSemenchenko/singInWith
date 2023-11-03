//
//  ContentView.swift
//  signIn
//
//  Created by Pavel Semenchenko on 31.10.2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseAuthCombineSwift
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import CryptoKit
import AuthenticationServices

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
            
            Button(action: { AuthService().authWithPhoneNumber(phone: "+380688880168")},
                   label: {
                Image(systemName: "iphone.gen1.circle")
                    .frame(width: 40, height: 40)
                Text("Sing in by phone")
            }).frame(width: 200, height: 40)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .background(Color.white)
                .cornerRadius(8.0)
                .shadow(radius: 4.0)
            
            Button(action: { AuthService().signInWithGoogleSync(vc: AuthService.getRootViewController())},
                   label: {
                HStack{
                    Image(systemName: "g.circle")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.black)
                    Text("Sing in with Google")
                        .bold()
                        .foregroundColor(.black)
                }
            }).frame(width: 200, height: 40)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .background(Color.white)
                .cornerRadius(8.0)
                .shadow(radius: 4.0)
            
            Button(action: { AuthService().startSignInWithAppleFlow()},
                   label: {
                HStack{
                    Image(systemName: "apple.logo")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.black)
                    Text("Sing in with Apple")
                        .bold()
                        .foregroundColor(.black)
                }
            })
            .frame(width: 200, height: 40)
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .background(Color.white)
            .cornerRadius(8.0)
            .shadow(radius: 4.0)
            
        }
        .onAppear {
            //AuthService().startSignInWithAppleFlow()
            //AuthService().authWithPhoneNumber(phone: "+380688880168")
        }
        .padding()
        /*
         .task {
         await AuthService().signInWithGoogle(vc: AuthService.getRootViewController())
         }*/
    }
}

#Preview {
    ContentView()
}

class AuthService: NSObject {
    fileprivate var currentNonce: String? // for apple auth
    
    // phone
    func authWithPhoneNumber(phone: String = "+380688880168") {
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phone, uiDelegate: nil) { verificationID, error in
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
    
    // google
    func signInWithGoogle(vc: UIViewController) async {
        guard let clientID = FirebaseApp.app()?.options.clientID else {return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let result = try? await GIDSignIn.sharedInstance.signIn(withPresenting: vc)
        
        guard let result = result else {
            return
        }
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: result.user.idToken!.tokenString,
            accessToken: result.user.accessToken.tokenString)
        
        let result1 = try? await Auth.auth().signIn(with: credential)
        
        print(result1?.user.uid)
        print(result1?.additionalUserInfo?.isNewUser)
        
    }
    
    func signInWithGoogleSync(vc: UIViewController) {
        Task {
            await self.signInWithGoogle(vc: vc)
        }
    }
    
    class func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        return root
    }
    // apple
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        // authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
}

extension AuthService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        currentNonce = nil
        print("failer \(error)")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("cancel \(authorization)")
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error.localizedDescription)
                    return
                }
                // User is signed in to Firebase with Apple.
                // sign in -> навигация дальше !!!
            }
        } else {
            currentNonce = nil
        }
    }
}
