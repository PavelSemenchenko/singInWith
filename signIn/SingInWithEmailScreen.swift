//
//  SingInWithEmailScreen.swift
//  signIn
//
//  Created by Pavel Semenchenko on 04.11.2023.
//

import SwiftUI


struct SingInWithEmailScreen: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject private var navigationVM: NavigationRouter
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding()
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Пароль", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
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
#Preview {
    SingInWithEmailScreen()
}
