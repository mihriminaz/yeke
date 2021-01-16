//
//  AppDelegate.swift
//  yeke
//
//  Created by Mihri Minaz on 12.11.20.
//

import SwiftUI
import AppCenter
import AppCenterCrashes

@main
struct Yeke: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    WindowGroup {
      ContentView(session: Session(), chat: ChatModel())
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      AppCenter.start(withAppSecret: "902c23e4-f40c-4a7b-976a-dceceac9f550", services:[
        Crashes.self
      ])
        return true
    }
}
