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
  var isLoadingChatListPage = false
  private var currentChatListPage = 0
  private var canLoadMorePagesChatList = true
  
  let numberOfChatItemsOnEachCall = 20
  
  var token: String? {
    didSet { getFirstTimeChatList() }
  }
  
  func addMessageToChat(chatId: Int, message: ChatMessage) -> Bool {
    print("addMessageToChatiscalled \(message)")
    if currentChatItem != nil, currentChatItem!.id == chatId {
      currentChatItem?.appendMessage(message: message)
      currentChatItem?.lastMessage = message
    }
    
    if let chatItem = self.chatList.filter ({ chatItem in
      chatItem.id == chatId
    }).first {
      if let chosenIndex = self.chatList.firstIndex(matching: chatItem) {
        self.chatList[chosenIndex].appendMessage(message: message)
        self.chatList[chosenIndex].lastMessage = message
        let lastChatItem = self.chatList.remove(at: chosenIndex)
        self.chatList.insert(lastChatItem, at: 0)
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
  
  func getFirstTimeChatList() {
    currentChatListPage = 0
    canLoadMorePagesChatList = true
    getChatListItems()
  }
  
  func loadMoreChatListItems() {
    if canLoadMorePagesChatList {
      currentChatListPage = currentChatListPage + 1
      print("fetching for more: ", currentChatListPage)
      getChatListItems()
    } else {
      print("this was all you can not load more!...", currentChatListPage)
    }
  }
  
  func getChatListItems() {
    guard let token = token else { return }
    NetworkManager().getActiveChats(token: token, page: currentChatListPage) { data in
      if let jsonData = data.data(using: .utf8) {
        let decoder = JSONDecoder()
        
        do {
          let parsedResult: GetActiveChatsResult = try decoder.decode(GetActiveChatsResult.self, from: jsonData)
          if let chatLista = parsedResult.data {
            DispatchQueue.main.async {
              if self.currentChatListPage == 0 {
                self.chatList.removeAll()
              }
              let mutatedChatList = chatLista.map { chatItem -> ChatItem in
                var newChatItem = chatItem
                let (avatar, bgColor) = UserRepository().generateAvatarIfNotYet(userID: chatItem.code)
                newChatItem.setAvatar(avatar)
                newChatItem.setBGColor(bgColor)
                return newChatItem
              }
              
              if chatLista.count < self.numberOfChatItemsOnEachCall { self.canLoadMorePagesChatList = false }
              self.chatList.append(contentsOf: mutatedChatList)
              self.isLoadingChatListPage = false
            }
          }
        } catch {
          // Couldn't create audio player object, log the error
          print("Couldn't parse the active chats  \(error)")
          self.isLoadingChatListPage = false
        }
      }
    } errorHandler: { (error) in
      print("error \(error)")
      
      self.isLoadingChatListPage = false
    }
  }
}

