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
    UITableView.appearance().backgroundColor = .clear
    UITableViewCell.appearance().backgroundColor = .clear
    return ZStack {
      List {
        ForEach(chat.chatList.reversed(), id: \.self) { chatItem in
        if let code = chatItem.code {
          ChatListItemView(code: code, chat: chat).environmentObject(session).listRowBackground(Color.clear)
            .listRowInsets(.none)
        }
       }
       .onDelete(perform: removeRows)
      }.listStyle(PlainListStyle())
      
      .environment(\.defaultMinListRowHeight, 75)
    }
  }
  
  func removeRows(at offsets: IndexSet) {
    if let index = offsets.first, let token = session.token {
      let chatToDelete: ChatItem = chat.chatList.remove(at: index)
      NetworkManager().deleteChat(token: token, chatId: chatToDelete.id) { result in
          print("result", result)
      } errorHandler: { error in
        print("error", error)
    }
    }

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
    if let chatItem = self.chatItem {
      GeometryReader{ geometry in
        self.body(for: geometry.size, chatItem: chatItem)
      }
    }
  }
  
  @ViewBuilder
  private func body(for size: CGSize, chatItem: ChatItem) ->
   some View {
    NavigationLink(destination: ChatView(chat: chat, chatItem: chatItem, currentUser: session.currentUser)) {
      ZStack {
        HStack {
          ZStack {
            Circle().fill(Color(hex: chatItem.bgColor))
              .frame(width: size.height - 10, height: size.height - 10)
              .padding(.leading, -5)
            Text(chatItem.avatar).font(.system(size: 48, weight: .semibold)).padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
          }.frame(width: size.height, height:size.height)
          Text(chatItem.lastMessage?.message ?? "Write now or... will be gone soon!").padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 10))
            .font(.subheadline)
          Spacer()
      }
      Text(AppHelper.dateFormatter(isoDate: chatItem.lastMessage?.createdOn ?? "fd")).font(.system(size: 10, weight: .semibold)).foregroundColor(Color.gray)
        .frame(width: size.width, height: size.height, alignment: .bottomTrailing)
      }.padding(.trailing, -20).font(.title)
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
    return ChatListView(chat: chat).environmentObject(Session())
  }
}
