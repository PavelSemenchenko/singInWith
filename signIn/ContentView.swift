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
    @EnvironmentObject private var navigationVM: NavigationRouter
    @State private var isPhoneAuthSheetPresented = false
    //@State private var userLoggedIn = (Auth.auth().currentUser != nil)
    @State private var err : String = ""
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "swirl.circle.righthalf.filled.inverse")
                    .imageScale(.large)
                    .foregroundStyle(Color.white)
                    .font(.largeTitle)
                    .bold()
                Text("Power")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
            }.padding()
                .shadow(color: Color.black.opacity(0.8), radius: 5, x: 0, y: 2)
            Spacer()
            Divider()
                .background(Color.black) // Устанавливаем черный цвет для Divider
                .frame(height: 2) // Устанавливаем толщину Divider
            VStack{
                AuthButton(action: {
                    navigationVM.pushScreen(route: .signWithEmail)
                }, systemImage: "at", label: "Sign in with Email")
                
                // sign in with phone
                AuthButton(action: {
                    isPhoneAuthSheetPresented = true
                    // AuthService().authWithPhoneNumber(phone: "+380688880168")
                }, systemImage: "iphone.gen1.circle" , label: "Sing in by phone")
                
                // sign in with google
                AuthButton(action: {
                    AuthService().signInWithGoogleSync(navigation: navigationVM, vc: AuthService.getRootViewController())
                }, systemImage: "g.circle", label: "Sing in with Google")
                
                AuthButton(action: {
                    AuthService().startSignInWithAppleFlow()
                }, systemImage: "apple.logo", label: "SIGN IN WITH APPLE")
                
                //другой вариант входа в гугл
                /*
                AuthButton(action: {
                    Task {
                        do {
                            try await AuthenticationWithGoogle().googleOauth()
                        } catch let e {
                            err = e.localizedDescription
                        }
                    }
                }, systemImage: "person.2.badge.key", label: "google")
                */
            }.padding()
                .sheet(isPresented: $isPhoneAuthSheetPresented) {
                    // Всплывающее окно для входа по телефону
                    PhoneAuthView(isPresented: $isPhoneAuthSheetPresented)
                }
            
            NavigationLink("Trouble Signing In?") {
                
            }.foregroundColor(.black)
        }.navigationBarBackButtonHidden()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(LinearGradient(gradient: Gradient(colors: [.pink, .red]), startPoint: .top, endPoint: .bottom))
            .opacity(0.9)
    }
}
struct PhoneAuthView: View {
    @EnvironmentObject private var navigationVM: NavigationRouter
    @Binding var isPresented: Bool
    @State private var phoneNumber = "+380688880168"
    @State private var verificationCode = "123456"
    @State private var verificationID: String?
    @State private var errorText: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if let errorText = errorText {
                    Text(errorText)
                        .foregroundColor(.red)
                        .padding()
                }
                TextField("Phone Number", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if verificationID != nil {
                    TextField("Verification Code", text: $verificationCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                
                Button(action: {
                    let service = AuthService()
                    
                    guard let verificationID = verificationID else {
                        Task {
                            let newId = await service.getVerificationId(phone: phoneNumber)
                            if newId == nil {
                                errorText = "Please, ensure you hsve enter correct number, include country code!"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    errorText = nil
                                }
                            }
                            verificationID = newId
                        }
                        return
                    }
                    Task {
                        let status = await service.signInWithPhone(verificationID: verificationID, verificationCode: verificationCode)
                        switch (status) {
                            
                        case .newUser:
                            self.navigationVM.pushScreen(route: .signUp)
                        case .signIn:
                            self.navigationVM.pushScreen(route: .home)
                        case .failed:
                            errorText = "Oops, something went wrong. Pleasy, try again later"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                errorText = nil
                            }
                            self.verificationID = nil
                            self.verificationCode = ""
                        }
                    }
                }) {
                    Text(verificationID == nil ? "Send Code" : "Authenticate")
                }
                .padding()
                
                // Добавьте кнопку для закрытия всплывающего окна
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                }
            }
            .padding()
            .navigationTitle("Phone Authentication")
        }
    }
}


