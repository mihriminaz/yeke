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
  
  fileprivate static var colors = ["#DFFF00", "#FFBF00", "FF7F50", "DE3163", "9FE2BF", "6495ED", "CCCCFF",
                                   "FF0000", "800000", "C0C0C0", "FFFF00", "808080", "808000", "FF00FF", "008080", "000080"]
  static func chooseRandomColor() -> String {
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

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
