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
      List {
        ForEach((chat.currentChatItem?.messageList ?? []), id: \.self) { chatMessage in
          ChatMessageView(chatMessage: chatMessage, currentUser: currentUser, avatar: chat.currentChatItem?.avatar)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .listRowInsets(EdgeInsets())
        .background(Color.white)
      }
      .listSeparatorStyle(style: .none)
      .environment(\.defaultMinListRowHeight, 50)
      .scaleEffect(x: 1, y: -1, anchor: .center)
      .offset(x: 0, y: 2)
      Divider()
      HStack {
        TextField("Type a message", text: $text)
        Button(action: self.send) {
          Text("Send")
        }
      }.padding()
    }
    .onAppear(perform: onAppear)
  }
  
  func send() {
    guard let chatId = self.chat.currentChatItem?.id else { return }
    let chatM = ChatMessage(id: Int(TimeInterval.init()), chatId: chatId, code: String(TimeInterval.init()), vendor: currentUser?.userName, message: text, createdOn: String(TimeInterval.init()), isSent: false)
    
    self.chat.addMessageToChat(chatId: chatId, message: chatM)
    
    HubSession.current.send(messageText: text, chatId: chatId) { result in
      print("result \(String(describing: result))")
    }
    text = ""
  }
  
  func onAppear() {
    if let chatItem = self.chatItem {
      chat.setCurrentChatItem(chatItem)
    }
    
    chat.getChatMessages()
  }
}

struct ChatMessageView: View {
  private var chatMessage: ChatMessage
  private var currentUser: UserModel?
  private var avatar: String
  
  init(chatMessage: ChatMessage, currentUser: UserModel?, avatar: String?) {
    self.currentUser = currentUser
    self.chatMessage = chatMessage
    self.avatar = avatar ?? "🕛"
  }
  
  var body: some View {
    Group {
      HStack(alignment: .bottom, spacing: 15) {
        if chatMessage.vendor == currentUser?.userName {
          Spacer()
        }
        
        let bgColor = chatMessage.isSent ? Color.blue : Color(UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0))
    
        Text(chatMessage.message)
          .padding(10)
          .foregroundColor(chatMessage.vendor == currentUser?.userName ? Color.white : Color.black)
          .background(chatMessage.vendor == currentUser?.userName ? bgColor : Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
          .cornerRadius(10)
      }
    }
      .padding(.leading, 10)
      .padding(.trailing, 10)
    .scaleEffect(x: 1, y: -1, anchor: .center)
    .navigationBarTitle("\(avatar)")
  }
}


struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
      let message1 = ChatMessage(id: 1, chatId: 4, code: "bbb", vendor: "Me", message: "Hello how are you doing? I wanted to tell you something. As a message, it should not be more than 3 lines, or what? Although I write.Hello how are you doing? I wanted to tell you something. As a message, it should not be more than 3 lines, or what? Although I write.Hello how are you doing? I wanted to tell you something. As a message, it should not be more than 3 lines, or what? Although I write.Hello how are you doing? I wanted to tell you something. As a message, it should not be more than 3 lines, or what? Although I write.Hello how are you doing? I wanted to tell you something. As a message, it should not be more than 3 lines, or what? Although I write.Hello how are you doing? I wanted to tell you something. As a message, it should not be more than 3 lines, or what? Although I write.Hello how are you doing? I wanted to tell you something. As a message, it should not be more than 3 lines, or what? Although I write.Hello how are you doing? I wanted to tell you something. As a message, it should not be more than 3 lines, or what? Although I write.Hello how are you doing? I wanted to tell you something. As a message, it should not be more than 3 lines, or what? Although I write.Hello how are you doing? I wanted to tell you something. As a message, it should not be more than 3 lines, or what? Although I write.Hello how are you doing? I wanted to tell you something. As a message, it should not be more than 3 lines, or what? Although I write.", createdOn: "2020-11-07T23:50:05.173")
      
      let message2 = ChatMessage(id: 2, chatId: 3, code: "aaa", vendor: "Me", message: "Hello how are you doing?", createdOn: "2020-11-07T23:50:05.173")
      let chatItem = ChatItem(id: Date().hashValue, code: "code", createdOn: "2020-11-06T23:50:05.173", lastMessage: message2, receiveVendorId: "Me", messageList: [message1, message2])
      let user = UserModel(keychain: KeychainSwift(), userName: "Me", password: "pass", token: "token")
      let session = Session(user: user)
      
      ChatView(chat: ChatModel() , chatItem: chatItem, currentUser: session.currentUser)
    }
}


struct ListSeparatorStyle: ViewModifier {
    
    let style: UITableViewCell.SeparatorStyle
    
    func body(content: Content) -> some View {
        content
            .onAppear() {
                UITableView.appearance().separatorStyle = self.style
            }
    }
}
 
extension View {
    
    func listSeparatorStyle(style: UITableViewCell.SeparatorStyle) -> some View {
        ModifiedContent(content: self, modifier: ListSeparatorStyle(style: style))
    }
}
