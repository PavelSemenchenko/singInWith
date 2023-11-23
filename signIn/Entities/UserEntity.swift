//
//  UserEntity.swift
//  signIn
//
//  Created by Pavel Semenchenko on 21.11.2023.
//

import SwiftUI
import FirebaseFirestoreSwift

struct UserEntity: Codable, Identifiable, Hashable  {
    @DocumentID var id: String?
    let name: String
    let lastName: String
}

