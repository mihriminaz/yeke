//
//  ChatModel.swift
//  uthere
//
//  Created by Mihri Minaz on 07.11.20.
//

import Foundation
import Combine
import SwiftUI

class ChatModel: ObservableObject {
  @Published private(set) var lastReceivedChatItem: ChatItem?
  @Published private(set) var currentChatItem: ChatItem?
  @Published var chatList = [ChatItem]()
  var token: String? {
    didSet { getChatListItems() }
  }
  
  func addMessageToChat(chatId: Int, message: ChatMessage) -> Bool {
    if currentChatItem != nil, currentChatItem!.id == chatId {     currentChatItem?.messageList?.append(message)
    }
    
    if let chatItem = self.chatList.filter ({ chatItem in
      chatItem.id == chatId
    }).first {
      if let chosenIndex = self.chatList.firstIndex(matching: chatItem) {       self.chatList[chosenIndex].appendMessage(message: message)
        return true
      }
    }
    
    return false
  }
  
  func generateInvitationCode(completionHandler: @escaping (String?) -> Void) {
    guard let token = token else { return }
    NetworkManager().generateInvitationCode(token: token) { data in
      if let jsonData = data.data(using: .utf8) {
        let decoder = JSONDecoder()
        if let parsedResult: GenerateCodeResult = try? decoder.decode(GenerateCodeResult.self, from: jsonData) {
          print("parsedResult \(parsedResult)")
          if let code = parsedResult.data?.code {
            print("code \(code)")
            completionHandler(code)
          }
        }
      }
    } errorHandler: { Error in
      completionHandler(nil)
    }
  }
  
  func setLastReceivedChatItem(_ chatItem: ChatItem) {
    self.lastReceivedChatItem = chatItem
  }
  
  func setCurrentChatItem(_ chatItem: ChatItem) {
    self.currentChatItem = chatItem
  }
  
  func appendToChatList(_ chatItem: ChatItem) {
    self.chatList.append(chatItem)
  }

  func getChatMessages() {
    guard let chatID = self.currentChatItem?.id, let token = token else { return }
    NetworkManager().getChatMessages(chatId: chatID, pageIndex: 0, token: token) { (data) in
//      print("getChatMessages succeeded \(data)")
      if let jsonData = data.data(using: .utf8) {
        let decoder = JSONDecoder()
        do {
          let parsedResult: GetChatMessagesResult = try decoder.decode(GetChatMessagesResult.self, from: jsonData)
//          print("parsedResult \(parsedResult)")
          if let chatMessageList = parsedResult.data {
//            print("token \(chatMessageList)")
            DispatchQueue.main.async {
              self.currentChatItem?.setMessages(messages: chatMessageList)
            }
          }
        } catch { // Couldn't create audio player object, log the error
          print("Couldn't parse the active chats  \(error)")
        }
      }
    } errorHandler: { (error) in
      print("error \(error)")
    }
  }
  
  func getChatListItems() {
    guard let token = token else { return }
    NetworkManager().getActiveChats(token: token) { data in
//      print("getChatMessages succeeded \(data)")
      
      if let jsonData = data.data(using: .utf8) {
        let decoder = JSONDecoder()
        
        do {
          let parsedResult: GetActiveChatsResult = try decoder.decode(GetActiveChatsResult.self, from: jsonData)
//          print("parsedResult \(parsedResult)")
          if let chatLista = parsedResult.data {
//            print("token \(chatLista)")
            DispatchQueue.main.async {
              self.chatList.removeAll()
              self.chatList.append(contentsOf: chatLista)
              }
          }
        }
        catch {
            // Couldn't create audio player object, log the error
            print("Couldn't parse the active chats  \(error)")
        }
        
      }
    } errorHandler: { (error) in
      print("error \(error)")
    }
  }
}
