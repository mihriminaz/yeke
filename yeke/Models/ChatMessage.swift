//
//  ChatMessage.swift
//  uthere
//
//  Created by Mihri Minaz on 10.11.20.
//

import Foundation

struct ChatMessage: Identifiable, Codable, Hashable {
  var id: Int
  var chatId: Int?
  var code: String?
  var vendor: String?
  var message: String
  var createdOn: String
  var isSent: Bool = true
  
  private enum CodingKeys: String, CodingKey {
    case id, chatId, code, vendor, message, createdOn
  }
  
  mutating func setSent() {
    self.isSent = true
  }
}
