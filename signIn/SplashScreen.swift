//
//  SplashScreen.swift
//  signIn
//
//  Created by Pavel Semenchenko on 03.11.2023.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false

    var body: some View {
        VStack {
            Image(systemName: "power").font(.largeTitle).bold()
            Text("Wellcome to Power").font(.largeTitle).bold()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isActive = true
            }
        }
        .background(NavigationLink("", destination: ContentView(), isActive: $isActive).isDetailLink(false))
    }
}


#Preview {
    SplashScreen()
}
