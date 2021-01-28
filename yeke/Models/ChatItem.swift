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
  
  mutating func setAvatar(_ avatar: String) {
    self._avatar = avatar
  }
  
  var _bgColor: String?
  var bgColor: String {
    get { return _bgColor ?? "FFF000" }
  }
  
  mutating func setBGColor(_ bgColor: String) {
    self._bgColor = bgColor
  }
  
  mutating func setMessages(messages: [ChatMessage]) {
    self.messageList = messages
  }
  
  mutating func appendMessage(message: ChatMessage) {
    if self.messageList == nil { self.messageList = [] }
    
    for (index, theMessage) in messageList!.enumerated() {
      print("Item \(index): \(theMessage)")
      // TODO: check with a proper local message item id
      if theMessage.message == message.message {
        print("set sent it")
        messageList?[index].isSent = true
        return
      }
    }
    
    print("add the new message \(index): \(message)")
    self.messageList!.insert(message, at: 0)
  }
}
