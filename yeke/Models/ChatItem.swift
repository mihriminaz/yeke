//
//  ChatItem.swift
//  yeke
//
//  Created by Mihri Minaz on 19.11.20.
//

import Foundation

struct ChatItem: Identifiable, Codable, Hashable {
  var id: Int
  var code: String
  var createdOn: String
  var lastMessage: ChatMessage?
  var receiveVendorId: String?
  var messageList: [ChatMessage]?
  
  var _avatar: String?
  var avatar: String {
    get { return _avatar ?? "🕛" }
  }
  
  mutating func setAvatar(avatar: String) {
    self._avatar = avatar
  }
  
  mutating func setMessages(messages: [ChatMessage]) {
    self.messageList = messages
  }
  
  mutating func appendMessage(message: ChatMessage) {
    if self.messageList == nil { self.messageList = [] }
    self.messageList!.append(message)
  }
}
