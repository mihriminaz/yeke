//
//  AppDelegate.swift
//  yeke
//
//  Created by Mihri Minaz on 12.11.20.
//

import SwiftUI

@main
struct Yeke: App {
    var body: some Scene {
        WindowGroup {
          let session = Session()
          let chat = ChatModel()
            ContentView(session: session, chat: chat)
        }
    }
}
