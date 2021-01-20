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
    if currentChatItem != nil, currentChatItem!.id == chatId {
      currentChatItem?.messageList?.insert(message, at: 0)
      currentChatItem?.lastMessage = message
      
    }
    
    if let chatItem = self.chatList.filter ({ chatItem in
      chatItem.id == chatId
    }).first {
      if let chosenIndex = self.chatList.firstIndex(matching: chatItem) {
        self.chatList[chosenIndex].appendMessage(message: message)
        self.chatList[chosenIndex].lastMessage = message
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
      if let jsonData = data.data(using: .utf8) {
        let decoder = JSONDecoder()
        do {
          let parsedResult: GetChatMessagesResult = try decoder.decode(GetChatMessagesResult.self, from: jsonData)
          if let chatMessageList = parsedResult.data {
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
      if let jsonData = data.data(using: .utf8) {
        let decoder = JSONDecoder()
        
        do {
          let parsedResult: GetActiveChatsResult = try decoder.decode(GetActiveChatsResult.self, from: jsonData)
          if let chatLista = parsedResult.data {
            DispatchQueue.main.async {
              self.chatList.removeAll()
              let mutatedChatList = chatLista.map { chatItem -> ChatItem in
                var newChatItem = chatItem
                let (avatar, bgColor) = UserRepository().generateAvatarIfNotYet(userID: chatItem.code)
                newChatItem.setAvatar(avatar)
                newChatItem.setBGColor(bgColor)
                return newChatItem
              }
              self.chatList.append(contentsOf: mutatedChatList)
            }
          }
        } catch {
          // Couldn't create audio player object, log the error
          print("Couldn't parse the active chats  \(error)")
        }
      }
    } errorHandler: { (error) in
      print("error \(error)")
    }
  }
}

