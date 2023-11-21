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
    @Published var name = "..."
    
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
                // Преобразуем данные документа в объект Contact
                if let contact = try? document.data(as: UserEntity.self) {
                    // Обновляем значение @Published var name
                    self.name = contact.name ?? "John Doe"
                    print(name)
                    print(userId)
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
}
