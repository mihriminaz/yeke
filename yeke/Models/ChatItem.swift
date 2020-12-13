//
//  ChatItem.swift
//  yeke
//
//  Created by Mihri Minaz on 19.11.20.
//

import Foundation

struct ChatItem: Identifiable, Codable {
  var id: Int
  var code: String
  var createdOn: String
  var lastMessage: ChatMessage?
  var receiveVendorId: String?
  var messageList: [ChatMessage]?
  
  mutating func setMessages(messages: [ChatMessage]) {
    self.messageList = messages
  }
  
  mutating func appendMessage(message: ChatMessage) {
    if self.messageList == nil { self.messageList = [] }
    self.messageList!.append(message)
  }
}
