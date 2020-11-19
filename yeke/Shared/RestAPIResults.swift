//
//  RestAPIResults.swift
//  uthere
//
//  Created by Mihri Minaz on 07.11.20.
//

import Foundation

enum BackendError: Error {
    case LoginResponseInvalid
    case UnknownError
    case ServerError(code: Int, message: String)
    case AuthenticationError
}

enum ClientError: Error {
    case deviceHasNoVendorId
}

struct ChatItemResult: Decodable {
    let data: ChatItem?
}

struct LoginResult: Decodable {
    struct Data: Decodable {
      let token: String?
    }

    let data: Data?
}

struct GenerateCodeResult: Decodable {
    struct Data: Decodable {
      let code: String?
    }

    let data: Data?
}

struct GetActiveChatsResult: Decodable {
    let data: [ChatItem]?
}

struct StartChatResult: Decodable {
  struct Data: Decodable {
    let code: String?
    let id: Int?
  }
  
  let data: Data?
}

struct GetChatMessagesResult: Decodable {
    let data: [ChatMessage]?
}
