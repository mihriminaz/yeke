//
//  Array+Identifiable.swift
//  memori
//
//  Created by Mihri Minaz on 07.10.20.
//  Copyright © 2020 Mihri Minaz. All rights reserved.
//

import Foundation

extension Array where Element: Identifiable {
  func firstIndex(matching: Element) -> Int? {
    for index in 0..<self.count {
      if self[index].id == matching.id {
        return index
      }
    }
    return nil
  }
}
