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
      ContentView(session: Session(), chat: ChatModel())
    }
  }
}
