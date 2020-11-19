//
//  Helper.swift
//  uthere
//
//  Created by Mihri Minaz on 10.11.20.
//

import Foundation
import SwiftUI

public struct AppHelper {
  fileprivate static var emojis = ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼",
              "🐨", "🐯", "🦁", "🐮", "🐷", "🐽", "🐸", "🐵",
              "🙈", "🙉", "🙊", "🐒", "🐔", "🐧", "🐦", "🐤",
              "🐣", "🐥", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗",
              "🐴", "🦄", "🐝", "🐛", "🦋", "🐌", "🐞", "🐜",
              "🦟", "🦗", "🕷", "🕸", "🦂", "🐢", "🐍", "🦎",
              "🦖", "🦕", "🐙", "🦑", "🦐", "🦞", "🦀", "🐡",
              "🐠", "🐟", "🐬", "🐳", "🐋", "🦈", "🐊", "🐅",
              "🐆", "🦓", "🦍", "🦧", "🐘", "🦛", "🦏", "🐪",
              "🐫", "🦒", "🦘", "🐃", "🐂", "🐄", "🐎", "🐖",
              "🐏", "🐑", "🦙", "🐐", "🦌", "🐕", "🐩", "🦮",
              "🐕‍🦺", "🐈", "🐓", "🦃", "🦚", "🦜", "🦢", "🦩",
              "🕊", "🐇", "🦝", "🦨", "🦡", "🦦", "🦥", "🐁",
              "🐀", "🐿", "🦔" ]
  static func chooseRandomImage() -> String {
    return emojis.randomElement()!
  }

  fileprivate static var colors = [Color.red, Color.purple, Color.blue, Color.orange,
                                   Color.yellow, Color.pink, Color.green, Color.gray]
  static func chooseRandomColor() -> Color {
    return colors.randomElement()!
  }

  static func dateFormatter(isoDate: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    if let date = dateFormatter.date(from:isoDate) {
      let formatter2 = DateFormatter()
      formatter2.dateStyle = .short
      formatter2.timeStyle = .short
      return formatter2.string(from: date)
    }
    return "-"
  }
}
