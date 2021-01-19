//
//  NetworkManager.swift
//  uthere
//
//  Created by Mihri Minaz on 22.10.20.
//

import Foundation

final class NetworkManager {
  let domainURL = "https://chattyapp.azurewebsites.net/api/v1"

  func register(userName: String, password: String, completionHandler: @escaping (String) -> Void, errorHandler: @escaping (Error) -> Void) {
    let semaphore = DispatchSemaphore(value: 0)
    let parameters = "{\r\n    \"VendorId\": \"\(userName)\",\r\n    \"Password\": \"\(password)\"\r\n}"
    let postData =  parameters.data(using: .utf8)

    var request = URLRequest(url: URL(string: "\(domainURL)/account/register")!,timeoutInterval: Double.infinity)
    
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("ARRAffinity=3476a45ffaf68d2bcdb985995034447d94fa4df1ae54a194b813620782b22d6c; ARRAffinitySameSite=3476a45ffaf68d2bcdb985995034447d94fa4df1ae54a194b813620782b22d6c", forHTTPHeaderField: "Cookie")

    request.httpMethod = "POST"
    request.httpBody = postData

    let task = self.request(with: request, semaphore: semaphore, completionHandler: completionHandler, errorHandler: errorHandler)

    task.resume()
    semaphore.wait()
  }
  
  func login(userName: String, password: String, completionHandler: @escaping (String) -> Void, errorHandler: @escaping (Error) -> Void) {
    let semaphore = DispatchSemaphore(value: 1)
    let parameters = "VendorId=\(userName)&Password=\(password)&grant_type=password&Content-Type=application/x-www-form-urlencoded"
    let postData =  parameters.data(using: .utf8)

    var request = URLRequest(url: URL(string: "\(domainURL)/account/token")!,timeoutInterval: Double.infinity)
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    request.httpMethod = "POST"
    request.httpBody = postData

    let task = self.request(with: request, semaphore: semaphore, completionHandler: completionHandler, errorHandler: errorHandler)

    task.resume()
    semaphore.wait()
  }
  
  func getActiveChats(token: String, completionHandler: @escaping (String) -> Void, errorHandler: @escaping (Error) -> Void) {
      getRequest(endPoint: "/chat/getactivechats", token: token, completionHandler: completionHandler, errorHandler: errorHandler)
  }
  
  func getChatMessages(chatId: Int, pageIndex: Int, token: String, completionHandler: @escaping (String) -> Void, errorHandler: @escaping (Error) -> Void) {
      getRequest(endPoint: "/chat/getchatmessages/@chatId?chatId=\(chatId)&pageIndex=\(pageIndex)", token: token, completionHandler: completionHandler, errorHandler: errorHandler)
  }
  
  func generateInvitationCode(token: String, completionHandler: @escaping (String) -> Void, errorHandler: @escaping (Error) -> Void) {
    getRequest(endPoint: "/chat/generateinvitationcode", token: token, completionHandler: completionHandler, errorHandler: errorHandler)
  }
  
  func startChat(generatedCode: String, token: String, completionHandler: @escaping (String) -> Void, errorHandler: @escaping (Error) -> Void) {
    
    let semaphore = DispatchSemaphore (value: 0)

    let parameters = "{\r\n    \"code\": \"\(generatedCode)\"\r\n}"
    let postData = parameters.data(using: .utf8)

    var request = URLRequest(url: URL(string: "\(domainURL)/chat/startchat")!,timeoutInterval: Double.infinity)
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    request.httpMethod = "POST"
    request.httpBody = postData

    let task = URLSession.shared.dataTask(with: request) { responseData, response, error in
      
      if let data = responseData, let result = String(data: data, encoding: .utf8) {
        print(result)
      }
      if let response = response, let code = response.getStatusCode(), code != 200 {
        return errorHandler(code == 401 ? BackendError.AuthenticationError : BackendError.UnknownError)
      }
      if let data = responseData, let result = String(data: data, encoding: .utf8) {
        print(result)
        completionHandler(result)
      }
      
      if let errorReceived = error {
        errorHandler(errorReceived)
      }
      semaphore.signal()
    }

    task.resume()
    semaphore.wait()

  }
  
  func deleteChat(token: String, chatId: Int, completionHandler: @escaping (String) -> Void, errorHandler: @escaping (Error) -> Void) {
    getRequest(endPoint: "/chat/deletechat?chatId=\(chatId)", token: token, completionHandler: completionHandler, errorHandler: errorHandler)
  }
  
  func startRandomChat(token: String, completionHandler: @escaping (String) -> Void, errorHandler: @escaping (Error) -> Void) {
    getRequest(endPoint: "/chat/startrandomchat", token: token, completionHandler: completionHandler, errorHandler: errorHandler)
  }
  
  func getRequest(endPoint: String, token: String, completionHandler: @escaping (String) -> Void, errorHandler: @escaping (Error) -> Void) {
    let semaphore = DispatchSemaphore (value: 0)
    var request = URLRequest(url: URL(string: "\(domainURL)\(endPoint)")!,timeoutInterval: Double.infinity)
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "GET"

    let task = self.request(with: request, semaphore: semaphore, completionHandler: completionHandler, errorHandler: errorHandler)

    task.resume()
    semaphore.wait()
  }

  func request(with request: URLRequest, semaphore:DispatchSemaphore, completionHandler: @escaping (String) -> Void, errorHandler: @escaping (Error) -> Void) -> URLSessionDataTask {
    return URLSession.shared.dataTask(with: request) { responseData, response, error in
      defer { semaphore.signal() }
      if let response = response {
        if let code = response.getStatusCode(), code != 200 {
          if code == 401 { return errorHandler(BackendError.AuthenticationError) }
          if let data = responseData, let _ = String(data: data, encoding: .utf8) {
            let decoder = JSONDecoder()
            if let parsedResult: YekeBackendResult = try? decoder.decode(YekeBackendResult.self, from: data) {
              if let error = parsedResult.error { return errorHandler(error) }
            }
          }
          return errorHandler(BackendError.UnknownError)
        }
      }
      
      if let data = responseData, let result = String(data: data, encoding: .utf8) {
        completionHandler(result)
      }
      
      if let errorReceived = error {
        return errorHandler(errorReceived)
      }
      
      semaphore.signal()
    }
  }
}

struct YekeBackendResult: Decodable {
  let data: Data?
  let error: YekeError?
}


struct YekeError: Decodable, Error {
  let message: String?
  let source: String?
  let code: Int?
  
  init(_ code: Int, message: String, source: String) {
    self.code = code
    self.message = message
    self.source = source
  }
}

extension URLResponse {
    func getStatusCode() -> Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return nil
    }
}

