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
  @State var showActionView = false
  @State var showChatView = false

  var body: some View {
    NavigationView() {
      Group {
        ZStack {
          NavigationLink("", destination: ChatView(chat: chat, currentUser: session.currentUser), isActive: $showChatView)
          ChatListView(chat: chat).environmentObject(session)
          
          if chat.chatList.count <= 0 {
            TutorialView(showActionView: $showActionView)
          }

          if showActionView == true && showChatView == false {
            ActionListView(chat: chat, showChatView: $showChatView, showActionView: $showActionView)
              .environmentObject(session)
          }
        }
      }.navigationViewStyle(StackNavigationViewStyle())
      .navigationBarTitle("Chats", displayMode: .inline)
      .navigationBarItems(
        leading:
         Button(action: {
            print("refresh button pressed....")
          if let _ = session.token {
            chat.getFirstTimeChatList()
          } else {
            session.initialConnection()
          }
         }) { Image(systemName: "arrow.clockwise").font(.system(size: 30, weight: .semibold)).foregroundColor(Color(hex: "#c397f0"))
         },
        trailing: Button(action: {
        self.showActionView = !self.showActionView
      }, label: {
        Image(systemName: self.showActionView ? "xmark.circle" : "sun.max").font(.system(size: 40, weight: .semibold))
          .foregroundColor(self.showActionView ? Color.black : Color(hex: "#c397f0"))
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


