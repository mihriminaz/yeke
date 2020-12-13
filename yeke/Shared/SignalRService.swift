//
//  SignalRService.swift
//  uthere
//
//  Created by Mihri Minaz on 25.10.20.
//

import Foundation
import SwiftSignalRClient
public class SignalRService: HubConnectionDelegate {
  private var hubConnection: HubConnection?
  
  public func reconnect() {
    print("reconnect \(String(describing: hubConnection))")
    if let hub = hubConnection {
      hub.start()
    }
  }
  
  
  public func disconnect() {
    print("disconnect \(String(describing: hubConnection))")
    if let hub = hubConnection {
      hub.stop()
    }
  }
  
  public func connectionDidOpen(hubConnection: HubConnection) {
    print("connectionDidOpen")
    self.hubConnection = hubConnection
  }
  
  public func connectionDidFailToOpen(error: Error) {
    print("connectionDidFailToOpen \(String(describing: error))")
  }
  
  public func connectionDidClose(error: Error?) {
    print("connectionDidClose \(String(describing: error))")
  }
  
  public func connectionWillReconnect(error: Error) {
    print("connectionWillReconnect \(String(describing: error))")
  }
  
  public func connectionDidReconnect() {
    print("connectionDidReconnect")
  }
  
  private var connection: HubConnection

  init(url: URL, token: String, handleMessage:@escaping (_ message: ChatMessage?) -> Void ) {
  connection = HubConnectionBuilder(url: url)
    .withHttpConnectionOptions() { httpConnectionOptions in
        httpConnectionOptions.accessTokenProvider = { return token }
    }
    .withLogging(minLogLevel: .error)
    .build()

    connection.delegate = self
    
    connection.on(method: "ReceiveMessage") { (_ message: ChatMessage?) in
      print("ReceiveMessage: chatCode - \(String(describing: message?.message)), vendor - \(String(describing: message?.chatId))")
      handleMessage(message)
    }
    connection.start()
  }
  
  func sendMessage(_ message: String, chatId: Int, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
      self.connection.invoke(method: "SendMessage", chatId, message, invocationDidComplete: invocationDidComplete)
  }
}
