//
//  SingInWithEmailScreen.swift
//  signIn
//
//  Created by Pavel Semenchenko on 04.11.2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseAuthCombineSwift


struct SingInWithEmailScreen: View {
    @FocusState private var email
    @FocusState private var password
    @EnvironmentObject private var navigationVM: NavigationRouter
    @EnvironmentObject private var loginVM : SingInWithEmailScreenVM
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding()
                
                TextField("Email", text: $loginVM.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Пароль", text: $loginVM.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    Task {
                        await loginVM.signIn()
                        navigationVM.pushScreen(route: .home)
                    }
                    // Выполните здесь вход с использованием email и пароля
                    // Вы можете добавить свою логику аутентификации в это действие
                    // В этом примере мы просто выведем в консоль email и пароль.
                    print("Email: \(email)")
                    print("Пароль: \(password)")
                }) {
                    Text("Войти")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                NavigationLink("Забыли пароль?", destination: ResetPasswordScreen())
            }
            .navigationBarTitle("Вход")
        }
    }
}

struct ResetPasswordScreen: View {
    @State private var email = ""
    
    var body: some View {
        VStack {
            Text("Введите ваш email для сброса пароля")
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                // Выполните здесь логику сброса пароля
                // В этом примере мы просто выведем в консоль email для сброса пароля.
                print("Запрос на сброс пароля для email: \(email)")
            }) {
                Text("Сбросить пароль")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationBarTitle("Сброс пароля")
    }
}

class SingInWithEmailScreenVM: ObservableObject {
    @Published var email : String = "test@test.com"
    @Published var password: String = "qwerty"
    @Published var busy: Bool = false
    
    
    var isEmailCorrect: Bool {
        email.contains("@")
    }
    
    var isPaswordCorrect: Bool {
        get {
            return password.count >= 6
        }
    }
    
    var canLogin: Bool {
        return isEmailCorrect && isPaswordCorrect
    }
    
    class var isAuthenticated: Bool {
        print(Auth.auth().currentUser?.uid)
        return Auth.auth().currentUser != nil
    }
    
    @MainActor func logOut() {
        try? Auth.auth().signOut()
    }
    
    @MainActor func signIn() async {
        busy = true
        do {
            let result = try? await Auth.auth().signIn(withEmail: email, password: password)
//            open home
        } catch {
            
        }
        busy = false
    }
    @MainActor func signUp() async {
        busy = true
        do {
            let result = try? await Auth.auth().createUser(withEmail: email, password: password)
//            open home
        } catch {
            
        }
        busy = false
    }
}


#Preview {
    SingInWithEmailScreen()
}
