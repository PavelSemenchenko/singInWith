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
                
                AuthButton(action: {
                    isPhoneAuthSheetPresented = true
                    // AuthService().authWithPhoneNumber(phone: "+380688880168")
                }, systemImage: "iphone.gen1.circle" , label: "Sing in by phone")
                
                AuthButton(action: {
                    AuthService().signInWithGoogleSync(vc: AuthService.getRootViewController())
                }, systemImage: "g.circle", label: "Sing in with Google")
                
                AuthButton(action: {
                    AuthService().startSignInWithAppleFlow()
                }, systemImage: "apple.logo", label: "SIGN IN WITH APPLE")
                
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
        /*
         .onAppear {
         //AuthService().startSignInWithAppleFlow()
         //AuthService().authWithPhoneNumber(phone: "+380688880168")
         }
         
         .task {
         await AuthService().signInWithGoogle(vc: AuthService.getRootViewController())
         }*/
    }
}
struct PhoneAuthView: View {
    @Binding var isPresented: Bool
    @State private var phoneNumber = "+380688880168"
    @State private var verificationCode = "123456"
    @State private var verificationID: String?
    
    var body: some View {
        NavigationView {
            VStack {
                // Добавьте поля для ввода номера телефона и проверочного кода
                TextField("Phone Number", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button(action: {
                    AuthService().authWithPhoneNumber(phone: "+380688880168")
                }) {
                    Text("Get Verification Code")
                }
                .padding()
                
                TextField("Verification Code", text: $verificationCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    AuthService().signInWithPhone(verificationID: verificationID!, verificationCode: verificationCode)
                }) {
                    Text("Authenticate")
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

class AuthService: NSObject {
    @EnvironmentObject private var navigationVM: NavigationRouter
    fileprivate var currentNonce: String? // for apple auth
    
    // phone
    func authWithPhoneNumber(phone: String = "+380688880168") {
        // сделав запрос
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phone, uiDelegate: nil) { verificationID, error in
                // получили
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
        // вход в файрбейс по креденшл собраного из телефона и пароля
        Auth.auth().signIn(with: credential) { result, error in
            if let user = result?.user {
                print("User UID: \(user.uid)")
                
                // Проверяем, новый ли пользователь (isNewUser), и определяем, куда перейти
                if result?.additionalUserInfo?.isNewUser == true {
                    self.navigationVM.pushScreen(route: .signWithEmail)
                } else {
                    self.navigationVM.pushScreen(route: .home)
                }
            } else {
                if let error = error {
                    // Обработка ошибки авторизации
                    print("Error: \(error.localizedDescription)")
                }
            }
            /*
             print(result?.user.uid)
             print(result?.additionalUserInfo?.isNewUser)
             let userId = result?.user.uid
             let isNewUser = result?.additionalUserInfo?.isNewUser
             
             if isNewUser == false {
             self.navigationVM.pushScreen(route: .home)
             } else {
             self.navigationVM.pushScreen(route: .signWithEmail)
             }*/
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
