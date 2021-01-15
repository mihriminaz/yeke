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
    func storeInfo(forUserID userID: String, avatarData: String) {
        saveValue(forKey: .avatarData, value: avatarData, userID: userID)
    }
    
    func getUserInfo(forUserID userID: String) -> String? {
        return readValue(forKey: .avatarData, userID: userID)
    }
    
    func removeUserInfo(forUserID userID: String) {
        Key
            .allCases
            .map { $0.make(for: userID) }
            .forEach { key in
                userDefaults.removeObject(forKey: key)
        }
    }
  
  func generateAvatarIfNotYet(userID: String) -> String {
     if let avatarName: String = readValue(forKey: .avatarData, userID: userID) {
      print("avatarNameexists", avatarName)
       return avatarName // existing
     }
     // generate something and use it!
    let value = AppHelper.chooseRandomImage()
    let key: Key = .avatarData
    userDefaults.set(value, forKey: key.make(for: userID))
    print("value", value)
    return value
   }
  
    // MARK: - Private
    private func saveValue(forKey key: Key, value: Any, userID: String) {
        userDefaults.set(value, forKey: key.make(for: userID))
    }
    private func readValue<T>(forKey key: Key, userID: String) -> T? {
        return userDefaults.value(forKey: key.make(for: userID)) as? T
    }
}
