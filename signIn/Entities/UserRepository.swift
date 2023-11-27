//
//  UserRepository.swift
//  signIn
//
//  Created by Pavel Semenchenko on 21.11.2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift

class UserRepository: ObservableObject {
    
    var navigationVM: NavigationRouter!
    //@EnvironmentObject private var navigationVM: NavigationRouter
    @Published var name = "..."
    @Published var lastName = ",,,"
    
    @MainActor func getUserInfo() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            return print ("John Doe")
        }
        
        do {
            // взяли снимок из коллекции с текущим идентификатором пользователя
            let querySnapshot = try await Firestore.firestore()
                .collection("profiles")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            // Проверяем, есть ли документы
            guard !querySnapshot.isEmpty else {
                print("No documents found for user with ID: \(userId)")
                return
            }
            
            // Получаем данные первого документа
            if let document = querySnapshot.documents.first {
                // Преобразуем данные документа в объект UserEntity
                if let contact = try? document.data(as: UserEntity.self) {
                    // Обновляем значение @Published var name
                    self.name = contact.name ?? "John Doe"
                    self.objectWillChange.send()
                } else {
                    print("Failed to decode Contact from document data")
                }
            } else {
                print("No documents found for user with ID: \(userId)")
            }
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
        }
    }
    
    @MainActor func signUp(email: String, password: String) async {
        do {
            let result = try? await Auth.auth().createUser(withEmail: email, password: password)
            let uid = (result?.user.uid)!
            //addLastName(uid: uid)
            //            open home
        } catch {
            
        }
    }
    
    @MainActor func addLastName(name:String, lastName: String) async {
        
        if let currentUID = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let userRef = db.collection("profiles").document(currentUID)
            do {
                try await userRef.setData(["name": name, "lastName": lastName]) { error in
                    if let error = error {
                        print("Error adding username to Firestore: \(error.localizedDescription)")
                    } else {
                        print("Username added to Firestore successfully.")
                    }
                }
               // navigationVM.pushHome()
            } catch {
                print("Error adding username to Firestore: \(error.localizedDescription)")
            }
        } else {
            print("Current user ID is nil.")
        }
    }
}