#Preview {
    ContentView()
}

enum AuthStatus {
    case newUser
    case signIn
    case failed
}
/*
struct AuthenticationWithGoogle {
    //@EnvironmentObject private var navigationVM: NavigationRouter
    
    func googleOauth() async throws {
        // google sign in
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("no firbase clientID found")
        }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        //get rootView
        let scene = await UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = await scene?.windows.first?.rootViewController
        else {
            fatalError("There is no root view controller!")
        }
        
        //google sign in authentication response
        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController
        )
        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            throw "Unexpected error occurred, please retry"
        }
        
        //Firebase auth
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken, accessToken: user.accessToken.tokenString
        )
        try await Auth.auth().signIn(with: credential)
            navigationVM.pushScreen(route: .home)
                
    }
    
    func logout() async throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }
}*/


extension String: Error {}

class AuthService: NSObject {
    //@EnvironmentObject private var navigationVM: NavigationRouter
    fileprivate var currentNonce: String? // for apple auth
    
    class var isAuthenticated: Bool {
        print(Auth.auth().currentUser?.uid ?? "Unknown")
        return Auth.auth().currentUser != nil
    }
    class func signOut() {
        do {
            try Auth.auth().signOut() // Выход из обычной аутентификации Firebase
            GIDSignIn.sharedInstance.signOut() // Выход из Google
            // ASAuthorizationAppleIDProvider().createRequest().cancel() // Отмена Apple авторизации
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    // phone
    func getVerificationId(phone: String ) async -> String? {
        do {
            let verificationID = try? await PhoneAuthProvider.provider()
                .verifyPhoneNumber(phone, uiDelegate: nil)
            return verificationID
            // получили верификационный ид
        } catch {
            print("\(#file) \(#function) \(error)")
        }
        return nil
    }
    
    func signInWithPhone(verificationID: String, verificationCode: String) async -> AuthStatus {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        do {
            let result = try await Auth.auth().signIn(with: credential)
            if result.additionalUserInfo?.isNewUser == true {
                return .newUser
            }
            return .signIn
        } catch {
            print("\(#file) \(#function) \(error)")
            return .failed
        }
    }
    
    // google
    func signInWithGoogle(vc: UIViewController) async -> AuthStatus {
        // google sign in
        guard let clientID = FirebaseApp.app()?.options.clientID else { return .failed}
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: vc)
            // получили результат гугл авторизации
            
            let status = result.user
            guard let idToken = status.idToken?.tokenString else {
                return .signIn
            }
            /*
             guard let result = result else {
             return .failed
             }*/
            // авторизация в файрбейс
            let credential = GoogleAuthProvider.credential(
                withIDToken: result.user.idToken!.tokenString,
                accessToken: result.user.accessToken.tokenString)
            
            let authResult = try await Auth.auth().signIn(with: credential)
            
            return authResult.additionalUserInfo?.isNewUser == true ? .newUser : .signIn
            print("===== User id is : \(authResult.user.uid)")
            print(authResult.additionalUserInfo?.isNewUser)
        } catch {
            return .failed
        }
        
        
    }
    // передали навигацию вне вью
    func signInWithGoogleSync(navigation: NavigationRouter ,vc: UIViewController) {
        Task {
            let status = await AuthService().signInWithGoogle(vc: vc)
            
            switch (status) {
            case .newUser:
                navigation.pushScreen(route: .signUp)
            case .signIn:
                print("======== status currently is : \(status.self)")
                navigation.pushScreen(route: .home)
            case .failed:
                // Обработка ошибки
                print("Google Sign In Failed")
            }
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

struct AuthButton: View {
    let action: () -> Void
    let systemImage: String
    let label: String
    
    var body: some View {
        Button(action: action) {
            HStack() {
                //Spacer()
                Image(systemName: systemImage)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.white)
                Text(label)
                    .bold()
                    .foregroundColor(.white)
                //Spacer()
            }.frame(alignment: .leading)
        }
        .frame(width: 210, height: 36)
        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .background(Capsule().stroke(Color.white, lineWidth: 1))
        .shadow(radius: 8.0)
        
    }
}
