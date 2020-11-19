//
//  ChatListView.swift
//  uthere
//
//  Created by Mihri Minaz on 25.10.20.
//

import SwiftUI

struct ChatListView: View {
  @ObservedObject var chat: ChatModel
  @EnvironmentObject var session: Session

  var body: some View {
    List(chat.chatList) { chatItem in
      ChatListItemView(code: chatItem.code, chat: chat).environmentObject(session)
    }.environment(\.defaultMinListRowHeight, 75)
  }
}

struct ChatListItemView: View {
  @ObservedObject var chat: ChatModel
  @EnvironmentObject var session: Session
  var code: String
  var chatItem: ChatItem? {
    get {
      chat.chatList.filter { theItem -> Bool in
        theItem.code == code
      }.first
    }
  }
  var token: String? { get { chat.token } }
  
  init(code: String, chat: ChatModel) {
    self.code = code
    self.chat = chat
  }
  
  var body: some View {
    Group {
      if let chatItem = self.chatItem {
        GeometryReader{ geometry in
          self.body(for: geometry.size, chatItem: chatItem)
        }
      }
    }
  }
  
  @ViewBuilder
  private func body(for size: CGSize, chatItem: ChatItem) -> some View {
    ZStack {
      NavigationLink(destination: ChatView(chat: chat, chatItem: chatItem, currentUser: session.currentUser)) {
        ZStack {
          HStack {
            ZStack {
              Circle().fill(AppHelper.chooseRandomColor())
                .frame(width: size.height - 10, height: size.height - 10)
                .padding(.leading, 10)
              Text(AppHelper.chooseRandomImage()).font(.system(size: 48, weight: .semibold)).padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
            }.frame(width: size.height, height:size.height)
            Text(chatItem.lastMessage?.message ?? "Write now or... will be gone soon!").padding(.top, 10)
              .font(.subheadline)
            Spacer()
          }
          Text(AppHelper.dateFormatter(isoDate: chatItem.lastMessage?.createdOn ?? "fd")).font(.footnote).foregroundColor(Color.gray)
            .frame(width: size.width, height: size.height, alignment: .topTrailing)
         }.font(.title)
      }
    }
    .foregroundColor(Color.black)
  }
}

struct ChatListView_Previews: PreviewProvider {
  static var previews: some View {
    let chat = ChatModel()
    let message1 = ChatMessage(id: 1, chatId: 4, code: "bbb", vendor: "ME", message: "Hello how are you doing? I wanted to tell you something. As a message, it should not be more than 3 lines, or what? Although I write.", createdOn: "2020-11-07T23:50:05.173")
    let chatItem1 = ChatItem(id: 4, code: "fddfd", createdOn: "2020-11-06T23:50:05.173", lastMessage: message1, receiveVendorId: "ME", messageList: [message1])
    
    let message2 = ChatMessage(id: 2, chatId: 3, code: "aaa", vendor: "ME", message: "Hello how are you doing?", createdOn: "2020-11-07T23:50:05.173")
    let chatItem2 = ChatItem(id: 5, code: "fddfd", createdOn: "2020-11-06T23:50:05.173", lastMessage: message2, receiveVendorId: "ME", messageList: [message2])
    
    chat.appendToChatList(chatItem1)
    chat.appendToChatList(chatItem2)
    return ChatListView(chat: chat)
  }
}
