//
//  NavigationRouter.swift
//  signIn
//
//  Created by Pavel Semenchenko on 04.11.2023.
//

import Foundation
import SwiftUI

enum NavigationRoute: Hashable {
    case splash
    case signIn
    case signUp
    case home
    case signWithEmail
    //case editTodo(todo: Todo )
}

class NavigationRouter: ObservableObject {
    @Published var currentRoute: NavigationPath = NavigationPath()
    
    // добавляем на верх колоды путь
    func pushScreen(route: NavigationRoute) {
        currentRoute.append(route)
    }
    func pushHome() {
        currentRoute.removeLast(currentRoute.count)
        pushScreen(route: .home)
    }
    //назад - убираем последний слой колоды
    func popScreen() {
        currentRoute.removeLast()
    }
    //убираем все и переходим на ,,,
    func popUntilSignInScreen() {
        currentRoute.removeLast(currentRoute.count)
        pushScreen(route: .signIn)
    }
}
