//
//  ChatView.swift
//  uthere
//
//  Created by Mihri Minaz on 23.10.20.
//

import SwiftUI

enum LoadResult<Success, Failure: Error> {
    case success(Success)
    case failure(Failure)
}

struct ChatView: View {
  @ObservedObject var chat: ChatModel
  @State var text: String = ""
  private var chatItem: ChatItem?
  private var currentUser: UserModel?
  
  init(chat: ChatModel, chatItem: ChatItem, currentUser: UserModel?) {
    self.chat = chat
    self.chatItem = chatItem
    self.currentUser = currentUser
  }

  init(chat: ChatModel, currentUser: UserModel?)  {
    self.chat = chat
    self.currentUser = currentUser
    // this is a random chat do some stuff
    // do a call to create a chat with a random person
    chatItem = chat.currentChatItem
  }
  
  var body: some View {
    return VStack {
      List((chat.currentChatItem?.messageList ?? []).reversed(), id: \.self) {
        Text("\($0.vendor == currentUser?.userName ?  "Me" : "Them"): \($0.message)")
          .scaleEffect(x: 1, y: -1, anchor: .center)
      }
      .scaleEffect(x: 1, y: -1, anchor: .center)
      .offset(x: 0, y: 2)
      
      HStack {
        TextField("Type a message", text: $text)
        Button(action: self.send) {
          Text("Send")
        }
      }.padding()
    }
    .navigationBarTitle("chattin...")
    .onAppear(perform: onAppear)
  }
  
  func send() {
    guard let chatId = self.chat.currentChatItem?.id else { return }
    HubSession.current.send(messageText: text, chatId: chatId) { result in
      text = ""
      print("result \(String(describing: result))")
    }
  }
  
  func onAppear() {
    if let chatItem = self.chatItem {
      chat.setCurrentChatItem(chatItem)
    }
    
    chat.getChatMessages()
  }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
      let chatItem = ChatItem(id: Date().hashValue, code: "code", createdOn: "\(Date.timeIntervalBetween1970AndReferenceDate)", lastMessage: nil, receiveVendorId: "vendor", messageList: [])
      let session = Session()
      ChatView(chat: ChatModel() , chatItem: chatItem, currentUser: session.currentUser)
    }
}

