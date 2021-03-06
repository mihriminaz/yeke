//
//  Login.swift
//  uthere
//
//  Created by Mihri Minaz on 22.10.20.
//

import Foundation
import Combine
import SwiftUI

class Session: ObservableObject {
  private var vendorId: String? { UIDevice.current.identifierForVendor?.uuidString }
  @Published private(set) var connected: Bool = false
  @Published private(set) var currentUser: UserModel?
  @Published var scannedCode: String?
  var token: String? { currentUser?.token }
  let keychain = KeychainSwift()
  
  init(user: UserModel? = nil) {
    currentUser = user ?? UserModel(keychain: KeychainSwift())
    
    // app can not be used no vendor
    guard self.vendorId != nil else { return }
    
    // phone reset
    if self.currentUser?.userName == nil {
      register(user: vendorId)
      return
    }
    
    // phone reset
    if let _ = self.currentUser?.userName, vendorId != currentUser?.userName {
      currentUser?.wipe()
      register(user: vendorId)
      return
    }
    
    self.token != nil ? self.connected = true : self.initialConnection()
  }
  
  func initialConnection() {
    if let userName = currentUser?.userName, let password = currentUser?.password {
      // user & password is there
      if !userName.contains(self.vendorId!) {
        // user deleted the app installed again
        // wipe everything!
        // delete user because of this reason, use flag & store this information???
        print("user deleted the app & installed again")
        currentUser?.wipe()
        self.reregister()
      } else { // login
        self.login(userName: userName, password: password)
      }
    } else {
      self.register()
    }
  }
  
  func login(userName: String, password: String) {
    NetworkManager().login(userName: userName, password: password) { data in
      if let jsonData = data.data(using: .utf8) {
        let decoder = JSONDecoder()
        if let parsedResult: LoginResult = try? decoder.decode(LoginResult.self, from: jsonData) {
          if let token = parsedResult.data?.token {
            DispatchQueue.main.async {
              self.currentUser = UserModel(keychain: KeychainSwift(), userName: userName, password: password, token: token)
              self.connected = true
            }
          } else {
            print("NetworkManager().login invalid response, this should not happen ever!!!")
            self.reregister()
          }
        }
      }
    } errorHandler: { error in
      self.reregister()
    }
  }
  
  func generateInvitationCode(completionHandler: @escaping (String?) -> Void) {
    guard let token = self.token else {
      completionHandler(nil)
      return
    }
    // token is there, get active chats
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
    } errorHandler: { error in
      if let errorTyped = error as? BackendError {
        switch errorTyped {
        case .AuthenticationError:
          self.initialConnection()
          completionHandler(nil)
        default:
          completionHandler(nil)
        }
      }
    }
  }

  func reregister() {
    // if error user name add time let timeInterval = someDate.timeIntervalSince1970
    currentUser?.wipe()

    let timeInterval = Date().timeIntervalSince1970
    let newUserName = "\(self.vendorId!)+\(timeInterval)"
    self.register(user: newUserName)
  }

  func register(user: String? = nil) {
    guard let userName = user ?? self.vendorId else { return }
    let pwd = self.generatePwd()
    NetworkManager().register(userName: userName, password: pwd) { data in
      if let jsonData = data.data(using: .utf8) {
        let decoder = JSONDecoder()
        if let parsedResult: LoginResult = try? decoder.decode(LoginResult.self, from: jsonData) {
          if let token = parsedResult.data?.token {
            self.currentUser = UserModel(keychain: KeychainSwift(), userName: userName, password: pwd, token: token)
            self.connected = true
          }
        }
      }
    } errorHandler: { error in
      print("Register failed: \(error)")
    }
  }
  
  func generatePwd() -> String {
    let pswdChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890@.-#$%^&*()+=-_"
    return String((0..<10).compactMap{ _ in pswdChars.randomElement() })
  }
}
