//
//  signInApp.swift
//  signIn
//
//  Created by Pavel Semenchenko on 31.10.2023.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
    
    // for phone signIn - регистрация на получение пуш уведомлений
    func application(_ application: UIApplication, didRegisterForRemoteNotificationWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
    }
    // проверка нотификейшн от файрбейса
    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      if Auth.auth().canHandleNotification(notification) {
        completionHandler(.noData)
        return
      }
    }
    // открытие по СХЕМЕ
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        print("\(#file) \(#function) \(url)")
        
      if Auth.auth().canHandle(url) {
        return true
      }
        
        let googleHanlded = GIDSignIn.sharedInstance.handle(url)
        if googleHanlded {
            return true
        }
        
      return false
    }
    
}

@main
struct YourApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }
  }
}
