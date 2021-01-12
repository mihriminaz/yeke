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
  @State var showRandomChatView = false

  var body: some View {
    NavigationView() {
      Group {
        ZStack {
          NavigationLink("", destination: ChatView(chat: chat, currentUser: session.currentUser), isActive: $showRandomChatView)
          ChatListView(chat: chat).environmentObject(session)
          if showActionView == true {
            ActionListView(chat: chat, showRandomChatView: $showRandomChatView)
              .environmentObject(session)
          }
        }
      }.navigationBarTitle("Chats", displayMode: .inline)
      .navigationBarItems(leading:
         Button(action: {
            print("delete button pressed....")
         }) { Image(systemName: "trash.fill").font(.system(size: 30, weight: .semibold))
          .foregroundColor(self.editingMode ? Color.black : Color.gray)
         },
        trailing: Button(action: {
        self.showActionView = !self.showActionView
      }, label: {
        Image(systemName: self.showActionView ? "xmark.circle" : "circle.circle.fill").font(.system(size: 40, weight: .semibold))
        .foregroundColor(self.showActionView ? Color.black : Color.pink)
      }))
    }
    .onReceive(self.session.$connected) { connected in
      if connected {
        HubSession.current.setConnection(token: session.token!, handleMessage: self.handleMessage)
        chat.token = session.token
      }
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


