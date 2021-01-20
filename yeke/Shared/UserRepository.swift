//
//  UserRepository.swift
//  yeke
//
//  Created by Mihri Minaz on 13.01.21.
//

import Foundation

class UserRepository {
    enum Key: String, CaseIterable {
        case avatarData
        case bgColor
        func make(for userID: String) -> String {
            return self.rawValue + "_" + userID
        }
    }
    let userDefaults: UserDefaults
    // MARK: - Lifecycle
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    // MARK: - API
    func getUserInfo(forUserID userID: String) -> (String, String)? {
      if let avatarName: String = readValue(forKey: .avatarData, userID: userID) , let bgColorName: String = readValue(forKey: .bgColor, userID: userID) {
        return (avatarName, bgColorName)
      }
      return nil
    }
    
    func removeUserInfo(forUserID userID: String) {
        Key
            .allCases
            .map { $0.make(for: userID) }
            .forEach { key in
                userDefaults.removeObject(forKey: key)
        }
    }
  
  func generateAvatarIfNotYet(userID: String) -> (String, String) {
    if let avatarName: String = readValue(forKey: .avatarData, userID: userID), let bgColor: String = readValue(forKey: .bgColor, userID: userID) {
      print("avatarNameexists", avatarName)
       return (avatarName, bgColor)// existing
     }
     // generate something and use it!
    let value = AppHelper.chooseRandomImage()
    let key: Key = .avatarData
    userDefaults.set(value, forKey: key.make(for: userID))
    
    let keyBGColor: Key = .bgColor
    let valueBGColor = AppHelper.chooseRandomColor()
    userDefaults.set(valueBGColor, forKey: keyBGColor.make(for: userID))

    return (value, valueBGColor)
   }
  
    // MARK: - Private
    private func saveValue(forKey key: Key, value: Any, userID: String) {
        userDefaults.set(value, forKey: key.make(for: userID))
    }
    private func readValue<T>(forKey key: Key, userID: String) -> T? {
        return userDefaults.value(forKey: key.make(for: userID)) as? T
    }
}
