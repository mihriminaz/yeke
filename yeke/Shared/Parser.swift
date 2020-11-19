//
//  Parser.swift
//  uthere
//
//  Created by Mihri Minaz on 10.11.20.
//

import Foundation
let decoder = JSONDecoder()
let encoder = JSONEncoder()

public struct Parser {
  
  static func encode<T: Codable>(_ value: T) -> Data {
    var jsonData = Data()
    let jsonEncoder = JSONEncoder()

    do {
      jsonData = try jsonEncoder.encode(value)
    }
    catch { }
    return jsonData
  }
  
  static func decode<T: Codable>(data: Data, type: T) -> T? {
    let jsonDecoder = JSONDecoder()

    do {
      let parsedResult: T = try jsonDecoder.decode(T.self, from: data)
      return parsedResult
    }
    catch { }
    return nil
  }
}

