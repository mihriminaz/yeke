//
//  UserModel.swift
//  uthere
//
//  Created by Mihri Minaz on 06.11.20.
//

import Foundation

enum UserKey: String {
  case token = "token"
  case userName = "userName"
  case password = "password"
}

struct UserModel {
  private(set) var userName: String?
  private(set) var password: String?
  private(set) var token: String?
  private(set) var keychain: KeychainSwift
  
  init(keychain: KeychainSwift) {
    self.keychain = keychain
    userName = keychain.get(UserKey.userName.rawValue)
    password = keychain.get(UserKey.password.rawValue)
    token = keychain.get(UserKey.token.rawValue)
  }
  
  init(keychain: KeychainSwift, userName: String, password: String, token: String) {
    self.keychain = keychain
    self.userName = userName
    self.password = password
    self.token = token
    self.save()
  }
  
  func save() {
    if userName != nil {
      keychain.set(userName!, forKey: UserKey.userName.rawValue)
    }
    if password != nil {
      keychain.set(password!, forKey: UserKey.password.rawValue)
    }
    if token != nil {
      keychain.set(token!, forKey: UserKey.token.rawValue)
    }
  }

  func wipe() {
    keychain.delete(UserKey.userName.rawValue)
    keychain.delete(UserKey.password.rawValue)
    keychain.delete(UserKey.token.rawValue)
  }
}
