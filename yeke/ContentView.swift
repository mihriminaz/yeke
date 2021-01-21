//
//  ContentView.swift
//  uthere
//
//  Created by Mihri Minaz on 22.10.20.
//

import SwiftUI
import Combine

struct ContentView: View {
  @ObservedObject var session: Session
  @ObservedObject var chat: ChatModel
  @State var editingMode = false
  @State var showActionView = false
  @State var showChatView = false

  var body: some View {
    NavigationView() {
      Group {
        ZStack {
          NavigationLink("", destination: ChatView(chat: chat, currentUser: session.currentUser), isActive: $showChatView)
          ChatListView(chat: chat).environmentObject(session)
          if showActionView == true && showChatView == false {
            ActionListView(chat: chat, showChatView: $showChatView)
              .environmentObject(session)
          }
        }
      }.navigationViewStyle(StackNavigationViewStyle())
      .navigationBarTitle("Chats", displayMode: .inline)
      .navigationBarItems(
//        leading:
//         Button(action: {
//            print("delete button pressed....")
//         }) { Image(systemName: "trash.fill").font(.system(size: 30, weight: .semibold))
//          .foregroundColor(self.editingMode ? Color.black : Color.gray)
//         },
        trailing: Button(action: {
        self.showActionView = !self.showActionView
      }, label: {
        Image(systemName: self.showActionView ? "xmark.circle" : "circle.circle.fill").font(.system(size: 40, weight: .semibold))
          .foregroundColor(self.showActionView ? Color.black : Color(hex: "#ECDAFE"))
      }))
    }
    .onOpenURL { url in
      guard url.scheme == "yeke" else { return }
      setOpenURL(url: url) { chatItem in
       
      }
    }
    .onReceive(self.session.$connected) { connected in
      if connected {
        HubSession.current.setConnection(token: session.token!, handleMessage: self.handleMessage)
        chat.token = session.token
      }
    }
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
           print("chatItem \(chatItem)")
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
  
  func handleMessage(chatM: ChatMessage?) {
    guard let chatMessage = chatM else { return }
    guard let chatId = chatMessage.chatId,  chatId != 0 else {
      print("There is no chat code, should be a system message \(String(describing: chatM!.chatId))")
      return
    }

    guard let chatCode = chatMessage.code else { return }
    
    let chatMessageIsAdded = chat.addMessageToChat(chatId: Int(chatId), message: chatMessage)
    if chatMessageIsAdded == false { // there was no chat, it is the start of a new chat
      let chatItem = ChatItem(id: Int(chatId), code: chatCode, createdOn: "\(Date.timeIntervalBetween1970AndReferenceDate)", lastMessage: chatMessage, receiveVendorId: chatMessage.vendor, messageList: [chatMessage])
      chat.appendToChatList(chatItem)
        chat.setLastReceivedChatItem(chatItem)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ContentView(session: Session(), chat: ChatModel())
      ContentView(session: Session(), chat: ChatModel())
      .previewDevice("iPhone SE (2nd generation)")
    }
  }
}


