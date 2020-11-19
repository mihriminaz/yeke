//
//  HubSession.swift
//  uthere
//
//  Created by Mihri Minaz on 06.11.20.
//

import Foundation
import Combine
import SwiftUI

class HubSession: ObservableObject {
  @Published private(set) var connection: SignalRService?
  static let current: HubSession = HubSession()
  
  func setConnection(token: String, handleMessage:@escaping (Message?) -> ()) {
    if let url = URL(string: "https://chattyapp.azurewebsites.net/privateHub") {
      connection = SignalRService(url: url, token: token, handleMessage: handleMessage)
    }
  }
  
  func reconnect() {
    if let conn = connection {
      conn.reconnect()
    }
  }
  
  func disconnect() {
    if let conn = connection {
      conn.disconnect()
    }
  }
  
  func send(messageText: String, chatId: Int, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
    connection?.sendMessage(messageText, chatId: chatId, invocationDidComplete: invocationDidComplete)
  }
}
