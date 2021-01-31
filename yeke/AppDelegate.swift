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
let contentView: ContentView = ContentView(session: session, chat: chat)

@main
struct Yeke {
    static func main() {
        if #available(iOS 14.0, *) {
          YekeNewUI.main()
        } else {
          UIApplicationMain(
                    CommandLine.argc,
                    CommandLine.unsafeArgv,
            NSStringFromClass(UIApplication.self),
                    NSStringFromClass(AppDelegate.self))
        }
    }
}

@available(iOS 14.0, *)
struct YekeNewUI: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      contentView
        .onOpenURL { url in
          guard url.scheme == "yeke" else { return }
          setOpenURL(url: url) { chatItem in
          }
        }
    }
  }
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

      // MARK: Create UISceneConfiguration manually
      let sceneConfiguration = UISceneConfiguration(name: "Default", sessionRole: .windowApplication)
      sceneConfiguration.delegateClass = SceneDelegate.self

      return sceneConfiguration
  }
  
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
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    guard url.scheme == "yeke" else { return false }
    setOpenURL(url: url) { chatItem in
      
    }
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

func setOpenURL(url: URL?, completionHandler: @escaping (ChatItem?) -> Void)  {
  print("i am in setopenurl of content view")
  guard let token = session.token, let urlString: String =  url?.absoluteString else { return }
  let splittedURLString = urlString.split{$0 == "?"}
  let generatedCodeArray: [String] = splittedURLString.map(String.init)
  
  guard generatedCodeArray.count > 0 else { return }
  
  let generatedCode = generatedCodeArray[generatedCodeArray.count - 1]
  NetworkManager().startChat(generatedCode: generatedCode, token: token) { data in
    print("data \(data)")
      
    guard let jsonData = data.data(using: .utf8) else { return }
    let decoder = JSONDecoder()
        
    do {
      let chatItemResult: ChatItemResult = try decoder.decode(ChatItemResult.self, from: jsonData)
        if let chatItem: ChatItem = chatItemResult.data {
         print("chatItem \(chatItem)")
          DispatchQueue.main.async {
            contentView.showActionView = false
            contentView.chat.appendToChatList(chatItem)
            contentView.chat.setCurrentChatItem(chatItem)
            contentView.showChatView = true
          }
        }
    } catch {
      // Couldn't create audio player object, log the error
      print("Couldn't parse the active chats  \(error)")
    }
  } errorHandler: { error in
    print("errorororor \(error)")
  }
}


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      
      window.rootViewController = UIHostingController(rootView: contentView)
      self.window = window
      window.makeKeyAndVisible()
    }
  }

  func sceneDidDisconnect(_ scene: UIScene) {  }
  func sceneDidBecomeActive(_ scene: UIScene) {  }
  func sceneWillResignActive(_ scene: UIScene) {  }
  func sceneWillEnterForeground(_ scene: UIScene) {  }
  func sceneDidEnterBackground(_ scene: UIScene) {  }
}
