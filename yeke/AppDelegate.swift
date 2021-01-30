//
//  AppDelegate.swift
//  yeke
//
//  Created by Mihri Minaz on 12.11.20.
//

import SwiftUI
import AppCenter
import AppCenterCrashes

let session: Session = Session()
let chat: ChatModel = ChatModel()

@main
struct Yeke {
    static func main() {
        if #available(iOS 14.0, *) {
          YekeNewUI.main()
        } else {
            UIApplicationMain(
                CommandLine.argc,
                CommandLine.unsafeArgv,
                nil,
                NSStringFromClass(AppDelegate.self))
        }
    }
}

@available(iOS 14.0, *)
struct YekeNewUI: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  var body: some Scene {
    WindowGroup {
      ContentView(session: session, chat: chat)
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      AppCenter.start(withAppSecret: "902c23e4-f40c-4a7b-976a-dceceac9f550", services:[
        Crashes.self
      ])
      
      let center = UNUserNotificationCenter.current()
      center.delegate = self
      // set the type as sound or badge
      center.requestAuthorization(options: [.sound,.alert,.badge]) { (granted, error) in
          if granted {
              print("Notification Enable Successfully")
          }else{
              print("Some Error Occure")
          }
      }
      application.registerForRemoteNotifications()
      
      return true
    }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print("didReceiveRemoteNotification!", userInfo)
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let deviceToken = tokenParts.joined()
    
    if let token = session.token {
      NetworkManager().setDeviceToken(token: token, deviceToken: deviceToken) { response in
        print("setDeviceToken success response \(response)")
      } errorHandler: { error in
        print("setDeviceToken error \(error)")
      }
    }
    print("Successfully registered for notifications!", deviceToken)
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for notifications: \(error.localizedDescription)")
  }

}
