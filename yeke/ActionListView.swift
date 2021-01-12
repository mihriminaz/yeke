//
//  ActionListView.swift
//  uthere
//
//  Created by Mihri Minaz on 10.11.20.
//

import SwiftUI

struct ActionListView: View {
  @Environment(\.presentationMode) var presentationMode
  @EnvironmentObject var session: Session
  @ObservedObject var chat: ChatModel
  @State var showQRGeneratorView = false
  @State var isPresentingScanner = false
  @State var showChatView = false
  @State var qrCode: String = ""
  @Binding var showRandomChatView: Bool
  
  var body: some View {
    GeometryReader{ geometry in
      self.body(for: geometry.size)
    }
  }
  
  @ViewBuilder
  private func body(for size: CGSize) -> some View {
    List {
      Button(action: { startRandomChat() }) { Text("Random Chat") }
      Button(action: { self.isPresentingScanner = true }) { Text("Scan QR")}
       .sheet(isPresented: $isPresentingScanner, content: { self.scannerSheet })
      Button(action: { generateRandomCode() }) { Text("Generate Chat Code") }
    }
    .sheet(isPresented: $showQRGeneratorView) {
      QRGeneratorView(chat: chat, code: self.$qrCode, showQRGeneratorView: $showQRGeneratorView, showChatView: $showChatView)
    }
    .onOpenURL { url in
      setOpenURL(url: url) { chatItem in
        if chatItem != nil { showChatView = true }
      }
    }
    .onReceive(self.session.$scannedCode) { scannedCode in
      if let code = scannedCode {
        setOpenURL(url: URL(string:"yeke://chat?\(code)")) { item in
            if let chatItem = item {
              DispatchQueue.main.async {
                chat.setCurrentChatItem(chatItem)
                showChatView = true
              }
            }
        }
      }
    }
    .listStyle(PlainListStyle())
  }
  
  var scannerSheet : some View {
    CodeScannerView(
      codeTypes: [.qr],
      completion: { result in
        if case let .success(code) = result {
          self.isPresentingScanner = false
          self.session.scannedCode = code
        }
    })
  }
  
  func setOpenURL(url: URL?, completionHandler: @escaping (ChatItem?) -> Void)  {
    guard let token = session.token, let urlString: String =  url?.absoluteString else { return }
    let splittedURLString = urlString.split{$0 == "?"}
    let generatedCodeArray: [String] = splittedURLString.map(String.init)
    
    guard generatedCodeArray.count > 0 else { return }
    
    let generatedCode = generatedCodeArray[generatedCodeArray.count - 1]
    NetworkManager().startChat(generatedCode: generatedCode, token: token) { data in
      print("data \(data)")
        
      guard let jsonData = data.data(using: .utf8) else { return }
      let decoder = JSONDecoder()
          
      do {
        let chatItemResult: ChatItemResult = try decoder.decode(ChatItemResult.self, from: jsonData)
          if let chatItem: ChatItem = chatItemResult.data {
//            print("chatItem \(chatItem)")
            DispatchQueue.main.async {
              self.chat.appendToChatList(chatItem)
              self.chat.setCurrentChatItem(chatItem)
              self.showChatView = true
            }
          }
      } catch {
        // Couldn't create audio player object, log the error
        print("Couldn't parse the active chats  \(error)")
      }
    } errorHandler: { error in
      print("errorororor \(error)")
    }
  }
  
  func startRandomChat() {
    guard let token = session.token else { return }
    NetworkManager().startRandomChat(token: token) { data in
      print("data \(data)")
        
      guard let jsonData = data.data(using: .utf8) else { return }
      let decoder = JSONDecoder()
          
      do {
        let chatItemResult: ChatItemResult = try decoder.decode(ChatItemResult.self, from: jsonData)
          if let chatItem: ChatItem = chatItemResult.data {
            print("chatItem \(chatItem)")
            DispatchQueue.main.async {
              self.chat.appendToChatList(chatItem)
              self.chat.setCurrentChatItem(chatItem)
              self.showRandomChatView = true
            }
          }
      } catch {
        // Couldn't create audio player object, log the error
        print("startRandomChat  \(error)")
      }
    } errorHandler: { error in
      print("Error \(error)")
    }
  }
  
  func generateRandomCode() {
    session.generateInvitationCode { code in
      DispatchQueue.main.async {
        if let code = code {
          self.qrCode = code
          self.showQRGeneratorView = true
        }
      }
    }
  }
}

struct ActionListView_Previews: PreviewProvider {
    static var previews: some View {
      ActionListView(chat: ChatModel(), showRandomChatView: .constant(false))
        .environmentObject(Session())
    }
}
