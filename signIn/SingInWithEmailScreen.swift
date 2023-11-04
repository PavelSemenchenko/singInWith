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
                
                EditField(valid: loginVM.isEmailCorrect, placeholder: "Email", text: $loginVM.email)
                    .submitLabel(.next)
                    .onSubmit {
                        //внимание на другое поле
                        //focusOnPassword()
                        
                    }
                    .keyboardType(.emailAddress)
                
                PasswordField(valid: loginVM.isPaswordCorrect, placeholder: "Password", text: $loginVM.password)
                    .submitLabel(.go)
                    .onSubmit {
                        Task {
                            await loginVM.signIn()
                            navigationVM.pushScreen(route: .home)
                        }
                    }
                    //.focused($password)
                /*
                TextField("Email", text: $loginVM.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Пароль", text: $loginVM.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                */
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
                
                MainButton(text: "Sign In", enabled: loginVM.canLogin, busy: loginVM.busy) {
                    Task {
                        await loginVM.signIn()
                        // open TODOs
                        navigationVM.pushScreen(route: .home)
                    }
                }
                
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

// BUTTON SETUP
fileprivate struct MainButtonStyle: ButtonStyle {
    
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(color)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

struct MainButton: View {
    let text: String
    let enabled: Bool
    let busy: Bool
    let action: () -> Void
    
    private var color: Color {
        var color: Color = enabled ? .blue : .red
        if busy {
            color = .orange
        }
        return color
    }
    
    var body: some View {
        Button(text, action: action)
            .buttonStyle(MainButtonStyle(color: color))
            .disabled(!enabled || busy)
    }
}
struct PasswordField: View {
    var valid: Bool
    var placeholder: String
    @Binding var text: String
    private var backgroundColor: Color {
        valid ? .white : .red
    }
    
    var body: some View {
        SecureField(placeholder, text: $text)
            .border(backgroundColor)
            .cornerRadius(5)
            .textFieldStyle(.roundedBorder)
            .padding(EdgeInsets(top: 8, leading: 36, bottom: 8, trailing: 36))
    }
}
struct EditField: View {
    var valid: Bool
    var placeholder: String
    var text: Binding<String>
    private var backgroundColor: Color {
        valid ? .white : .red
    }
    
    var body: some View {
        TextField(placeholder, text: text)
            .border(backgroundColor)
            .cornerRadius(5)
            .textFieldStyle(.roundedBorder)
            //.background(backgroundColor)
            .padding(EdgeInsets(top: 8, leading: 36, bottom: 8, trailing: 36))
    }
}

#Preview {
    SingInWithEmailScreen()
        .environmentObject(NavigationRouter())
        .environmentObject(SingInWithEmailScreenVM())
}
